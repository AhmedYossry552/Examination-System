/*
============================================================================
Real-Time Exam Monitoring Views
============================================================================
Description: Live dashboard views for instructors to monitor ongoing exams
Author: Examination System Team
Created: 2025-11-13
============================================================================
*/

USE ExaminationSystemDB;
GO

-- =============================================
-- 1. Live Exam Monitoring Dashboard
-- =============================================
CREATE OR ALTER VIEW Exam.VW_LiveExamMonitoring
AS
SELECT 
    -- Exam Information
    e.ExamID,
    e.ExamName,
    c.CourseName,
    e.DurationMinutes,
    e.TotalMarks,
    
    -- Student Information
    se.StudentExamID,
    s.StudentID,
    u.FirstName + ' ' + u.LastName AS StudentName,
    u.Email AS StudentEmail,
    
    -- Timing Information
    se.StartTime,
    DATEDIFF(MINUTE, se.StartTime, GETDATE()) AS MinutesElapsed,
    e.DurationMinutes - DATEDIFF(MINUTE, se.StartTime, GETDATE()) AS MinutesRemaining,
    CAST(
        (CAST(DATEDIFF(MINUTE, se.StartTime, GETDATE()) AS FLOAT) / e.DurationMinutes) * 100 
        AS DECIMAL(5,2)
    ) AS ProgressPercentage,
    
    -- Progress Information
    (
        SELECT COUNT(*) 
        FROM Exam.ExamQuestion eq 
        WHERE eq.ExamID = e.ExamID
    ) AS TotalQuestions,
    (
        SELECT COUNT(DISTINCT sa.QuestionID)
        FROM Exam.StudentAnswer sa
        WHERE sa.StudentExamID = se.StudentExamID
    ) AS QuestionsAnswered,
    CAST(
        (CAST((SELECT COUNT(DISTINCT sa.QuestionID)FROM Exam.StudentAnswer sa WHERE sa.StudentExamID = se.StudentExamID) AS FLOAT) /
         NULLIF((SELECT COUNT(*) FROM Exam.ExamQuestion eq WHERE eq.ExamID = e.ExamID), 0)) * 100
        AS DECIMAL(5,2)
    ) AS CompletionPercentage,
    
    -- Activity Status
    (
        SELECT MAX(AnsweredDate) 
        FROM Exam.StudentAnswer sa 
        WHERE sa.StudentExamID = se.StudentExamID
    ) AS LastActivity,
    DATEDIFF(MINUTE, 
        (SELECT MAX(AnsweredDate) FROM Exam.StudentAnswer sa WHERE sa.StudentExamID = se.StudentExamID),
        GETDATE()
    ) AS MinutesSinceLastActivity,
    
    -- Status Classification
    CASE 
        WHEN DATEDIFF(MINUTE, se.StartTime, GETDATE()) > e.DurationMinutes 
        THEN 'Overtime'
        WHEN (SELECT MAX(AnsweredDate) FROM Exam.StudentAnswer sa WHERE sa.StudentExamID = se.StudentExamID) IS NULL
        THEN 'Not Started'
        WHEN DATEDIFF(MINUTE, (SELECT MAX(AnsweredDate) FROM Exam.StudentAnswer sa WHERE sa.StudentExamID = se.StudentExamID), GETDATE()) > 5
        THEN 'Inactive'
        WHEN DATEDIFF(MINUTE, (SELECT MAX(AnsweredDate) FROM Exam.StudentAnswer sa WHERE sa.StudentExamID = se.StudentExamID), GETDATE()) > 2
        THEN 'Idle'
        ELSE 'Active'
    END AS ActivityStatus,
    
    -- Alert Level
    CASE 
        WHEN DATEDIFF(MINUTE, se.StartTime, GETDATE()) > e.DurationMinutes THEN 3  -- Critical
        WHEN DATEDIFF(MINUTE, (SELECT MAX(AnsweredDate) FROM Exam.StudentAnswer sa WHERE sa.StudentExamID = se.StudentExamID), GETDATE()) > 5 THEN 2  -- Warning
        WHEN DATEDIFF(MINUTE, se.StartTime, GETDATE()) > (e.DurationMinutes * 0.9) THEN 1  -- Info
        ELSE 0  -- Normal
    END AS AlertLevel,
    
    -- Session Information (if available)
    (
        SELECT TOP 1 us.IPAddress
        FROM Security.UserSessions us
        WHERE us.UserID = u.UserID 
          AND us.IsActive = 1
        ORDER BY us.LastActivityDate DESC
    ) AS CurrentIPAddress
    
FROM Exam.StudentExam se
INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
INNER JOIN Security.[User] u ON s.UserID = u.UserID
INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
WHERE se.SubmissionTime IS NULL  -- Only ongoing exams
  AND se.StartTime IS NOT NULL   -- Student has started
  AND e.StartDateTime <= GETDATE()  -- Exam has begun
  AND DATEADD(HOUR, 1, e.EndDateTime) >= GETDATE();  -- Include 1 hour grace period
GO

-- =============================================
-- 2. Exam Session Statistics
-- =============================================
CREATE OR ALTER VIEW Exam.VW_ExamSessionStatistics
AS
SELECT 
    e.ExamID,
    e.ExamName,
    c.CourseName,
    i.FirstName + ' ' + i.LastName AS InstructorName,
    e.StartDateTime,
    e.EndDateTime,
    e.DurationMinutes,
    
    -- Overall Statistics
    COUNT(DISTINCT se.StudentID) AS TotalStudents,
    COUNT(DISTINCT CASE WHEN se.StartTime IS NOT NULL THEN se.StudentID END) AS StudentsStarted,
    COUNT(DISTINCT CASE WHEN se.SubmissionTime IS NOT NULL THEN se.StudentID END) AS StudentsCompleted,
    COUNT(DISTINCT CASE WHEN se.StartTime IS NOT NULL AND se.SubmissionTime IS NULL THEN se.StudentID END) AS StudentsInProgress,
    
    -- Completion Rates
    CAST(
        (CAST(COUNT(DISTINCT CASE WHEN se.StartTime IS NOT NULL THEN se.StudentID END) AS FLOAT) /
         NULLIF(COUNT(DISTINCT se.StudentID), 0)) * 100
        AS DECIMAL(5,2)
    ) AS StartRatePercentage,
    CAST(
        (CAST(COUNT(DISTINCT CASE WHEN se.SubmissionTime IS NOT NULL THEN se.StudentID END) AS FLOAT) /
         NULLIF(COUNT(DISTINCT CASE WHEN se.StartTime IS NOT NULL THEN se.StudentID END), 0)) * 100
        AS DECIMAL(5,2)
    ) AS CompletionRatePercentage,
    
    -- Average Timings (for completed exams)
    CAST(AVG(
        CASE WHEN se.SubmissionTime IS NOT NULL 
        THEN DATEDIFF(MINUTE, se.StartTime, se.SubmissionTime)
        END
    ) AS DECIMAL(5,2)) AS AvgCompletionTimeMinutes,
    
    -- Current Status
    CASE 
        WHEN GETDATE() < e.StartDateTime THEN 'Scheduled'
        WHEN GETDATE() >= e.StartDateTime AND GETDATE() <= e.EndDateTime THEN 'In Progress'
        WHEN GETDATE() > e.EndDateTime THEN 'Ended'
    END AS ExamStatus
    
FROM Exam.Exam e
INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
INNER JOIN Academic.Instructor inst ON e.InstructorID = inst.InstructorID
INNER JOIN Security.[User] i ON inst.UserID = i.UserID
LEFT JOIN Exam.StudentExam se ON e.ExamID = se.ExamID
GROUP BY 
    e.ExamID, e.ExamName, c.CourseName, 
    i.FirstName, i.LastName,
    e.StartDateTime, e.EndDateTime, e.DurationMinutes;
GO

-- =============================================
-- 3. Suspicious Activity Monitor
-- =============================================
CREATE OR ALTER VIEW Exam.VW_SuspiciousActivityMonitor
AS
SELECT 
    se.StudentExamID,
    s.StudentID,
    u.FirstName + ' ' + u.LastName AS StudentName,
    e.ExamName,
    
    -- Time-based suspicions
    CASE 
        WHEN (
            SELECT COUNT(*)
            FROM (
                SELECT 
                    QuestionID,
                    AnsweredDate,
                    LAG(AnsweredDate) OVER (ORDER BY AnsweredDate) AS PrevAnswerTime
                FROM Exam.StudentAnswer
                WHERE StudentExamID = se.StudentExamID
            ) t
            WHERE DATEDIFF(SECOND, PrevAnswerTime, AnsweredDate) < 5
        ) >= 5
        THEN 1 ELSE 0
    END AS TooFastAnswering,
    
    -- Pattern-based suspicions
    CASE 
        WHEN (
            SELECT COUNT(DISTINCT SelectedOptionID)
            FROM Exam.StudentAnswer sa
            INNER JOIN Exam.QuestionOption qo ON sa.SelectedOptionID = qo.OptionID
            WHERE sa.StudentExamID = se.StudentExamID
              AND qo.OptionText IN ('A', 'B', 'C', 'D', '1', '2', '3', '4')
        ) = 1
        THEN 1 ELSE 0
    END AS PatternBias,
    
    -- Completion suspicions
    CASE 
        WHEN se.SubmissionTime IS NOT NULL 
         AND DATEDIFF(MINUTE, se.StartTime, se.SubmissionTime) < (e.DurationMinutes * 0.3)
        THEN 1 ELSE 0
    END AS TooQuickSubmission,
    
    -- Summary
    (
        SELECT COUNT(*)
        FROM (
            SELECT 
                QuestionID,
                AnsweredDate,
                LAG(AnsweredDate) OVER (ORDER BY AnsweredDate) AS PrevAnswerTime
            FROM Exam.StudentAnswer
            WHERE StudentExamID = se.StudentExamID
        ) t
        WHERE DATEDIFF(SECOND, PrevAnswerTime, AnsweredDate) < 5
    ) AS RapidAnswerCount,
    
    DATEDIFF(MINUTE, se.StartTime, ISNULL(se.SubmissionTime, GETDATE())) AS TotalTimeMinutes,
    
    -- Risk Level
    CASE 
        WHEN (
            (SELECT COUNT(*) FROM (SELECT QuestionID, AnsweredDate, LAG(AnsweredDate) OVER (ORDER BY AnsweredDate) AS PrevAnswerTime FROM Exam.StudentAnswer WHERE StudentExamID = se.StudentExamID) t WHERE DATEDIFF(SECOND, PrevAnswerTime, AnsweredDate) < 5) >= 10
            OR
            (se.SubmissionTime IS NOT NULL AND DATEDIFF(MINUTE, se.StartTime, se.SubmissionTime) < (e.DurationMinutes * 0.2))
        )
        THEN 'High Risk'
        WHEN (
            (SELECT COUNT(*) FROM (SELECT QuestionID, AnsweredDate, LAG(AnsweredDate) OVER (ORDER BY AnsweredDate) AS PrevAnswerTime FROM Exam.StudentAnswer WHERE StudentExamID = se.StudentExamID) t WHERE DATEDIFF(SECOND, PrevAnswerTime, AnsweredDate) < 5) >= 5
            OR
            (se.SubmissionTime IS NOT NULL AND DATEDIFF(MINUTE, se.StartTime, se.SubmissionTime) < (e.DurationMinutes * 0.4))
        )
        THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskLevel
    
FROM Exam.StudentExam se
INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
INNER JOIN Security.[User] u ON s.UserID = u.UserID
INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
WHERE se.StartTime IS NOT NULL;
GO

PRINT '✓ Real-Time Monitoring views created successfully';
GO
