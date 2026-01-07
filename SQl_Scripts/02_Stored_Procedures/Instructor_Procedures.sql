/*=============================================
  Examination System - Instructor Procedures
  Description: Procedures for instructor operations
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Procedure: SP_Instructor_Add
-- Description: Adds a new instructor
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Instructor_Add
    @UserID INT,
    @Specialization NVARCHAR(100) = NULL,
    @HireDate DATE = NULL,
    @Salary DECIMAL(10,2) = NULL,
    @IsTrainingManager BIT = 0,
    @InstructorID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate user exists and is an instructor
        IF NOT EXISTS (
            SELECT 1 FROM Security.[User] 
            WHERE UserID = @UserID AND UserType IN ('Instructor', 'TrainingManager')
        )
        BEGIN
            RAISERROR('User must be of type Instructor or TrainingManager.', 16, 1);
            RETURN -1;
        END
        
        -- Check if user already has instructor record
        IF EXISTS (SELECT 1 FROM Academic.Instructor WHERE UserID = @UserID)
        BEGIN
            RAISERROR('Instructor record already exists for this user.', 16, 1);
            RETURN -1;
        END
        
        -- Set default hire date
        IF @HireDate IS NULL
            SET @HireDate = GETDATE();
        
        -- Insert instructor
        INSERT INTO Academic.Instructor (UserID, Specialization, HireDate, Salary, IsTrainingManager, IsActive)
        VALUES (@UserID, @Specialization, @HireDate, @Salary, @IsTrainingManager, 1);
        
        SET @InstructorID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Instructor added successfully with ID: ' + CAST(@InstructorID AS NVARCHAR(10));
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
-- Procedure: SP_Instructor_AssignToCourse
-- Description: Assigns instructor to a course
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Instructor_AssignToCourse
    @InstructorID INT,
    @CourseID INT,
    @IntakeID INT,
    @BranchID INT,
    @TrackID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if already assigned
        IF EXISTS (
            SELECT 1 FROM Academic.CourseInstructor
            WHERE InstructorID = @InstructorID 
                AND CourseID = @CourseID
                AND IntakeID = @IntakeID
                AND BranchID = @BranchID
                AND TrackID = @TrackID
                AND IsActive = 1
        )
        BEGIN
            RAISERROR('Instructor is already assigned to this course for this intake/branch/track.', 16, 1);
            RETURN -1;
        END
        
        -- Assign instructor
        INSERT INTO Academic.CourseInstructor (InstructorID, CourseID, IntakeID, BranchID, TrackID, IsActive)
        VALUES (@InstructorID, @CourseID, @IntakeID, @BranchID, @TrackID, 1);
        
        COMMIT TRANSACTION;
        
        PRINT 'Instructor assigned successfully.';
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
-- Procedure: SP_Instructor_GetMyCourses
-- Description: Gets all courses assigned to an instructor
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Instructor_GetMyCourses
    @InstructorID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT DISTINCT
        c.CourseID,
        c.CourseName,
        c.CourseCode,
        c.CourseDescription,
        c.MaxDegree,
        c.MinDegree,
        c.TotalHours,
        ci.IntakeID,
        i.IntakeName,
        ci.BranchID,
        b.BranchName,
        ci.TrackID,
        t.TrackName,
        ci.AssignedDate
    FROM Academic.CourseInstructor ci
    INNER JOIN Academic.Course c ON ci.CourseID = c.CourseID
    INNER JOIN Academic.Intake i ON ci.IntakeID = i.IntakeID
    INNER JOIN Academic.Branch b ON ci.BranchID = b.BranchID
    INNER JOIN Academic.Track t ON ci.TrackID = t.TrackID
    WHERE ci.InstructorID = @InstructorID
        AND ci.IsActive = 1
        AND c.IsActive = 1
    ORDER BY c.CourseName;
END
GO

-- =============================================
-- Procedure: SP_Instructor_GetCourseStudents
-- Description: Gets all students enrolled in a course
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Instructor_GetCourseStudents
    @InstructorID INT,
    @CourseID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verify instructor teaches this course
    IF NOT EXISTS (
        SELECT 1 FROM Academic.CourseInstructor
        WHERE InstructorID = @InstructorID AND CourseID = @CourseID AND IsActive = 1
    )
    BEGIN
        RAISERROR('Instructor does not teach this course.', 16, 1);
        RETURN -1;
    END
    
    SELECT 
        s.StudentID,
        u.Username,
        u.FirstName,
        u.LastName,
        u.Email,
        sc.EnrollmentDate,
        sc.FinalGrade,
        sc.IsPassed,
        b.BranchName,
        t.TrackName,
        i.IntakeName
    FROM Academic.StudentCourse sc
    INNER JOIN Academic.Student s ON sc.StudentID = s.StudentID
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    INNER JOIN Academic.Branch b ON s.BranchID = b.BranchID
    INNER JOIN Academic.Track t ON s.TrackID = t.TrackID
    INNER JOIN Academic.Intake i ON s.IntakeID = i.IntakeID
    WHERE sc.CourseID = @CourseID
        AND s.IsActive = 1
    ORDER BY u.LastName, u.FirstName;
END
GO

-- =============================================
-- Procedure: SP_Instructor_GetExamsToGrade
-- Description: Gets list of exams that need manual grading
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Instructor_GetExamsToGrade
    @InstructorID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT DISTINCT
        se.StudentExamID,
        s.StudentID,
        u.FirstName + ' ' + u.LastName AS StudentName,
        e.ExamID,
        e.ExamName,
        c.CourseName,
        se.SubmissionTime,
        se.TotalScore,
        COUNT(sa.StudentAnswerID) AS QuestionsNeedingGrading
    FROM Exam.StudentExam se
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    INNER JOIN Exam.StudentAnswer sa ON se.StudentExamID = sa.StudentExamID
    WHERE e.InstructorID = @InstructorID
        AND sa.NeedsManualGrading = 1
        AND sa.MarksObtained IS NULL
    GROUP BY 
        se.StudentExamID, s.StudentID, u.FirstName, u.LastName,
        e.ExamID, e.ExamName, c.CourseName, se.SubmissionTime, se.TotalScore
    ORDER BY se.SubmissionTime DESC;
END
GO

-- =============================================
-- Procedure: SP_Instructor_GradeTextAnswer
-- Description: Manually grades a text answer
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Instructor_GradeTextAnswer
    @InstructorID INT,
    @StudentAnswerID INT,
    @MarksObtained DECIMAL(5,2),
    @InstructorComments NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @ExamID INT;
        DECLARE @QuestionMarks INT;
        DECLARE @QuestionID INT;
        DECLARE @StudentExamID INT;
        
        -- Get answer details
        SELECT @StudentExamID = StudentExamID, @QuestionID = QuestionID
        FROM Exam.StudentAnswer
        WHERE StudentAnswerID = @StudentAnswerID;
        
        -- Get exam and verify instructor
        SELECT @ExamID = e.ExamID, @QuestionMarks = eq.QuestionMarks
        FROM Exam.StudentExam se
        INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
        INNER JOIN Exam.ExamQuestion eq ON e.ExamID = eq.ExamID AND eq.QuestionID = @QuestionID
        WHERE se.StudentExamID = @StudentExamID;
        
        IF NOT EXISTS (
            SELECT 1 FROM Exam.Exam WHERE ExamID = @ExamID AND InstructorID = @InstructorID
        )
        BEGIN
            RAISERROR('You are not authorized to grade this exam.', 16, 1);
            RETURN -1;
        END
        
        -- Validate marks
        IF @MarksObtained < 0 OR @MarksObtained > @QuestionMarks
        BEGIN
            RAISERROR('Marks obtained cannot exceed question marks.', 16, 1);
            RETURN -1;
        END
        
        -- Update answer
        UPDATE Exam.StudentAnswer
        SET 
            MarksObtained = @MarksObtained,
            IsCorrect = CASE WHEN @MarksObtained > 0 THEN 1 ELSE 0 END,
            NeedsManualGrading = 0,
            InstructorComments = @InstructorComments,
            GradedDate = GETDATE()
        WHERE StudentAnswerID = @StudentAnswerID;
        
        -- Recalculate total score
        DECLARE @TotalScore DECIMAL(5,2);
        DECLARE @PassMarks INT;
        
        SELECT @TotalScore = ISNULL(SUM(MarksObtained), 0)
        FROM Exam.StudentAnswer
        WHERE StudentExamID = @StudentExamID;
        
        SELECT @PassMarks = PassMarks
        FROM Exam.Exam
        WHERE ExamID = @ExamID;
        
        -- Update student exam
        UPDATE Exam.StudentExam
        SET 
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
        
        PRINT 'Answer graded successfully.';
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
-- Procedure: SP_Instructor_GetExamStatistics
-- Description: Gets statistics for an exam
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Instructor_GetExamStatistics
    @InstructorID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verify instructor owns this exam
    IF NOT EXISTS (
        SELECT 1 FROM Exam.Exam WHERE ExamID = @ExamID AND InstructorID = @InstructorID
    )
    BEGIN
        RAISERROR('You are not authorized to view this exam.', 16, 1);
        RETURN -1;
    END
    
    SELECT 
        COUNT(*) AS TotalStudents,
        SUM(CASE WHEN SubmissionTime IS NOT NULL THEN 1 ELSE 0 END) AS StudentsCompleted,
        SUM(CASE WHEN IsPassed = 1 THEN 1 ELSE 0 END) AS StudentsPassed,
        SUM(CASE WHEN IsPassed = 0 THEN 1 ELSE 0 END) AS StudentsFailed,
        AVG(TotalScore) AS AverageScore,
        MAX(TotalScore) AS HighestScore,
        MIN(TotalScore) AS LowestScore,
        SUM(CASE WHEN IsGraded = 0 THEN 1 ELSE 0 END) AS PendingGrading
    FROM Exam.StudentExam
    WHERE ExamID = @ExamID
        AND SubmissionTime IS NOT NULL;
END
GO

-- =============================================
-- Procedure: SP_Instructor_UpdateCourseFinalGrades
-- Description: Updates final grades for students in a course
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Instructor_UpdateCourseFinalGrades
    @InstructorID INT,
    @CourseID INT
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
        
        -- Update final grades based on exam scores
        UPDATE sc
        SET 
            FinalGrade = ISNULL(examScores.TotalScore, 0),
            IsPassed = CASE 
                WHEN ISNULL(examScores.TotalScore, 0) >= c.MinDegree THEN 1 
                ELSE 0 
            END,
            CompletionDate = GETDATE(),
            ModifiedDate = GETDATE()
        FROM Academic.StudentCourse sc
        INNER JOIN Academic.Course c ON sc.CourseID = c.CourseID
        LEFT JOIN (
            SELECT 
                s.StudentID,
                e.CourseID,
                SUM(se.TotalScore) AS TotalScore
            FROM Exam.StudentExam se
            INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
            INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
            WHERE se.IsGraded = 1
            GROUP BY s.StudentID, e.CourseID
        ) examScores ON sc.StudentID = examScores.StudentID AND sc.CourseID = examScores.CourseID
        WHERE sc.CourseID = @CourseID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Final grades updated successfully.';
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
-- Procedure: SP_Instructor_GetTextAnswersAnalysis (BONUS FEATURE)
-- Description: Advanced analysis of text answers with similarity scoring
-- Shows instructor valid/invalid answers with AI-like suggestions
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_Instructor_GetTextAnswersAnalysis
    @InstructorID INT,
    @ExamID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verify instructor authorization
    IF @ExamID IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM Exam.Exam WHERE ExamID = @ExamID AND InstructorID = @InstructorID
    )
    BEGIN
        RAISERROR('You are not authorized to view this exam.', 16, 1);
        RETURN -1;
    END
    
    -- Get text answers with advanced analysis
    SELECT 
        -- Student Info
        sa.StudentAnswerID,
        s.StudentID,
        u.FirstName + ' ' + u.LastName AS StudentName,
        
        -- Exam Info
        e.ExamID,
        e.ExamName,
        c.CourseName,
        
        -- Question Info
        q.QuestionID,
        q.QuestionText,
        eq.QuestionMarks AS MaxMarks,
        
        -- Answer Info
        sa.StudentAnswerText,
        qa.CorrectAnswer AS ModelAnswer,
        qa.AnswerPattern AS RegexPattern,
        
        -- Basic Similarity Analysis (Simplified)
        CASE 
            WHEN LOWER(sa.StudentAnswerText) LIKE '%' + LOWER(qa.CorrectAnswer) + '%' THEN 90.0
            WHEN LOWER(qa.CorrectAnswer) LIKE '%' + LOWER(sa.StudentAnswerText) + '%' THEN 85.0
            WHEN LEN(sa.StudentAnswerText) > LEN(qa.CorrectAnswer) * 0.5 THEN 60.0
            ELSE 30.0
        END AS SimilarityScore,
        
        -- Intelligent Recommendation
        CASE 
            WHEN LOWER(sa.StudentAnswerText) LIKE '%' + LOWER(qa.CorrectAnswer) + '%' 
                THEN 'ACCEPT - High Match'
            WHEN LOWER(qa.CorrectAnswer) LIKE '%' + LOWER(sa.StudentAnswerText) + '%' 
                THEN 'REVIEW - Good Match'
            WHEN LEN(sa.StudentAnswerText) > LEN(qa.CorrectAnswer) * 0.5 
                THEN 'REVIEW - Partial Match'
            ELSE 'REJECT - Low Match'
        END AS Recommendation,
        
        -- Suggested Marks based on similarity
        CAST(
            CASE 
                WHEN LOWER(sa.StudentAnswerText) LIKE '%' + LOWER(qa.CorrectAnswer) + '%' THEN eq.QuestionMarks * 0.9
                WHEN LOWER(qa.CorrectAnswer) LIKE '%' + LOWER(sa.StudentAnswerText) + '%' THEN eq.QuestionMarks * 0.85
                WHEN LEN(sa.StudentAnswerText) > LEN(qa.CorrectAnswer) * 0.5 THEN eq.QuestionMarks * 0.6
                ELSE eq.QuestionMarks * 0.3
            END
        AS DECIMAL(5,2)) AS SuggestedMarks,
        
        -- Current Status
        sa.MarksObtained AS CurrentMarks,
        sa.IsCorrect,
        sa.NeedsManualGrading,
        sa.InstructorComments,
        sa.AnsweredDate,
        sa.GradedDate,
        
        -- Analysis Details
        LEN(sa.StudentAnswerText) AS StudentAnswerLength,
        LEN(qa.CorrectAnswer) AS ModelAnswerLength,
        ABS(LEN(sa.StudentAnswerText) - LEN(qa.CorrectAnswer)) AS LengthDifference,
        
        -- Keyword Analysis
        (
            SELECT COUNT(*)
            FROM STRING_SPLIT(qa.CorrectAnswer, ' ') kw
            WHERE LEN(TRIM(kw.value)) > 3 
                AND LOWER(sa.StudentAnswerText) LIKE '%' + LOWER(TRIM(kw.value)) + '%'
        ) AS KeywordsMatched,
        
        (
            SELECT COUNT(*)
            FROM STRING_SPLIT(qa.CorrectAnswer, ' ')
            WHERE LEN(TRIM(value)) > 3
        ) AS TotalKeywords,
        
        -- Grading Priority (urgent first)
        CASE 
            WHEN sa.MarksObtained IS NULL AND sa.NeedsManualGrading = 1 
            THEN DATEDIFF(HOUR, sa.AnsweredDate, GETDATE())
            ELSE 0
        END AS HoursPendingGrading

    FROM Exam.StudentAnswer sa
    INNER JOIN Exam.StudentExam se ON sa.StudentExamID = se.StudentExamID
    INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    INNER JOIN Exam.Question q ON sa.QuestionID = q.QuestionID
    INNER JOIN Exam.ExamQuestion eq ON e.ExamID = eq.ExamID AND q.QuestionID = eq.QuestionID
    LEFT JOIN Exam.QuestionAnswer qa ON q.QuestionID = qa.QuestionID
    
    WHERE e.InstructorID = @InstructorID
        AND q.QuestionType = 'Text'
        AND (@ExamID IS NULL OR e.ExamID = @ExamID)
        AND sa.NeedsManualGrading = 1
    
    ORDER BY 
        -- Priority: Pending grading first, then by waiting time
        CASE WHEN sa.MarksObtained IS NULL THEN 0 ELSE 1 END,
        sa.AnsweredDate ASC,
        CASE 
            WHEN LOWER(sa.StudentAnswerText) LIKE '%' + LOWER(qa.CorrectAnswer) + '%' THEN 90.0
            WHEN LOWER(qa.CorrectAnswer) LIKE '%' + LOWER(sa.StudentAnswerText) + '%' THEN 85.0
            WHEN LEN(sa.StudentAnswerText) > LEN(qa.CorrectAnswer) * 0.5 THEN 60.0
            ELSE 30.0
        END DESC;
    
    -- Summary Statistics
    SELECT 
        'Text Answers Summary' AS ReportType,
        COUNT(*) AS TotalTextAnswers,
        SUM(CASE WHEN sa.MarksObtained IS NULL THEN 1 ELSE 0 END) AS PendingGrading,
        SUM(CASE WHEN sa.MarksObtained IS NOT NULL THEN 1 ELSE 0 END) AS Graded,
        SUM(CASE WHEN LOWER(sa.StudentAnswerText) LIKE '%' + LOWER(qa.CorrectAnswer) + '%' THEN 1 ELSE 0 END) AS HighSimilarity,
        SUM(CASE WHEN LOWER(qa.CorrectAnswer) LIKE '%' + LOWER(sa.StudentAnswerText) + '%' THEN 1 ELSE 0 END) AS MediumSimilarity,
        SUM(CASE WHEN LEN(sa.StudentAnswerText) <= LEN(qa.CorrectAnswer) * 0.5 THEN 1 ELSE 0 END) AS LowSimilarity,
        AVG(CASE 
            WHEN LOWER(sa.StudentAnswerText) LIKE '%' + LOWER(qa.CorrectAnswer) + '%' THEN 90.0
            WHEN LOWER(qa.CorrectAnswer) LIKE '%' + LOWER(sa.StudentAnswerText) + '%' THEN 85.0
            WHEN LEN(sa.StudentAnswerText) > LEN(qa.CorrectAnswer) * 0.5 THEN 60.0
            ELSE 30.0
        END) AS AverageSimilarity
    FROM Exam.StudentAnswer sa
    INNER JOIN Exam.StudentExam se ON sa.StudentExamID = se.StudentExamID
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    INNER JOIN Exam.Question q ON sa.QuestionID = q.QuestionID
    LEFT JOIN Exam.QuestionAnswer qa ON q.QuestionID = qa.QuestionID
    WHERE e.InstructorID = @InstructorID
        AND q.QuestionType = 'Text'
        AND (@ExamID IS NULL OR e.ExamID = @ExamID);
END
GO

-- =============================================
-- Procedure: SP_Instructor_Update
-- Description: Updates instructor information
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Instructor_Update
    @InstructorID INT,
    @Specialization NVARCHAR(100) = NULL,
    @HireDate DATE = NULL,
    @Salary DECIMAL(10,2) = NULL,
    @IsTrainingManager BIT = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Academic.Instructor WHERE InstructorID = @InstructorID)
        BEGIN
            RAISERROR('Instructor not found.', 16, 1);
            RETURN -1;
        END

        UPDATE Academic.Instructor
        SET 
            Specialization = COALESCE(@Specialization, Specialization),
            HireDate = COALESCE(@HireDate, HireDate),
            Salary = COALESCE(@Salary, Salary),
            IsTrainingManager = COALESCE(@IsTrainingManager, IsTrainingManager),
            IsActive = COALESCE(@IsActive, IsActive),
            ModifiedDate = GETDATE()
        WHERE InstructorID = @InstructorID;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Instructor_Deactivate
-- Description: Deactivates an instructor
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Instructor_Deactivate
    @InstructorID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Academic.Instructor
    SET IsActive = 0,
        ModifiedDate = GETDATE()
    WHERE InstructorID = @InstructorID;
END
GO

PRINT 'Instructor procedures created successfully!';
GO
