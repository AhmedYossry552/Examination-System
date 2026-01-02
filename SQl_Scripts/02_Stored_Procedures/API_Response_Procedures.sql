/*=============================================
  Examination System - API Response Helpers
  Description: Standardized API responses and error handling
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Procedure: SP_API_GetStudentExamWithQuestions
-- Description: Returns complete exam data for student in one call (reduces API round trips)
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_API_GetStudentExamWithQuestions
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StudentExamID INT;
    DECLARE @IsAllowed BIT;
    DECLARE @StartTime DATETIME2(3);
    DECLARE @ExamStartDateTime DATETIME2(3);
    DECLARE @ExamEndDateTime DATETIME2(3);
    
    -- Get student exam info
    SELECT 
        @StudentExamID = StudentExamID,
        @IsAllowed = IsAllowed,
        @StartTime = StartTime
    FROM Exam.StudentExam
    WHERE StudentID = @StudentID AND ExamID = @ExamID;
    
    -- Get exam details
    SELECT 
        @ExamStartDateTime = StartDateTime,
        @ExamEndDateTime = EndDateTime
    FROM Exam.Exam
    WHERE ExamID = @ExamID;
    
    -- Return exam info
    SELECT 
        e.ExamID,
        e.ExamName,
        e.ExamType,
        c.CourseName,
        e.TotalMarks,
        e.DurationMinutes,
        e.StartDateTime,
        e.EndDateTime,
        se.StartTime,
        se.SubmissionTime,
        se.TotalScore,
        CASE 
            WHEN se.SubmissionTime IS NOT NULL THEN 'Completed'
            WHEN GETDATE() < e.StartDateTime THEN 'NotStarted'
            WHEN GETDATE() > e.EndDateTime THEN 'Expired'
            WHEN se.StartTime IS NULL THEN 'Ready'
            WHEN se.StartTime IS NOT NULL THEN 'InProgress'
        END AS ExamStatus,
        CASE 
            WHEN se.StartTime IS NOT NULL 
            THEN DATEDIFF(MINUTE, GETDATE(), DATEADD(MINUTE, e.DurationMinutes, se.StartTime))
            ELSE e.DurationMinutes
        END AS RemainingMinutes,
        se.IsAllowed,
        (SELECT COUNT(*) FROM Exam.ExamQuestion WHERE ExamID = e.ExamID) AS TotalQuestions
    FROM Exam.Exam e
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    LEFT JOIN Exam.StudentExam se ON e.ExamID = se.ExamID AND se.StudentID = @StudentID
    WHERE e.ExamID = @ExamID;
    
    -- Return questions (hide correct answers)
    SELECT 
        eq.QuestionOrder,
        q.QuestionID,
        q.QuestionText,
        q.QuestionType,
        eq.QuestionMarks,
        sa.StudentAnswerID,
        sa.StudentAnswerText,
        sa.SelectedOptionID,
        CASE WHEN sa.StudentAnswerID IS NOT NULL THEN 1 ELSE 0 END AS IsAnswered
    FROM Exam.ExamQuestion eq
    INNER JOIN Exam.Question q ON eq.QuestionID = q.QuestionID
    LEFT JOIN Exam.StudentAnswer sa ON q.QuestionID = sa.QuestionID 
        AND sa.StudentExamID = @StudentExamID
    WHERE eq.ExamID = @ExamID
    ORDER BY eq.QuestionOrder;
    
    -- Return options for multiple choice (without correct answer indicator)
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
GO

-- =============================================
-- Procedure: SP_API_GetExamResults
-- Description: Returns complete exam results with detailed breakdown
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_API_GetExamResults
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StudentExamID INT;
    SELECT TOP (1) @StudentExamID = StudentExamID 
    FROM Exam.StudentExam 
    WHERE StudentID = @StudentID AND ExamID = @ExamID
    ORDER BY SubmissionTime DESC, StartTime DESC, StudentExamID DESC;
    
    -- Exam summary
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
        DATEDIFF(MINUTE, se.StartTime, se.SubmissionTime) AS TimeTakenMinutes,
        Exam.FN_CalculateExamGrade(se.TotalScore, e.TotalMarks) AS Percentage,
        (SELECT COUNT(*) FROM Exam.StudentAnswer WHERE StudentExamID = @StudentExamID) AS TotalQuestions,
        (SELECT COUNT(*) FROM Exam.StudentAnswer WHERE StudentExamID = @StudentExamID AND IsCorrect = 1) AS CorrectAnswers,
        (SELECT COUNT(*) FROM Exam.StudentAnswer WHERE StudentExamID = @StudentExamID AND IsCorrect = 0) AS IncorrectAnswers,
        (SELECT COUNT(*) FROM Exam.StudentAnswer WHERE StudentExamID = @StudentExamID AND NeedsManualGrading = 1) AS PendingGrading
    FROM Exam.Exam e
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    INNER JOIN Exam.StudentExam se ON e.ExamID = se.ExamID
    WHERE se.StudentExamID = @StudentExamID;
    
    -- Question-by-question breakdown
    SELECT 
        q.QuestionID,
        eq.QuestionOrder,
        q.QuestionText,
        q.QuestionType,
        eq.QuestionMarks,
        sa.StudentAnswerText,
        sa.IsCorrect,
        sa.MarksObtained,
        sa.NeedsManualGrading,
        sa.InstructorComments,
        CASE q.QuestionType
            WHEN 'MultipleChoice' THEN (
                SELECT TOP (1) OptionText FROM Exam.QuestionOption 
                WHERE OptionID = sa.SelectedOptionID
            )
            ELSE NULL
        END AS SelectedOption,
        CASE q.QuestionType
            WHEN 'MultipleChoice' THEN (
                SELECT TOP (1) OptionText FROM Exam.QuestionOption 
                WHERE QuestionID = q.QuestionID AND IsCorrect = 1
                ORDER BY OptionID
            )
            WHEN 'TrueFalse' THEN (
                SELECT TOP (1) CorrectAnswer FROM Exam.QuestionAnswer 
                WHERE QuestionID = q.QuestionID
                ORDER BY QuestionID
            )
            ELSE NULL
        END AS CorrectAnswer
    FROM Exam.ExamQuestion eq
    INNER JOIN Exam.Question q ON eq.QuestionID = q.QuestionID
    LEFT JOIN Exam.StudentAnswer sa ON q.QuestionID = sa.QuestionID 
        AND sa.StudentExamID = @StudentExamID
    WHERE eq.ExamID = @ExamID
    ORDER BY eq.QuestionOrder;
END
GO

-- =============================================
-- Procedure: SP_API_GetInstructorExamReport
-- Description: Comprehensive exam report for instructors
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_API_GetInstructorExamReport
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
        RAISERROR('Unauthorized access to exam.', 16, 1);
        RETURN;
    END
    
    -- Exam overview
    SELECT 
        e.ExamID,
        e.ExamName,
        c.CourseName,
        e.TotalMarks,
        e.PassMarks,
        e.StartDateTime,
        e.EndDateTime,
        COUNT(DISTINCT se.StudentID) AS TotalStudents,
        SUM(CASE WHEN se.SubmissionTime IS NOT NULL THEN 1 ELSE 0 END) AS CompletedCount,
        SUM(CASE WHEN se.IsPassed = 1 THEN 1 ELSE 0 END) AS PassedCount,
        SUM(CASE WHEN se.IsPassed = 0 THEN 1 ELSE 0 END) AS FailedCount,
        AVG(se.TotalScore) AS AverageScore,
        MAX(se.TotalScore) AS HighestScore,
        MIN(se.TotalScore) AS LowestScore,
        STDEV(se.TotalScore) AS StandardDeviation,
        SUM(CASE WHEN se.IsGraded = 0 AND se.SubmissionTime IS NOT NULL THEN 1 ELSE 0 END) AS PendingGrading
    FROM Exam.Exam e
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    LEFT JOIN Exam.StudentExam se ON e.ExamID = se.ExamID
    WHERE e.ExamID = @ExamID
    GROUP BY e.ExamID, e.ExamName, c.CourseName, e.TotalMarks, e.PassMarks, e.StartDateTime, e.EndDateTime;
    
    -- Student-by-student results
    SELECT 
        s.StudentID,
        u.FirstName + ' ' + u.LastName AS StudentName,
        u.Email,
        se.StartTime,
        se.SubmissionTime,
        DATEDIFF(MINUTE, se.StartTime, se.SubmissionTime) AS TimeTaken,
        se.TotalScore,
        se.IsPassed,
        se.IsGraded,
        Exam.FN_CalculateExamGrade(se.TotalScore, e.TotalMarks) AS Percentage
    FROM Exam.StudentExam se
    INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    WHERE se.ExamID = @ExamID AND se.SubmissionTime IS NOT NULL
    ORDER BY se.TotalScore DESC;
    
    -- Question statistics
    SELECT 
        q.QuestionID,
        q.QuestionText,
        q.QuestionType,
        eq.QuestionMarks,
        COUNT(sa.StudentAnswerID) AS TotalAttempts,
        SUM(CASE WHEN sa.IsCorrect = 1 THEN 1 ELSE 0 END) AS CorrectCount,
        SUM(CASE WHEN sa.IsCorrect = 0 THEN 1 ELSE 0 END) AS IncorrectCount,
        CAST(SUM(CASE WHEN sa.IsCorrect = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(sa.StudentAnswerID) AS DECIMAL(5,2)) AS SuccessRate
    FROM Exam.ExamQuestion eq
    INNER JOIN Exam.Question q ON eq.QuestionID = q.QuestionID
    LEFT JOIN Exam.StudentAnswer sa ON q.QuestionID = sa.QuestionID
    LEFT JOIN Exam.StudentExam se ON sa.StudentExamID = se.StudentExamID
    WHERE eq.ExamID = @ExamID AND se.ExamID = @ExamID
    GROUP BY q.QuestionID, q.QuestionText, q.QuestionType, eq.QuestionMarks
    ORDER BY SuccessRate ASC;
END
GO

-- =============================================
-- Procedure: SP_API_BulkAssignStudentsToExam
-- Description: Efficiently assigns multiple students to exam
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_API_BulkAssignStudentsToExam
    @ExamID INT,
    @StudentIDsJSON NVARCHAR(MAX) -- JSON array: [1,2,3,4,5]
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parse JSON
        INSERT INTO Exam.StudentExam (StudentID, ExamID, IsAllowed)
        SELECT 
            CAST(value AS INT) AS StudentID,
            @ExamID,
            1
        FROM OPENJSON(@StudentIDsJSON)
        WHERE CAST(value AS INT) NOT IN (
            SELECT StudentID FROM Exam.StudentExam WHERE ExamID = @ExamID
        );
        
        COMMIT TRANSACTION;
        
        SELECT @@ROWCOUNT AS StudentsAssigned;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_API_GetStudentProgress
-- Description: Student overall progress across all courses
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_API_GetStudentProgress
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Overall stats
    SELECT 
        s.StudentID,
        u.FirstName + ' ' + u.LastName AS StudentName,
        s.GPA,
        b.BranchName,
        t.TrackName,
        i.IntakeName,
        (SELECT COUNT(*) FROM Academic.StudentCourse WHERE StudentID = @StudentID) AS TotalCourses,
        (SELECT COUNT(*) FROM Academic.StudentCourse WHERE StudentID = @StudentID AND IsPassed = 1) AS PassedCourses,
        (SELECT COUNT(*) FROM Exam.StudentExam se WHERE se.StudentID = @StudentID AND se.SubmissionTime IS NOT NULL) AS CompletedExams,
        (SELECT AVG(TotalScore) FROM Exam.StudentExam WHERE StudentID = @StudentID AND IsGraded = 1) AS OverallExamAverage
    FROM Academic.Student s
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    INNER JOIN Academic.Branch b ON s.BranchID = b.BranchID
    INNER JOIN Academic.Track t ON s.TrackID = t.TrackID
    INNER JOIN Academic.Intake i ON s.IntakeID = i.IntakeID
    WHERE s.StudentID = @StudentID;
    
    -- Course-by-course progress
    SELECT 
        c.CourseID,
        c.CourseName,
        c.CourseCode,
        sc.FinalGrade,
        c.MaxDegree,
        c.MinDegree,
        sc.IsPassed,
        Exam.FN_CalculateExamGrade(sc.FinalGrade, c.MaxDegree) AS Percentage,
        (SELECT COUNT(*) FROM Exam.StudentExam se 
         INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
         WHERE se.StudentID = @StudentID AND e.CourseID = c.CourseID) AS TotalExams,
        (SELECT COUNT(*) FROM Exam.StudentExam se 
         INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
         WHERE se.StudentID = @StudentID AND e.CourseID = c.CourseID AND se.SubmissionTime IS NOT NULL) AS CompletedExams
    FROM Academic.StudentCourse sc
    INNER JOIN Academic.Course c ON sc.CourseID = c.CourseID
    WHERE sc.StudentID = @StudentID
    ORDER BY sc.EnrollmentDate DESC;
    
    -- Recent exam results
    SELECT TOP 5
        e.ExamName,
        c.CourseName,
        se.TotalScore,
        e.TotalMarks,
        se.IsPassed,
        se.SubmissionTime,
        Exam.FN_CalculateExamGrade(se.TotalScore, e.TotalMarks) AS Percentage
    FROM Exam.StudentExam se
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    WHERE se.StudentID = @StudentID AND se.SubmissionTime IS NOT NULL
    ORDER BY se.SubmissionTime DESC;
END
GO

PRINT 'API Response procedures created successfully!';
GO
