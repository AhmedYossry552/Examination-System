/*=============================================
  Examination System - Triggers
  Description: Triggers for data integrity and business rules
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Trigger: TR_StudentAnswer_AfterInsertUpdate
-- Description: Auto-grades objective questions and updates exam score
-- =============================================
CREATE OR ALTER TRIGGER Exam.TR_StudentAnswer_AfterInsertUpdate
ON Exam.StudentAnswer
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Recalculate total scores for affected exams
    UPDATE se
    SET 
        TotalScore = (
            SELECT ISNULL(SUM(MarksObtained), 0)
            FROM Exam.StudentAnswer
            WHERE StudentExamID = se.StudentExamID
        ),
        IsGraded = CASE 
            WHEN EXISTS (
                SELECT 1 FROM Exam.StudentAnswer 
                WHERE StudentExamID = se.StudentExamID 
                    AND NeedsManualGrading = 1 
                    AND MarksObtained IS NULL
            ) THEN 0 
            ELSE 1 
        END,
        ModifiedDate = GETDATE()
    FROM Exam.StudentExam se
    WHERE se.StudentExamID IN (
        SELECT DISTINCT StudentExamID FROM inserted
    );
    
    -- Update pass/fail status
    UPDATE se
    SET 
        IsPassed = CASE 
            WHEN se.TotalScore >= e.PassMarks THEN 1 
            ELSE 0 
        END
    FROM Exam.StudentExam se
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    WHERE se.StudentExamID IN (
        SELECT DISTINCT StudentExamID FROM inserted
    ) AND se.IsGraded = 1;
END
GO

-- =============================================
-- Trigger: TR_Question_BeforeDelete
-- Description: Prevents deletion of questions used in active exams
-- =============================================
CREATE OR ALTER TRIGGER Exam.TR_Question_InsteadOfDelete
ON Exam.Question
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @QuestionID INT;
    DECLARE @ErrorMsg NVARCHAR(500);
    
    SELECT @QuestionID = QuestionID FROM deleted;
    
    -- Check if question is used in any active exam
    IF EXISTS (
        SELECT 1 FROM Exam.ExamQuestion eq
        INNER JOIN Exam.Exam e ON eq.ExamID = e.ExamID
        WHERE eq.QuestionID = @QuestionID 
            AND e.IsActive = 1
    )
    BEGIN
        SET @ErrorMsg = 'Cannot delete question ID ' + CAST(@QuestionID AS NVARCHAR(10)) + 
                        '. It is used in active exams. Use soft delete (IsActive = 0) instead.';
        RAISERROR(@ErrorMsg, 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- If not used in active exams, perform hard delete
    DELETE FROM Exam.Question WHERE QuestionID = @QuestionID;
END
GO

-- =============================================
-- Trigger: TR_ExamQuestion_AfterInsert
-- Description: Validates exam total marks don't exceed course max
-- =============================================
CREATE OR ALTER TRIGGER Exam.TR_ExamQuestion_AfterInsert
ON Exam.ExamQuestion
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ExamID INT;
    DECLARE @CurrentTotal INT;
    DECLARE @ExamTotalMarks INT;
    
    SELECT @ExamID = ExamID FROM inserted;
    
    -- Calculate current total
    SELECT @CurrentTotal = SUM(QuestionMarks)
    FROM Exam.ExamQuestion
    WHERE ExamID = @ExamID;
    
    -- Get exam total marks
    SELECT @ExamTotalMarks = TotalMarks
    FROM Exam.Exam
    WHERE ExamID = @ExamID;
    
    -- Validate
    IF @CurrentTotal > @ExamTotalMarks
    BEGIN
        RAISERROR('Total question marks exceed exam total marks.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- =============================================
-- Trigger: TR_StudentExam_AfterUpdate
-- Description: Updates course final grade when exam is graded
-- =============================================
CREATE OR ALTER TRIGGER Exam.TR_StudentExam_AfterUpdate
ON Exam.StudentExam
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update student course grades when exam is graded
    IF UPDATE(IsGraded) OR UPDATE(TotalScore)
    BEGIN
        UPDATE sc
        SET 
            FinalGrade = (
                SELECT ISNULL(SUM(se.TotalScore), 0)
                FROM Exam.StudentExam se
                INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
                WHERE se.StudentID = sc.StudentID
                    AND e.CourseID = sc.CourseID
                    AND se.IsGraded = 1
            ),
            ModifiedDate = GETDATE()
        FROM Academic.StudentCourse sc
        INNER JOIN inserted i ON sc.StudentID = (
            SELECT StudentID FROM inserted WHERE StudentExamID = i.StudentExamID
        )
        WHERE sc.CourseID IN (
            SELECT e.CourseID 
            FROM Exam.Exam e
            WHERE e.ExamID = i.ExamID
        );
        
        -- Update pass/fail status
        UPDATE sc
        SET 
            IsPassed = CASE 
                WHEN sc.FinalGrade >= c.MinDegree THEN 1 
                ELSE 0 
            END
        FROM Academic.StudentCourse sc
        INNER JOIN Academic.Course c ON sc.CourseID = c.CourseID
        INNER JOIN inserted i ON sc.StudentID = (
            SELECT StudentID FROM inserted WHERE StudentExamID = i.StudentExamID
        )
        WHERE sc.CourseID IN (
            SELECT e.CourseID 
            FROM Exam.Exam e
            WHERE e.ExamID = i.ExamID
        );
    END
END
GO

-- =============================================
-- Trigger: TR_User_AfterInsert
-- Description: Audit log for new users
-- =============================================
CREATE OR ALTER TRIGGER Security.TR_User_AfterInsert
ON Security.[User]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Security.AuditLog (TableName, OperationType, RecordID, UserID, NewValue)
    SELECT 
        'User',
        'INSERT',
        UserID,
        UserID,
        'Username: ' + Username + ', Email: ' + Email + ', UserType: ' + UserType
    FROM inserted;
END
GO

-- =============================================
-- Trigger: TR_User_AfterUpdate
-- Description: Audit log for user updates
-- =============================================
CREATE OR ALTER TRIGGER Security.TR_User_AfterUpdate
ON Security.[User]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Security.AuditLog (TableName, OperationType, RecordID, UserID, OldValue, NewValue)
    SELECT 
        'User',
        'UPDATE',
        i.UserID,
        i.UserID,
        'Email: ' + d.Email + ', IsActive: ' + CAST(d.IsActive AS NVARCHAR(1)),
        'Email: ' + i.Email + ', IsActive: ' + CAST(i.IsActive AS NVARCHAR(1))
    FROM inserted i
    INNER JOIN deleted d ON i.UserID = d.UserID;
END
GO

-- =============================================
-- Trigger: TR_Exam_AfterInsert
-- Description: Audit log for exam creation
-- =============================================
CREATE OR ALTER TRIGGER Exam.TR_Exam_AfterInsert
ON Exam.Exam
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Security.AuditLog (TableName, OperationType, RecordID, UserID, NewValue)
    SELECT 
        'Exam',
        'INSERT',
        ExamID,
        (SELECT UserID FROM Academic.Instructor WHERE InstructorID = inserted.InstructorID),
        'ExamName: ' + ExamName + ', Course: ' + CAST(CourseID AS NVARCHAR(10)) + 
        ', TotalMarks: ' + CAST(TotalMarks AS NVARCHAR(10))
    FROM inserted;
END
GO

-- =============================================
-- Trigger: TR_StudentExam_BeforeInsert
-- Description: Validates student is enrolled in course
-- =============================================
CREATE OR ALTER TRIGGER Exam.TR_StudentExam_BeforeInsert
ON Exam.StudentExam
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate student is enrolled in the course
    IF EXISTS (
        SELECT 1 FROM inserted i
        INNER JOIN Exam.Exam e ON i.ExamID = e.ExamID
        WHERE NOT EXISTS (
            SELECT 1 FROM Academic.StudentCourse sc
            WHERE sc.StudentID = i.StudentID 
                AND sc.CourseID = e.CourseID
        )
    )
    BEGIN
        RAISERROR('Student must be enrolled in the course to take the exam.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Insert if validation passes
    INSERT INTO Exam.StudentExam (StudentID, ExamID, IsAllowed, CreatedDate)
    SELECT StudentID, ExamID, IsAllowed, GETDATE()
    FROM inserted;
END
GO

-- =============================================
-- Trigger: TR_QuestionOption_AfterInsert
-- Description: Ensures only one correct answer for multiple choice
-- =============================================
CREATE OR ALTER TRIGGER Exam.TR_QuestionOption_AfterInsertUpdate
ON Exam.QuestionOption
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If a new correct answer is set, unmark others
    IF EXISTS (SELECT 1 FROM inserted WHERE IsCorrect = 1)
    BEGIN
        UPDATE qo
        SET IsCorrect = 0
        FROM Exam.QuestionOption qo
        INNER JOIN inserted i ON qo.QuestionID = i.QuestionID
        WHERE qo.OptionID != i.OptionID
            AND i.IsCorrect = 1;
    END
    
    -- Validate each multiple choice question has at least one correct answer
    DECLARE @QuestionID INT;
    SELECT @QuestionID = QuestionID FROM inserted;
    
    IF NOT EXISTS (
        SELECT 1 FROM Exam.QuestionOption 
        WHERE QuestionID = @QuestionID AND IsCorrect = 1
    )
    BEGIN
        PRINT 'Warning: Question ' + CAST(@QuestionID AS NVARCHAR(10)) + ' has no correct answer marked.';
    END
END
GO

-- =============================================
-- Trigger: TR_Student_AfterUpdate
-- Description: Updates GPA when student course grades change
-- =============================================
CREATE OR ALTER TRIGGER Academic.TR_Student_UpdateGPA
ON Academic.StudentCourse
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update GPA for affected students
    UPDATE s
    SET 
        GPA = Academic.FN_GetStudentGPA(s.StudentID),
        ModifiedDate = GETDATE()
    FROM Academic.Student s
    WHERE s.StudentID IN (
        SELECT DISTINCT StudentID FROM inserted
        UNION
        SELECT DISTINCT StudentID FROM deleted
    );
END
GO

-- =============================================
-- Trigger: TR_Exam_ValidateDateTime
-- Description: Validates exam date/time logic
-- =============================================
CREATE OR ALTER TRIGGER Exam.TR_Exam_ValidateDateTime
ON Exam.Exam
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate StartDateTime < EndDateTime
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE StartDateTime >= EndDateTime
    )
    BEGIN
        RAISERROR('Exam start time must be before end time.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Validate exam window is reasonable (duration matches datetime difference)
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE DATEDIFF(MINUTE, StartDateTime, EndDateTime) < DurationMinutes
    )
    BEGIN
        RAISERROR('Exam duration exceeds the time window (EndDateTime - StartDateTime).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- =============================================
-- Trigger: TR_Course_ValidateDegrees
-- Description: Validates course degree constraints
-- =============================================
CREATE OR ALTER TRIGGER Academic.TR_Course_ValidateDegrees
ON Academic.Course
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE MaxDegree <= MinDegree
    )
    BEGIN
        RAISERROR('Course MaxDegree must be greater than MinDegree.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- =============================================
-- Trigger: TR_Instructor_EnsureTrainingManager
-- Description: Ensures at least one training manager exists
-- =============================================
CREATE OR ALTER TRIGGER Academic.TR_Instructor_EnsureTrainingManager
ON Academic.Instructor
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if any training manager still exists
    IF NOT EXISTS (
        SELECT 1 FROM Academic.Instructor 
        WHERE IsTrainingManager = 1 AND IsActive = 1
    )
    BEGIN
        PRINT 'Warning: No active training managers in the system!';
    END
END
GO

PRINT 'All triggers created successfully!';
GO
