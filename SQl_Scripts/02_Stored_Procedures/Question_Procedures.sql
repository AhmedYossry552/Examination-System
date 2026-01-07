/*=============================================
  Examination System - Question Management Procedures
  Description: Procedures for question pool management
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Procedure: SP_Question_Add
-- Description: Adds a new question to the pool
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Question_Add
    @InstructorID INT,
    @CourseID INT,
    @QuestionText NVARCHAR(MAX),
    @QuestionType NVARCHAR(20),
    @DifficultyLevel NVARCHAR(20) = 'Medium',
    @Points INT = 1,
    @QuestionID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify instructor teaches this course
        IF NOT EXISTS (
            SELECT 1 FROM Academic.CourseInstructor
            WHERE InstructorID = @InstructorID AND CourseID = @CourseID AND IsActive = 1
        )
        BEGIN
            RAISERROR('Instructor does not teach this course.', 16, 1);
            RETURN -1;
        END
        
        -- Validate question type
        IF @QuestionType NOT IN ('MultipleChoice', 'TrueFalse', 'Text')
        BEGIN
            RAISERROR('Invalid question type.', 16, 1);
            RETURN -1;
        END
        
        -- Insert question
        INSERT INTO Exam.Question (
            CourseID, InstructorID, QuestionText, QuestionType, 
            DifficultyLevel, Points, IsActive
        )
        VALUES (
            @CourseID, @InstructorID, @QuestionText, @QuestionType,
            @DifficultyLevel, @Points, 1
        );
        
        SET @QuestionID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Question added successfully with ID: ' + CAST(@QuestionID AS NVARCHAR(10));
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
-- Procedure: SP_Question_AddOption
-- Description: Adds an option to a multiple choice question
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Question_AddOption
    @QuestionID INT,
    @OptionText NVARCHAR(500),
    @IsCorrect BIT,
    @OptionOrder INT,
    @OptionID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify question is multiple choice
        DECLARE @QuestionType NVARCHAR(20);
        SELECT @QuestionType = QuestionType
        FROM Exam.Question
        WHERE QuestionID = @QuestionID;
        
        IF @QuestionType != 'MultipleChoice'
        BEGIN
            RAISERROR('Question must be of type MultipleChoice.', 16, 1);
            RETURN -1;
        END
        
        -- If marking as correct, unmark other options
        IF @IsCorrect = 1
        BEGIN
            UPDATE Exam.QuestionOption
            SET IsCorrect = 0
            WHERE QuestionID = @QuestionID;
        END
        
        -- Insert option
        INSERT INTO Exam.QuestionOption (QuestionID, OptionText, IsCorrect, OptionOrder)
        VALUES (@QuestionID, @OptionText, @IsCorrect, @OptionOrder);

        -- Return newly created OptionID
        SET @OptionID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Option added successfully.';
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
-- Procedure: SP_Question_AddAnswer
-- Description: Adds correct answer for TrueFalse or Text question
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Question_AddAnswer
    @QuestionID INT,
    @CorrectAnswer NVARCHAR(MAX),
    @AnswerPattern NVARCHAR(500) = NULL,
    @CaseSensitive BIT = 0,
    @AnswerID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify question type
        DECLARE @QuestionType NVARCHAR(20);
        SELECT @QuestionType = QuestionType
        FROM Exam.Question
        WHERE QuestionID = @QuestionID;
        
        IF @QuestionType NOT IN ('TrueFalse', 'Text')
        BEGIN
            RAISERROR('Question must be of type TrueFalse or Text.', 16, 1);
            RETURN -1;
        END
        
        -- Insert or update answer
        IF EXISTS (SELECT 1 FROM Exam.QuestionAnswer WHERE QuestionID = @QuestionID)
        BEGIN
            UPDATE Exam.QuestionAnswer
            SET 
                CorrectAnswer = @CorrectAnswer,
                AnswerPattern = @AnswerPattern,
                CaseSensitive = @CaseSensitive
            WHERE QuestionID = @QuestionID;

            -- Return existing AnswerID
            SELECT @AnswerID = AnswerID FROM Exam.QuestionAnswer WHERE QuestionID = @QuestionID;
        END
        ELSE
        BEGIN
            INSERT INTO Exam.QuestionAnswer (QuestionID, CorrectAnswer, AnswerPattern, CaseSensitive)
            VALUES (@QuestionID, @CorrectAnswer, @AnswerPattern, @CaseSensitive);

            -- Return newly created AnswerID
            SET @AnswerID = SCOPE_IDENTITY();
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Answer added successfully.';
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
-- Procedure: SP_Question_Update
-- Description: Updates a question
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Question_Update
    @InstructorID INT,
    @QuestionID INT,
    @QuestionText NVARCHAR(MAX) = NULL,
    @DifficultyLevel NVARCHAR(20) = NULL,
    @Points INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify instructor owns this question or teaches the course
        IF NOT EXISTS (
            SELECT 1 FROM Exam.Question q
            INNER JOIN Academic.CourseInstructor ci ON q.CourseID = ci.CourseID
            WHERE q.QuestionID = @QuestionID 
                AND ci.InstructorID = @InstructorID 
                AND ci.IsActive = 1
        )
        BEGIN
            RAISERROR('You are not authorized to update this question.', 16, 1);
            RETURN -1;
        END
        
        -- Update question
        UPDATE Exam.Question
        SET 
            QuestionText = COALESCE(@QuestionText, QuestionText),
            DifficultyLevel = COALESCE(@DifficultyLevel, DifficultyLevel),
            Points = COALESCE(@Points, Points),
            ModifiedDate = GETDATE()
        WHERE QuestionID = @QuestionID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Question updated successfully.';
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
-- Procedure: SP_Question_Delete
-- Description: Soft deletes a question
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Question_Delete
    @InstructorID INT,
    @QuestionID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify instructor owns this question
        IF NOT EXISTS (
            SELECT 1 FROM Exam.Question q
            INNER JOIN Academic.CourseInstructor ci ON q.CourseID = ci.CourseID
            WHERE q.QuestionID = @QuestionID 
                AND ci.InstructorID = @InstructorID 
                AND ci.IsActive = 1
        )
        BEGIN
            RAISERROR('You are not authorized to delete this question.', 16, 1);
            RETURN -1;
        END
        
        -- Check if question is used in any active exam
        IF EXISTS (
            SELECT 1 FROM Exam.ExamQuestion eq
            INNER JOIN Exam.Exam e ON eq.ExamID = e.ExamID
            WHERE eq.QuestionID = @QuestionID AND e.IsActive = 1
        )
        BEGIN
            RAISERROR('Cannot delete question. It is used in active exams.', 16, 1);
            RETURN -1;
        END
        
        -- Soft delete
        UPDATE Exam.Question
        SET IsActive = 0, ModifiedDate = GETDATE()
        WHERE QuestionID = @QuestionID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Question deleted successfully.';
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
-- Procedure: SP_Question_GetByCourse
-- Description: Gets all questions for a course
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Question_GetByCourse
    @CourseID INT,
    @QuestionType NVARCHAR(20) = NULL,
    @DifficultyLevel NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        q.QuestionID,
        q.QuestionText,
        q.QuestionType,
        q.DifficultyLevel,
        q.Points,
        q.CreatedDate,
        q.ModifiedDate,
        u.FirstName + ' ' + u.LastName AS CreatorName
    FROM Exam.Question q
    INNER JOIN Academic.Instructor i ON q.InstructorID = i.InstructorID
    INNER JOIN Security.[User] u ON i.UserID = u.UserID
    WHERE q.CourseID = @CourseID
        AND q.IsActive = 1
        AND (@QuestionType IS NULL OR q.QuestionType = @QuestionType)
        AND (@DifficultyLevel IS NULL OR q.DifficultyLevel = @DifficultyLevel)
    ORDER BY q.CreatedDate DESC;
END
GO

-- =============================================
-- Procedure: SP_Question_GetWithOptions
-- Description: Gets a question with all its options
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Question_GetWithOptions
    @QuestionID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get question
    SELECT 
        q.QuestionID,
        q.CourseID,
        c.CourseName,
        q.QuestionText,
        q.QuestionType,
        q.DifficultyLevel,
        q.Points,
        q.CreatedDate
    FROM Exam.Question q
    INNER JOIN Academic.Course c ON q.CourseID = c.CourseID
    WHERE q.QuestionID = @QuestionID;
    
    -- Always return options (empty set if not MultipleChoice)
    SELECT 
        OptionID,
        QuestionID,
        OptionText,
        IsCorrect,
        OptionOrder
    FROM Exam.QuestionOption
    WHERE QuestionID = @QuestionID
    ORDER BY OptionOrder;

    -- Always return answer (empty set if none or not TrueFalse/Text)
    SELECT 
        AnswerID,
        QuestionID,
        CorrectAnswer,
        AnswerPattern,
        CaseSensitive
    FROM Exam.QuestionAnswer
    WHERE QuestionID = @QuestionID;
END
GO

-- =============================================
-- Procedure: SP_Question_GetRandomByType
-- Description: Gets random questions for exam generation
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Question_GetRandomByType
    @CourseID INT,
    @QuestionType NVARCHAR(20),
    @Count INT,
    @DifficultyLevel NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@Count)
        QuestionID,
        QuestionText,
        QuestionType,
        DifficultyLevel,
        Points
    FROM Exam.Question
    WHERE CourseID = @CourseID
        AND QuestionType = @QuestionType
        AND IsActive = 1
        AND (@DifficultyLevel IS NULL OR DifficultyLevel = @DifficultyLevel)
    ORDER BY NEWID(); -- Random selection
END
GO

-- =============================================
-- Procedure: SP_Question_GetStatistics
-- Description: Gets statistics for question pool
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Question_GetStatistics
    @CourseID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalQuestions,
        SUM(CASE WHEN QuestionType = 'MultipleChoice' THEN 1 ELSE 0 END) AS MultipleChoiceCount,
        SUM(CASE WHEN QuestionType = 'TrueFalse' THEN 1 ELSE 0 END) AS TrueFalseCount,
        SUM(CASE WHEN QuestionType = 'Text' THEN 1 ELSE 0 END) AS TextCount,
        SUM(CASE WHEN DifficultyLevel = 'Easy' THEN 1 ELSE 0 END) AS EasyCount,
        SUM(CASE WHEN DifficultyLevel = 'Medium' THEN 1 ELSE 0 END) AS MediumCount,
        SUM(CASE WHEN DifficultyLevel = 'Hard' THEN 1 ELSE 0 END) AS HardCount,
        AVG(CAST(Points AS FLOAT)) AS AveragePoints
    FROM Exam.Question
    WHERE CourseID = @CourseID
        AND IsActive = 1;
END
GO

PRINT 'Question procedures created successfully!';
GO
