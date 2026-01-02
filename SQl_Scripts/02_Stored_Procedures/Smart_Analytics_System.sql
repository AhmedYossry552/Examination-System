/*
============================================================================
Smart Analytics System - Data-Driven Insights (No AI Required)
============================================================================
Description: Statistical analysis and predictions using SQL intelligence
Author: Examination System Team
Created: 2025-11-13
============================================================================
*/

USE ExaminationSystemDB;
GO

-- =============================================
-- 1. Question Difficulty Analysis
-- =============================================
CREATE OR ALTER PROCEDURE Analytics.SP_AnalyzeQuestionDifficulty
    @QuestionID INT = NULL,
    @CourseID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        q.QuestionID,
        q.QuestionText,
        q.QuestionType,
        c.CourseName,
        
        -- Sample Size
        COUNT(sa.StudentAnswerID) AS SampleSize,
        
        -- Difficulty (% who got it right)
        CAST(AVG(CAST(sa.IsCorrect AS FLOAT)) * 100 AS DECIMAL(5,2)) AS SuccessRatePercentage,
        CASE 
            WHEN AVG(CAST(sa.IsCorrect AS FLOAT)) > 0.8 THEN 'Too Easy'
            WHEN AVG(CAST(sa.IsCorrect AS FLOAT)) > 0.6 THEN 'Easy'
            WHEN AVG(CAST(sa.IsCorrect AS FLOAT)) > 0.4 THEN 'Moderate'
            WHEN AVG(CAST(sa.IsCorrect AS FLOAT)) > 0.2 THEN 'Hard'
            ELSE 'Too Hard'
        END AS DifficultyLevel,
        
        -- Discrimination (separates good from poor students)
        (
            -- Top 25% students success rate
            SELECT AVG(CAST(sa1.IsCorrect AS FLOAT))
            FROM Exam.StudentAnswer sa1
            INNER JOIN Exam.StudentExam se1 ON sa1.StudentExamID = se1.StudentExamID
            INNER JOIN (
                SELECT TOP 25 PERCENT StudentID 
                FROM Exam.StudentExam
                WHERE TotalScore IS NOT NULL
                GROUP BY StudentID
                ORDER BY AVG(TotalScore) DESC
            ) topStudents ON se1.StudentID = topStudents.StudentID
            WHERE sa1.QuestionID = q.QuestionID
        ) - 
        (
            -- Bottom 25% students success rate
            SELECT AVG(CAST(sa2.IsCorrect AS FLOAT))
            FROM Exam.StudentAnswer sa2
            INNER JOIN Exam.StudentExam se2 ON sa2.StudentExamID = se2.StudentExamID
            INNER JOIN (
                SELECT TOP 25 PERCENT StudentID 
                FROM Exam.StudentExam
                WHERE TotalScore IS NOT NULL
                GROUP BY StudentID
                ORDER BY AVG(TotalScore) ASC
            ) bottomStudents ON se2.StudentID = bottomStudents.StudentID
            WHERE sa2.QuestionID = q.QuestionID
        ) AS DiscriminationIndex,
        
        CASE 
            WHEN (
                (SELECT AVG(CAST(sa1.IsCorrect AS FLOAT)) FROM Exam.StudentAnswer sa1 INNER JOIN Exam.StudentExam se1 ON sa1.StudentExamID = se1.StudentExamID INNER JOIN (SELECT TOP 25 PERCENT StudentID FROM Exam.StudentExam WHERE TotalScore IS NOT NULL GROUP BY StudentID ORDER BY AVG(TotalScore) DESC) topStudents ON se1.StudentID = topStudents.StudentID WHERE sa1.QuestionID = q.QuestionID) -
                (SELECT AVG(CAST(sa2.IsCorrect AS FLOAT)) FROM Exam.StudentAnswer sa2 INNER JOIN Exam.StudentExam se2 ON sa2.StudentExamID = se2.StudentExamID INNER JOIN (SELECT TOP 25 PERCENT StudentID FROM Exam.StudentExam WHERE TotalScore IS NOT NULL GROUP BY StudentID ORDER BY AVG(TotalScore) ASC) bottomStudents ON se2.StudentID = bottomStudents.StudentID WHERE sa2.QuestionID = q.QuestionID)
            ) > 0.4 THEN 'Excellent'
            WHEN (
                (SELECT AVG(CAST(sa1.IsCorrect AS FLOAT)) FROM Exam.StudentAnswer sa1 INNER JOIN Exam.StudentExam se1 ON sa1.StudentExamID = se1.StudentExamID INNER JOIN (SELECT TOP 25 PERCENT StudentID FROM Exam.StudentExam WHERE TotalScore IS NOT NULL GROUP BY StudentID ORDER BY AVG(TotalScore) DESC) topStudents ON se1.StudentID = topStudents.StudentID WHERE sa1.QuestionID = q.QuestionID) -
                (SELECT AVG(CAST(sa2.IsCorrect AS FLOAT)) FROM Exam.StudentAnswer sa2 INNER JOIN Exam.StudentExam se2 ON sa2.StudentExamID = se2.StudentExamID INNER JOIN (SELECT TOP 25 PERCENT StudentID FROM Exam.StudentExam WHERE TotalScore IS NOT NULL GROUP BY StudentID ORDER BY AVG(TotalScore) ASC) bottomStudents ON se2.StudentID = bottomStudents.StudentID WHERE sa2.QuestionID = q.QuestionID)
            ) > 0.2 THEN 'Good'
            WHEN (
                (SELECT AVG(CAST(sa1.IsCorrect AS FLOAT)) FROM Exam.StudentAnswer sa1 INNER JOIN Exam.StudentExam se1 ON sa1.StudentExamID = se1.StudentExamID INNER JOIN (SELECT TOP 25 PERCENT StudentID FROM Exam.StudentExam WHERE TotalScore IS NOT NULL GROUP BY StudentID ORDER BY AVG(TotalScore) DESC) topStudents ON se1.StudentID = topStudents.StudentID WHERE sa1.QuestionID = q.QuestionID) -
                (SELECT AVG(CAST(sa2.IsCorrect AS FLOAT)) FROM Exam.StudentAnswer sa2 INNER JOIN Exam.StudentExam se2 ON sa2.StudentExamID = se2.StudentExamID INNER JOIN (SELECT TOP 25 PERCENT StudentID FROM Exam.StudentExam WHERE TotalScore IS NOT NULL GROUP BY StudentID ORDER BY AVG(TotalScore) ASC) bottomStudents ON se2.StudentID = bottomStudents.StudentID WHERE sa2.QuestionID = q.QuestionID)
            ) >= 0 THEN 'Fair'
            ELSE 'Poor - Needs Review'
        END AS QuestionQuality,
        
        -- Recommendations
        CASE 
            WHEN AVG(CAST(sa.IsCorrect AS FLOAT)) > 0.9 THEN 'Consider making this question harder'
            WHEN AVG(CAST(sa.IsCorrect AS FLOAT)) < 0.1 THEN 'Question may be too hard or has errors'
            WHEN (
                (SELECT AVG(CAST(sa1.IsCorrect AS FLOAT)) FROM Exam.StudentAnswer sa1 INNER JOIN Exam.StudentExam se1 ON sa1.StudentExamID = se1.StudentExamID INNER JOIN (SELECT TOP 25 PERCENT StudentID FROM Exam.StudentExam WHERE TotalScore IS NOT NULL GROUP BY StudentID ORDER BY AVG(TotalScore) DESC) topStudents ON se1.StudentID = topStudents.StudentID WHERE sa1.QuestionID = q.QuestionID) -
                (SELECT AVG(CAST(sa2.IsCorrect AS FLOAT)) FROM Exam.StudentAnswer sa2 INNER JOIN Exam.StudentExam se2 ON sa2.StudentExamID = se2.StudentExamID INNER JOIN (SELECT TOP 25 PERCENT StudentID FROM Exam.StudentExam WHERE TotalScore IS NOT NULL GROUP BY StudentID ORDER BY AVG(TotalScore) ASC) bottomStudents ON se2.StudentID = bottomStudents.StudentID WHERE sa2.QuestionID = q.QuestionID)
            ) < 0.1 THEN 'Question does not discriminate well between good and poor students'
            ELSE 'Question is performing well'
        END AS Recommendation
        
    FROM Exam.Question q
    INNER JOIN Academic.Course c ON q.CourseID = c.CourseID
    LEFT JOIN Exam.StudentAnswer sa ON q.QuestionID = sa.QuestionID
    WHERE (@QuestionID IS NULL OR q.QuestionID = @QuestionID)
      AND (@CourseID IS NULL OR q.CourseID = @CourseID)
      AND sa.StudentAnswerID IS NOT NULL
    GROUP BY 
        q.QuestionID, q.QuestionText, q.QuestionType, c.CourseName
    HAVING COUNT(sa.StudentAnswerID) >= 10  -- Minimum sample size
    ORDER BY 
        DifficultyLevel, 
        SuccessRatePercentage DESC;
END
GO

-- =============================================
-- 2. Student Performance Prediction
-- =============================================
CREATE OR ALTER PROCEDURE Analytics.SP_PredictStudentPerformance
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @PredictedGrade DECIMAL(5,2);
    DECLARE @Confidence DECIMAL(3,2);
    DECLARE @RiskLevel NVARCHAR(20);
    
    -- Calculate based on historical performance
    WITH StudentMetrics AS (
        SELECT 
            -- Grade trend (weight: 40%)
            AVG(se.TotalScore / NULLIF(e.TotalMarks, 0)) AS AvgScore,
            STDEV(se.TotalScore / NULLIF(e.TotalMarks, 0)) AS ScoreStdDev,
            
            -- Recent performance (weight: 30%)
            (
                SELECT AVG(se2.TotalScore / NULLIF(e2.TotalMarks, 0))
                FROM Exam.StudentExam se2
                INNER JOIN Exam.Exam e2 ON se2.ExamID = e2.ExamID
                WHERE se2.StudentID = @StudentID
                  AND se2.SubmissionTime >= DATEADD(MONTH, -1, GETDATE())
            ) AS RecentScore,
            
            -- Completion rate (weight: 20%)
            CAST(COUNT(CASE WHEN se.SubmissionTime IS NOT NULL THEN 1 END) AS FLOAT) / 
            NULLIF(COUNT(*), 0) AS CompletionRate,
            
            -- Improvement trend (weight: 10%)
            CASE 
                WHEN COUNT(*) >= 3 THEN
                    (
                        SELECT 
                            (MAX(CASE WHEN rn IN (1,2) THEN Score END) - MAX(CASE WHEN rn IN (3,4) THEN Score END))
                        FROM (
                            SELECT 
                                se3.TotalScore / NULLIF(e3.TotalMarks, 0) AS Score,
                                ROW_NUMBER() OVER (ORDER BY se3.SubmissionTime DESC) AS rn
                            FROM Exam.StudentExam se3
                            INNER JOIN Exam.Exam e3 ON se3.ExamID = e3.ExamID
                            WHERE se3.StudentID = @StudentID
                              AND se3.SubmissionTime IS NOT NULL
                        ) t
                    )
                ELSE 0
            END AS ImprovementTrend,
            
            COUNT(*) AS TotalExams
            
        FROM Exam.StudentExam se
        INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
        WHERE se.StudentID = @StudentID
          AND se.SubmissionTime IS NOT NULL
    )
    SELECT 
        @PredictedGrade = (
            (ISNULL(AvgScore, 0.5) * 0.4) +
            (ISNULL(RecentScore, AvgScore) * 0.3) +
            (CompletionRate * 0.2) +
            ((ISNULL(ImprovementTrend, 0) + 0.5) * 0.1)
        ) * 100,
        @Confidence = CASE 
            WHEN TotalExams >= 10 THEN 0.9
            WHEN TotalExams >= 5 THEN 0.7
            WHEN TotalExams >= 3 THEN 0.5
            ELSE 0.3
        END
    FROM StudentMetrics;
    
    -- Determine risk level
    SET @RiskLevel = CASE 
        WHEN @PredictedGrade < 50 THEN 'High Risk'
        WHEN @PredictedGrade < 65 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END;
    
    -- Return prediction
    SELECT 
        @StudentID AS StudentID,
        u.FirstName + ' ' + u.LastName AS StudentName,
        @PredictedGrade AS PredictedGrade,
        @Confidence AS ConfidenceLevel,
        @RiskLevel AS RiskLevel,
        CASE 
            WHEN @RiskLevel = 'High Risk' THEN 'Immediate intervention recommended'
            WHEN @RiskLevel = 'Medium Risk' THEN 'Additional support suggested'
            ELSE 'Student is performing well'
        END AS Recommendation
    FROM Academic.Student s
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    WHERE s.StudentID = @StudentID;
END
GO

-- =============================================
-- 3. Identify At-Risk Students
-- =============================================
CREATE OR ALTER PROCEDURE Analytics.SP_IdentifyAtRiskStudents
    @CourseID INT = NULL,
    @IntakeID INT = NULL,
    @RiskThreshold DECIMAL(3,2) = 0.6  -- Below 60% is at risk
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.StudentID,
        u.FirstName + ' ' + u.LastName AS StudentName,
        u.Email,
        c.CourseName,
        
        -- Performance Metrics
        COUNT(DISTINCT se.ExamID) AS ExamsTaken,
        AVG(se.TotalScore / NULLIF(e.TotalMarks, 0)) AS AvgScoreRatio,
        CAST(AVG(se.TotalScore / NULLIF(e.TotalMarks, 0)) * 100 AS DECIMAL(5,2)) AS AvgScorePercentage,
        
        -- Recent Performance
        (
            SELECT AVG(se2.TotalScore / NULLIF(e2.TotalMarks, 0))
            FROM Exam.StudentExam se2
            INNER JOIN Exam.Exam e2 ON se2.ExamID = e2.ExamID
            WHERE se2.StudentID = s.StudentID
              AND se2.SubmissionTime >= DATEADD(WEEK, -2, GETDATE())
        ) AS RecentPerformance,
        
        -- Trend
        CASE 
            WHEN (
                SELECT AVG(se3.TotalScore / NULLIF(e3.TotalMarks, 0))
                FROM Exam.StudentExam se3
                INNER JOIN Exam.Exam e3 ON se3.ExamID = e3.ExamID
                WHERE se3.StudentID = s.StudentID
                  AND se3.SubmissionTime >= DATEADD(WEEK, -1, GETDATE())
            ) > AVG(se.TotalScore / NULLIF(e.TotalMarks, 0))
            THEN 'Improving'
            WHEN (
                SELECT AVG(se3.TotalScore / NULLIF(e3.TotalMarks, 0))
                FROM Exam.StudentExam se3
                INNER JOIN Exam.Exam e3 ON se3.ExamID = e3.ExamID
                WHERE se3.StudentID = s.StudentID
                  AND se3.SubmissionTime >= DATEADD(WEEK, -1, GETDATE())
            ) < AVG(se.TotalScore / NULLIF(e.TotalMarks, 0))
            THEN 'Declining'
            ELSE 'Stable'
        END AS PerformanceTrend,
        
        -- Risk Classification
        CASE 
            WHEN AVG(se.TotalScore / NULLIF(e.TotalMarks, 0)) < 0.4 THEN 'Critical'
            WHEN AVG(se.TotalScore / NULLIF(e.TotalMarks, 0)) < @RiskThreshold THEN 'High'
            ELSE 'Medium'
        END AS RiskLevel,
        
        -- Recommendations
        CASE 
            WHEN AVG(se.TotalScore / NULLIF(e.TotalMarks, 0)) < 0.4 
            THEN 'Urgent: Schedule one-on-one tutoring'
            WHEN AVG(se.TotalScore / NULLIF(e.TotalMarks, 0)) < 0.5 
            THEN 'High Priority: Assign additional study materials'
            ELSE 'Monitor: Provide encouragement and support'
        END AS ActionRequired
        
    FROM Academic.Student s
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    INNER JOIN Exam.StudentExam se ON s.StudentID = se.StudentID
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    WHERE se.SubmissionTime IS NOT NULL
      AND se.TotalScore IS NOT NULL
      AND (@CourseID IS NULL OR e.CourseID = @CourseID)
      AND (@IntakeID IS NULL OR e.IntakeID = @IntakeID)
    GROUP BY 
        s.StudentID, u.FirstName, u.LastName, u.Email, c.CourseName
    HAVING 
        AVG(se.TotalScore / NULLIF(e.TotalMarks, 0)) < @RiskThreshold
    ORDER BY 
        AvgScoreRatio ASC;
END
GO

-- =============================================
-- 4. Course Performance Dashboard
-- =============================================
CREATE OR ALTER PROCEDURE Analytics.SP_GetCoursePerformanceDashboard
    @CourseID INT,
    @IntakeID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Overall Statistics
    SELECT 
        c.CourseID,
        c.CourseName,
        COUNT(DISTINCT se.StudentID) AS TotalStudents,
        COUNT(DISTINCT e.ExamID) AS TotalExams,
        AVG(se.TotalScore / NULLIF(e.TotalMarks, 0)) * 100 AS AvgScorePercentage,
        STDEV(se.TotalScore / NULLIF(e.TotalMarks, 0)) * 100 AS ScoreStandardDeviation,
        
        -- Pass/Fail Statistics
        COUNT(DISTINCT CASE WHEN se.TotalScore >= e.PassMarks THEN se.StudentID END) AS StudentsPassed,
        COUNT(DISTINCT CASE WHEN se.TotalScore < e.PassMarks THEN se.StudentID END) AS StudentsFailed,
        CAST(
            COUNT(DISTINCT CASE WHEN se.TotalScore >= e.PassMarks THEN se.StudentID END) * 100.0 /
            NULLIF(COUNT(DISTINCT se.StudentID), 0)
            AS DECIMAL(5,2)
        ) AS PassRatePercentage
        
    FROM Academic.Course c
    LEFT JOIN Exam.Exam e ON c.CourseID = e.CourseID
    LEFT JOIN Exam.StudentExam se ON e.ExamID = se.ExamID
    WHERE c.CourseID = @CourseID
      AND (@IntakeID IS NULL OR e.IntakeID = @IntakeID)
      AND se.SubmissionTime IS NOT NULL
    GROUP BY c.CourseID, c.CourseName;
    
    -- Question Performance
    SELECT TOP 10
        q.QuestionID,
        LEFT(q.QuestionText, 100) AS QuestionPreview,
        q.QuestionType,
        COUNT(sa.StudentAnswerID) AS TimesAsked,
        CAST(AVG(CAST(sa.IsCorrect AS FLOAT)) * 100 AS DECIMAL(5,2)) AS SuccessRate,
        CASE 
            WHEN AVG(CAST(sa.IsCorrect AS FLOAT)) < 0.3 THEN 'Review Needed'
            WHEN AVG(CAST(sa.IsCorrect AS FLOAT)) < 0.5 THEN 'Difficult'
            WHEN AVG(CAST(sa.IsCorrect AS FLOAT)) > 0.8 THEN 'Easy'
            ELSE 'Moderate'
        END AS Assessment
    FROM Exam.Question q
    INNER JOIN Exam.ExamQuestion eq ON q.QuestionID = eq.QuestionID
    INNER JOIN Exam.Exam e ON eq.ExamID = e.ExamID
    INNER JOIN Exam.StudentAnswer sa ON q.QuestionID = sa.QuestionID
    WHERE e.CourseID = @CourseID
      AND (@IntakeID IS NULL OR e.IntakeID = @IntakeID)
    GROUP BY q.QuestionID, q.QuestionText, q.QuestionType
    ORDER BY SuccessRate ASC;
END
GO

PRINT '✓ Smart Analytics procedures created successfully';
GO
