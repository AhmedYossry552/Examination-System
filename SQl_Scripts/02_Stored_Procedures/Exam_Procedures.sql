/*=============================================
  Examination System - Exam Management Procedures
  Description: Procedures for exam creation and management
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Procedure: SP_Exam_Create
-- Description: Creates a new exam
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Exam_Create
    @InstructorID INT,
    @CourseID INT,
    @IntakeID INT,
    @BranchID INT,
    @TrackID INT,
    @ExamName NVARCHAR(200),
    @ExamYear INT,
    @ExamType NVARCHAR(20),
    @TotalMarks INT,
    @PassMarks INT,
    @DurationMinutes INT,
    @StartDateTime DATETIME2(3),
    @EndDateTime DATETIME2(3),
    @AllowanceOptions NVARCHAR(500) = NULL,
    @ExamID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify instructor teaches this course
        IF NOT EXISTS (
            SELECT 1 FROM Academic.CourseInstructor
            WHERE InstructorID = @InstructorID 
                AND CourseID = @CourseID 
                AND IntakeID = @IntakeID
                AND BranchID = @BranchID
                AND TrackID = @TrackID
                AND IsActive = 1
        )
        BEGIN
            RAISERROR('Instructor does not teach this course for specified intake/branch/track.', 16, 1);
            RETURN -1;
        END
        
        -- Validate total marks against course max degree
        DECLARE @MaxDegree INT;
        SELECT @MaxDegree = MaxDegree
        FROM Academic.Course
        WHERE CourseID = @CourseID;
        
        IF @TotalMarks > @MaxDegree
        BEGIN
            RAISERROR('Total marks cannot exceed course maximum degree.', 16, 1);
            RETURN -1;
        END
        
        -- Insert exam
        INSERT INTO Exam.Exam (
            CourseID, InstructorID, IntakeID, BranchID, TrackID,
            ExamName, ExamYear, ExamType, TotalMarks, PassMarks,
            DurationMinutes, StartDateTime, EndDateTime, AllowanceOptions, IsActive
        )
        VALUES (
            @CourseID, @InstructorID, @IntakeID, @BranchID, @TrackID,
            @ExamName, @ExamYear, @ExamType, @TotalMarks, @PassMarks,
            @DurationMinutes, @StartDateTime, @EndDateTime, @AllowanceOptions, 1
        );
        
        SET @ExamID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Exam created successfully with ID: ' + CAST(@ExamID AS NVARCHAR(10));
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
-- Procedure: SP_Exam_AddQuestion
-- Description: Adds a question to an exam
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Exam_AddQuestion
    @ExamID INT,
    @QuestionID INT,
    @QuestionOrder INT,
    @QuestionMarks INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify question belongs to same course as exam
        IF NOT EXISTS (
            SELECT 1 FROM Exam.Exam e
            INNER JOIN Exam.Question q ON e.CourseID = q.CourseID
            WHERE e.ExamID = @ExamID AND q.QuestionID = @QuestionID
        )
        BEGIN
            RAISERROR('Question does not belong to the same course as exam.', 16, 1);
            RETURN -1;
        END
        
        -- Check if question already added
        IF EXISTS (
            SELECT 1 FROM Exam.ExamQuestion
            WHERE ExamID = @ExamID AND QuestionID = @QuestionID
        )
        BEGIN
            RAISERROR('Question already added to this exam.', 16, 1);
            RETURN -1;
        END
        
        -- Calculate current total marks
        DECLARE @CurrentTotal INT;
        DECLARE @ExamTotalMarks INT;
        
        SELECT @ExamTotalMarks = TotalMarks
        FROM Exam.Exam
        WHERE ExamID = @ExamID;
        
        SELECT @CurrentTotal = ISNULL(SUM(QuestionMarks), 0)
        FROM Exam.ExamQuestion
        WHERE ExamID = @ExamID;
        
        -- Validate marks don't exceed exam total
        IF (@CurrentTotal + @QuestionMarks) > @ExamTotalMarks
        BEGIN
            RAISERROR('Adding this question would exceed exam total marks.', 16, 1);
            RETURN -1;
        END
        
        -- Add question to exam
        INSERT INTO Exam.ExamQuestion (ExamID, QuestionID, QuestionOrder, QuestionMarks)
        VALUES (@ExamID, @QuestionID, @QuestionOrder, @QuestionMarks);
        
        COMMIT TRANSACTION;
        
        PRINT 'Question added to exam successfully.';
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
-- Procedure: SP_Exam_GenerateRandom
-- Description: Generates exam with random questions
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Exam_GenerateRandom
    @ExamID INT,
    @MultipleChoiceCount INT = 0,
    @TrueFalseCount INT = 0,
    @TextCount INT = 0,
    @MarksPerMC INT = 2,
    @MarksPerTF INT = 1,
    @MarksPerText INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @CourseID INT;
        DECLARE @QuestionOrder INT = 1;
        
        -- Get course ID
        SELECT @CourseID = CourseID
        FROM Exam.Exam
        WHERE ExamID = @ExamID;
        
        -- Add Multiple Choice questions
        IF @MultipleChoiceCount > 0
        BEGIN
            INSERT INTO Exam.ExamQuestion (ExamID, QuestionID, QuestionOrder, QuestionMarks)
            SELECT TOP (@MultipleChoiceCount)
                @ExamID,
                QuestionID,
                ROW_NUMBER() OVER (ORDER BY NEWID()),
                @MarksPerMC
            FROM Exam.Question
            WHERE CourseID = @CourseID 
                AND QuestionType = 'MultipleChoice'
                AND IsActive = 1
                AND QuestionID NOT IN (
                    SELECT QuestionID FROM Exam.ExamQuestion WHERE ExamID = @ExamID
                )
            ORDER BY NEWID();
            
            SET @QuestionOrder = @QuestionOrder + @MultipleChoiceCount;
        END
        
        -- Add True/False questions
        IF @TrueFalseCount > 0
        BEGIN
            INSERT INTO Exam.ExamQuestion (ExamID, QuestionID, QuestionOrder, QuestionMarks)
            SELECT TOP (@TrueFalseCount)
                @ExamID,
                QuestionID,
                @QuestionOrder + ROW_NUMBER() OVER (ORDER BY NEWID()),
                @MarksPerTF
            FROM Exam.Question
            WHERE CourseID = @CourseID 
                AND QuestionType = 'TrueFalse'
                AND IsActive = 1
                AND QuestionID NOT IN (
                    SELECT QuestionID FROM Exam.ExamQuestion WHERE ExamID = @ExamID
                )
            ORDER BY NEWID();
            
            SET @QuestionOrder = @QuestionOrder + @TrueFalseCount;
        END
        
        -- Add Text questions
        IF @TextCount > 0
        BEGIN
            INSERT INTO Exam.ExamQuestion (ExamID, QuestionID, QuestionOrder, QuestionMarks)
            SELECT TOP (@TextCount)
                @ExamID,
                QuestionID,
                @QuestionOrder + ROW_NUMBER() OVER (ORDER BY NEWID()),
                @MarksPerText
            FROM Exam.Question
            WHERE CourseID = @CourseID 
                AND QuestionType = 'Text'
                AND IsActive = 1
                AND QuestionID NOT IN (
                    SELECT QuestionID FROM Exam.ExamQuestion WHERE ExamID = @ExamID
                )
            ORDER BY NEWID();
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Exam generated successfully with random questions.';
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
-- Procedure: SP_Exam_AssignToStudents
-- Description: Assigns exam to specific students
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Exam_AssignToStudents
    @ExamID INT,
    @StudentIDs NVARCHAR(MAX) -- Comma-separated list
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parse student IDs and insert
        INSERT INTO Exam.StudentExam (StudentID, ExamID, IsAllowed)
        SELECT 
            CAST(value AS INT),
            @ExamID,
            1
        FROM STRING_SPLIT(@StudentIDs, ',')
        WHERE value NOT IN (
            SELECT CAST(StudentID AS NVARCHAR(10))
            FROM Exam.StudentExam
            WHERE ExamID = @ExamID
        );
        
        COMMIT TRANSACTION;
        
        PRINT 'Exam assigned to students successfully.';
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
-- Procedure: SP_Exam_AssignToAllCourseStudents
-- Description: Assigns exam to all students enrolled in course
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Exam_AssignToAllCourseStudents
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @CourseID INT;
        DECLARE @IntakeID INT;
        DECLARE @BranchID INT;
        DECLARE @TrackID INT;
        
        -- Get exam details
        SELECT @CourseID = CourseID, @IntakeID = IntakeID, 
               @BranchID = BranchID, @TrackID = TrackID
        FROM Exam.Exam
        WHERE ExamID = @ExamID;
        
        -- Assign to all matching students
        INSERT INTO Exam.StudentExam (StudentID, ExamID, IsAllowed)
        SELECT DISTINCT
            s.StudentID,
            @ExamID,
            1
        FROM Academic.Student s
        INNER JOIN Academic.StudentCourse sc ON s.StudentID = sc.StudentID
        WHERE sc.CourseID = @CourseID
            AND s.IntakeID = @IntakeID
            AND s.BranchID = @BranchID
            AND s.TrackID = @TrackID
            AND s.IsActive = 1
            AND s.StudentID NOT IN (
                SELECT StudentID FROM Exam.StudentExam WHERE ExamID = @ExamID
            );
        
        COMMIT TRANSACTION;
        
        PRINT 'Exam assigned to all course students successfully.';
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
-- Procedure: SP_Exam_GetQuestions
-- Description: Gets all questions for an exam
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Exam_GetQuestions
    @ExamID INT,
    @IncludeAnswers BIT = 0 -- For instructor view
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        eq.ExamQuestionID,
        eq.QuestionOrder,
        eq.QuestionMarks,
        q.QuestionID,
        q.QuestionText,
        q.QuestionType,
        q.DifficultyLevel
    FROM Exam.ExamQuestion eq
    INNER JOIN Exam.Question q ON eq.QuestionID = q.QuestionID
    WHERE eq.ExamID = @ExamID
    ORDER BY eq.QuestionOrder;
    
    -- Get options for multiple choice questions
    IF @IncludeAnswers = 0
    BEGIN
        -- Student view - don't show correct answers
        SELECT 
            qo.OptionID,
            qo.QuestionID,
            qo.OptionText,
            qo.OptionOrder
        FROM Exam.QuestionOption qo
        WHERE qo.QuestionID IN (
            SELECT QuestionID FROM Exam.ExamQuestion WHERE ExamID = @ExamID
        )
        ORDER BY qo.QuestionID, qo.OptionOrder;
    END
    ELSE
    BEGIN
        -- Instructor view - show correct answers
        SELECT 
            qo.OptionID,
            qo.QuestionID,
            qo.OptionText,
            qo.IsCorrect,
            qo.OptionOrder
        FROM Exam.QuestionOption qo
        WHERE qo.QuestionID IN (
            SELECT QuestionID FROM Exam.ExamQuestion WHERE ExamID = @ExamID
        )
        ORDER BY qo.QuestionID, qo.OptionOrder;
        
        -- Get correct answers for TrueFalse and Text
        SELECT 
            qa.QuestionID,
            qa.CorrectAnswer,
            qa.AnswerPattern
        FROM Exam.QuestionAnswer qa
        WHERE qa.QuestionID IN (
            SELECT QuestionID FROM Exam.ExamQuestion WHERE ExamID = @ExamID
        );
    END
END
GO

-- =============================================
-- Procedure: SP_Exam_Update
-- Description: Updates exam details
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Exam_Update
    @InstructorID INT,
    @ExamID INT,
    @ExamName NVARCHAR(200) = NULL,
    @DurationMinutes INT = NULL,
    @StartDateTime DATETIME2(3) = NULL,
    @EndDateTime DATETIME2(3) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify instructor owns this exam
        IF NOT EXISTS (
            SELECT 1 FROM Exam.Exam 
            WHERE ExamID = @ExamID AND InstructorID = @InstructorID
        )
        BEGIN
            RAISERROR('You are not authorized to update this exam.', 16, 1);
            RETURN -1;
        END
        
        -- Update exam
        UPDATE Exam.Exam
        SET 
            ExamName = COALESCE(@ExamName, ExamName),
            DurationMinutes = COALESCE(@DurationMinutes, DurationMinutes),
            StartDateTime = COALESCE(@StartDateTime, StartDateTime),
            EndDateTime = COALESCE(@EndDateTime, EndDateTime),
            IsActive = COALESCE(@IsActive, IsActive),
            ModifiedDate = GETDATE()
        WHERE ExamID = @ExamID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Exam updated successfully.';
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
-- Procedure: SP_Exam_Delete
-- Description: Soft deletes an exam
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Exam_Delete
    @InstructorID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify instructor owns this exam
        IF NOT EXISTS (
            SELECT 1 FROM Exam.Exam 
            WHERE ExamID = @ExamID AND InstructorID = @InstructorID
        )
        BEGIN
            RAISERROR('You are not authorized to delete this exam.', 16, 1);
            RETURN -1;
        END
        
        -- Check if any student has started the exam
        IF EXISTS (
            SELECT 1 FROM Exam.StudentExam 
            WHERE ExamID = @ExamID AND StartTime IS NOT NULL
        )
        BEGIN
            RAISERROR('Cannot delete exam. Students have already started it.', 16, 1);
            RETURN -1;
        END
        
        -- Soft delete
        UPDATE Exam.Exam
        SET IsActive = 0, ModifiedDate = GETDATE()
        WHERE ExamID = @ExamID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Exam deleted successfully.';
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

PRINT 'Exam procedures created successfully!';
GO
