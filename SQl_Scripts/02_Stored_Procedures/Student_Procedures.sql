/*=============================================
  Examination System - Student Management Procedures
  Description: Procedures for student operations
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Procedure: SP_Student_Add
-- Description: Adds a new student
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Student_Add
    @UserID INT,
    @IntakeID INT,
    @BranchID INT,
    @TrackID INT,
    @EnrollmentDate DATE = NULL,
    @StudentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate user exists and is a student
        IF NOT EXISTS (
            SELECT 1 FROM Security.[User] 
            WHERE UserID = @UserID AND UserType = 'Student'
        )
        BEGIN
            RAISERROR('User must be of type Student.', 16, 1);
            RETURN -1;
        END
        
        -- Check if user already has student record
        IF EXISTS (SELECT 1 FROM Academic.Student WHERE UserID = @UserID)
        BEGIN
            RAISERROR('Student record already exists for this user.', 16, 1);
            RETURN -1;
        END
        
        -- Set default enrollment date
        IF @EnrollmentDate IS NULL
            SET @EnrollmentDate = GETDATE();
        
        -- Insert student
        INSERT INTO Academic.Student (UserID, IntakeID, BranchID, TrackID, EnrollmentDate, IsActive)
        VALUES (@UserID, @IntakeID, @BranchID, @TrackID, @EnrollmentDate, 1);
        
        SET @StudentID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Student added successfully with ID: ' + CAST(@StudentID AS NVARCHAR(10));
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Student_Update
-- Description: Updates student information
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Student_Update
    @StudentID INT,
    @IntakeID INT = NULL,
    @BranchID INT = NULL,
    @TrackID INT = NULL,
    @GPA DECIMAL(3,2) = NULL,
    @GraduationDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate student exists
        IF NOT EXISTS (SELECT 1 FROM Academic.Student WHERE StudentID = @StudentID)
        BEGIN
            RAISERROR('Student not found.', 16, 1);
            RETURN -1;
        END
        
        -- Update student
        UPDATE Academic.Student
        SET 
            IntakeID = COALESCE(@IntakeID, IntakeID),
            BranchID = COALESCE(@BranchID, BranchID),
            TrackID = COALESCE(@TrackID, TrackID),
            GPA = COALESCE(@GPA, GPA),
            GraduationDate = COALESCE(@GraduationDate, GraduationDate),
            ModifiedDate = GETDATE()
        WHERE StudentID = @StudentID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Student updated successfully.';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Student_EnrollInCourse
-- Description: Enrolls a student in a course
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Student_EnrollInCourse
    @StudentID INT,
    @CourseID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if already enrolled
        IF EXISTS (
            SELECT 1 FROM Academic.StudentCourse 
            WHERE StudentID = @StudentID AND CourseID = @CourseID
        )
        BEGIN
            RAISERROR('Student is already enrolled in this course.', 16, 1);
            RETURN -1;
        END
        
        -- Enroll student
        INSERT INTO Academic.StudentCourse (StudentID, CourseID, EnrollmentDate)
        VALUES (@StudentID, @CourseID, GETDATE());
        
        COMMIT TRANSACTION;
        
        PRINT 'Student enrolled successfully.';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Student_GetAvailableExams
-- Description: Gets list of available exams for a student
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Student_GetAvailableExams
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExamID,
        e.ExamName,
        c.CourseName,
        c.CourseCode,
        e.ExamType,
        e.TotalMarks,
        e.DurationMinutes,
        e.StartDateTime,
        e.EndDateTime,
        se.IsAllowed,
        se.StartTime,
        se.SubmissionTime,
        se.TotalScore,
        se.IsPassed,
        CASE 
            WHEN se.SubmissionTime IS NOT NULL THEN 'Completed'
            WHEN GETDATE() < e.StartDateTime THEN 'Upcoming'
            WHEN GETDATE() > e.EndDateTime THEN 'Expired'
            WHEN se.StartTime IS NOT NULL THEN 'In Progress'
            ELSE 'Available'
        END AS ExamStatus
    FROM Exam.StudentExam se
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    WHERE se.StudentID = @StudentID
        AND se.IsAllowed = 1
    ORDER BY e.StartDateTime DESC;
END
GO

-- =============================================
-- Procedure: SP_Student_StartExam
-- Description: Starts an exam for a student
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Student_StartExam
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @StartDateTime DATETIME2(3);
        DECLARE @EndDateTime DATETIME2(3);
        DECLARE @StudentExamID INT;
        
        -- Get exam details
        SELECT @StartDateTime = StartDateTime, @EndDateTime = EndDateTime
        FROM Exam.Exam
        WHERE ExamID = @ExamID;
        
        -- Validate exam time window
        IF GETDATE() < @StartDateTime
        BEGIN
            RAISERROR('Exam has not started yet.', 16, 1);
            RETURN -1;
        END
        
        IF GETDATE() > @EndDateTime
        BEGIN
            RAISERROR('Exam time has expired.', 16, 1);
            RETURN -1;
        END
        
        -- Get StudentExamID
        SELECT @StudentExamID = StudentExamID
        FROM Exam.StudentExam
        WHERE StudentID = @StudentID AND ExamID = @ExamID;
        
        -- Check if student is allowed
        IF NOT EXISTS (
            SELECT 1 FROM Exam.StudentExam 
            WHERE StudentExamID = @StudentExamID AND IsAllowed = 1
        )
        BEGIN
            RAISERROR('Student is not allowed to take this exam.', 16, 1);
            RETURN -1;
        END
        
        -- Check if already started
        IF EXISTS (
            SELECT 1 FROM Exam.StudentExam 
            WHERE StudentExamID = @StudentExamID AND StartTime IS NOT NULL
        )
        BEGIN
            RAISERROR('Exam has already been started.', 16, 1);
            RETURN -1;
        END
        
        -- Start exam
        UPDATE Exam.StudentExam
        SET StartTime = GETDATE(),
            ModifiedDate = GETDATE()
        WHERE StudentExamID = @StudentExamID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Exam started successfully.';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Student_SubmitAnswer
-- Description: Submits an answer for a question
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Student_SubmitAnswer
    @StudentExamID INT,
    @QuestionID INT,
    @StudentAnswerText NVARCHAR(MAX) = NULL,
    @SelectedOptionID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @QuestionType NVARCHAR(20);
        DECLARE @IsCorrect BIT;
        DECLARE @MarksObtained DECIMAL(5,2);
        DECLARE @QuestionMarks INT;
        DECLARE @NeedsManualGrading BIT = 0;
        
        -- Get question details
        SELECT @QuestionType = QuestionType
        FROM Exam.Question
        WHERE QuestionID = @QuestionID;
        
        -- Get question marks from exam
        SELECT @QuestionMarks = QuestionMarks
        FROM Exam.ExamQuestion eq
        INNER JOIN Exam.StudentExam se ON eq.ExamID = se.ExamID
        WHERE se.StudentExamID = @StudentExamID AND eq.QuestionID = @QuestionID;
        
        -- Auto-grade based on question type
        IF @QuestionType = 'MultipleChoice'
        BEGIN
            -- Check if selected option is correct
            SELECT @IsCorrect = IsCorrect
            FROM Exam.QuestionOption
            WHERE OptionID = @SelectedOptionID;
            
            IF @IsCorrect = 1
                SET @MarksObtained = @QuestionMarks;
            ELSE
                SET @MarksObtained = 0;
        END
        ELSE IF @QuestionType = 'TrueFalse'
        BEGIN
            -- Check if answer matches correct answer
            DECLARE @CorrectAnswer NVARCHAR(MAX);
            SELECT @CorrectAnswer = CorrectAnswer
            FROM Exam.QuestionAnswer
            WHERE QuestionID = @QuestionID;
            
            IF LOWER(TRIM(@StudentAnswerText)) = LOWER(TRIM(@CorrectAnswer))
            BEGIN
                SET @IsCorrect = 1;
                SET @MarksObtained = @QuestionMarks;
            END
            ELSE
            BEGIN
                SET @IsCorrect = 0;
                SET @MarksObtained = 0;
            END
        END
        ELSE IF @QuestionType = 'Text'
        BEGIN
            -- Text questions need manual grading
            SET @NeedsManualGrading = 1;
            SET @IsCorrect = NULL;
            SET @MarksObtained = NULL;
        END
        
        -- Insert or update answer
        IF EXISTS (
            SELECT 1 FROM Exam.StudentAnswer 
            WHERE StudentExamID = @StudentExamID AND QuestionID = @QuestionID
        )
        BEGIN
            UPDATE Exam.StudentAnswer
            SET 
                StudentAnswerText = @StudentAnswerText,
                SelectedOptionID = @SelectedOptionID,
                IsCorrect = @IsCorrect,
                MarksObtained = @MarksObtained,
                NeedsManualGrading = @NeedsManualGrading,
                AnsweredDate = GETDATE()
            WHERE StudentExamID = @StudentExamID AND QuestionID = @QuestionID;
        END
        ELSE
        BEGIN
            INSERT INTO Exam.StudentAnswer (
                StudentExamID, QuestionID, StudentAnswerText, SelectedOptionID,
                IsCorrect, MarksObtained, NeedsManualGrading
            )
            VALUES (
                @StudentExamID, @QuestionID, @StudentAnswerText, @SelectedOptionID,
                @IsCorrect, @MarksObtained, @NeedsManualGrading
            );
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Answer submitted successfully.';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Student_SubmitExam
-- Description: Submits the entire exam
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Student_SubmitExam
    @StudentExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Calculate total score
        DECLARE @TotalScore DECIMAL(5,2);
        DECLARE @PassMarks INT;
        DECLARE @ExamID INT;
        
        SELECT @TotalScore = ISNULL(SUM(MarksObtained), 0)
        FROM Exam.StudentAnswer
        WHERE StudentExamID = @StudentExamID;
        
        -- Get pass marks
        SELECT @ExamID = ExamID
        FROM Exam.StudentExam
        WHERE StudentExamID = @StudentExamID;
        
        SELECT @PassMarks = PassMarks
        FROM Exam.Exam
        WHERE ExamID = @ExamID;
        
        -- Update student exam
        UPDATE Exam.StudentExam
        SET 
            SubmissionTime = GETDATE(),
            EndTime = GETDATE(),
            TotalScore = @TotalScore,
            IsPassed = CASE WHEN @TotalScore >= @PassMarks THEN 1 ELSE 0 END,
            IsGraded = CASE 
                WHEN EXISTS (
                    SELECT 1 FROM Exam.StudentAnswer 
                    WHERE StudentExamID = @StudentExamID AND NeedsManualGrading = 1
                ) THEN 0 
                ELSE 1 
            END,
            ModifiedDate = GETDATE()
        WHERE StudentExamID = @StudentExamID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Exam submitted successfully. Total Score: ' + CAST(@TotalScore AS NVARCHAR(10));
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Student_GetExamResults
-- Description: Gets student's exam results
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Student_GetExamResults
    @StudentID INT,
    @ExamID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExamID,
        e.ExamName,
        c.CourseName,
        e.TotalMarks,
        e.PassMarks,
        se.TotalScore,
        se.IsPassed,
        se.StartTime,
        se.SubmissionTime,
        se.IsGraded,
        DATEDIFF(MINUTE, se.StartTime, se.SubmissionTime) AS TimeTakenMinutes
    FROM Exam.StudentExam se
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    WHERE se.StudentID = @StudentID
        AND (@ExamID IS NULL OR e.ExamID = @ExamID)
        AND se.SubmissionTime IS NOT NULL
    ORDER BY se.SubmissionTime DESC;
END
GO

-- =============================================
-- Procedure: SP_Student_GetCourseGrades
-- Description: Gets student's grades for all courses
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Student_GetCourseGrades
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.CourseID,
        c.CourseName,
        c.CourseCode,
        sc.FinalGrade,
        c.MaxDegree,
        c.MinDegree,
        sc.IsPassed,
        sc.EnrollmentDate,
        sc.CompletionDate
    FROM Academic.StudentCourse sc
    INNER JOIN Academic.Course c ON sc.CourseID = c.CourseID
    WHERE sc.StudentID = @StudentID
    ORDER BY sc.EnrollmentDate DESC;
END
GO

-- =============================================
-- Procedure: SP_Student_Deactivate
-- Description: Deactivates a student
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Student_Deactivate
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Academic.Student
    SET IsActive = 0,
        ModifiedDate = GETDATE()
    WHERE StudentID = @StudentID;
END
GO

PRINT 'Student procedures created successfully!';
GO
