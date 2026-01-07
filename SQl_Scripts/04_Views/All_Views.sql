/*=============================================
  Examination System - Views
  Description: Views for clean data access layer
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- View: VW_UserDetails
-- Description: Complete user information with role
-- =============================================
CREATE OR ALTER VIEW Security.VW_UserDetails
AS
SELECT 
    u.UserID,
    u.Username,
    u.Email,
    u.FirstName,
    u.LastName,
    u.FullName,
    u.PhoneNumber,
    u.UserType,
    u.IsActive,
    u.CreatedDate,
    u.LastLoginDate,
    CASE u.UserType
        WHEN 'Student' THEN s.StudentID
        WHEN 'Instructor' THEN i.InstructorID
        WHEN 'TrainingManager' THEN i.InstructorID
        ELSE NULL
    END AS RoleID
FROM Security.[User] u
LEFT JOIN Academic.Student s ON u.UserID = s.UserID
LEFT JOIN Academic.Instructor i ON u.UserID = i.UserID;
GO

-- =============================================
-- View: VW_StudentDetails
-- Description: Complete student information
-- =============================================
CREATE OR ALTER VIEW Academic.VW_StudentDetails
AS
SELECT 
    s.StudentID,
    u.Username,
    u.Email,
    u.FirstName,
    u.LastName,
    u.FullName,
    u.PhoneNumber,
    s.EnrollmentDate,
    s.GraduationDate,
    s.GPA,
    i.IntakeID,
    i.IntakeName,
    i.IntakeYear,
    b.BranchID,
    b.BranchName,
    b.BranchLocation,
    t.TrackID,
    t.TrackName,
    s.IsActive,
    (SELECT COUNT(*) FROM Academic.StudentCourse WHERE StudentID = s.StudentID) AS CoursesEnrolled,
    (SELECT COUNT(*) FROM Exam.StudentExam se WHERE se.StudentID = s.StudentID AND se.SubmissionTime IS NOT NULL) AS ExamsCompleted
FROM Academic.Student s
INNER JOIN Security.[User] u ON s.UserID = u.UserID
INNER JOIN Academic.Intake i ON s.IntakeID = i.IntakeID
INNER JOIN Academic.Branch b ON s.BranchID = b.BranchID
INNER JOIN Academic.Track t ON s.TrackID = t.TrackID;
GO

-- =============================================
-- View: VW_InstructorDetails
-- Description: Complete instructor information
-- =============================================
CREATE OR ALTER VIEW Academic.VW_InstructorDetails
AS
SELECT 
    i.InstructorID,
    u.Username,
    u.Email,
    u.FirstName,
    u.LastName,
    u.FullName,
    u.PhoneNumber,
    i.Specialization,
    i.HireDate,
    i.IsTrainingManager,
    i.IsActive,
    (SELECT COUNT(DISTINCT CourseID) FROM Academic.CourseInstructor WHERE InstructorID = i.InstructorID AND IsActive = 1) AS CoursesTeaching,
    (SELECT COUNT(*) FROM Exam.Exam WHERE InstructorID = i.InstructorID AND IsActive = 1) AS ExamsCreated,
    (SELECT COUNT(*) FROM Exam.Question WHERE InstructorID = i.InstructorID AND IsActive = 1) AS QuestionsCreated
FROM Academic.Instructor i
INNER JOIN Security.[User] u ON i.UserID = u.UserID;
GO

-- =============================================
-- View: VW_CourseDetails
-- Description: Complete course information with statistics
-- =============================================
CREATE OR ALTER VIEW Academic.VW_CourseDetails
AS
SELECT 
    c.CourseID,
    c.CourseName,
    c.CourseCode,
    c.CourseDescription,
    c.MaxDegree,
    c.MinDegree,
    c.TotalHours,
    c.IsActive,
    (SELECT COUNT(DISTINCT InstructorID) FROM Academic.CourseInstructor WHERE CourseID = c.CourseID AND IsActive = 1) AS InstructorCount,
    (SELECT COUNT(*) FROM Academic.StudentCourse WHERE CourseID = c.CourseID) AS StudentsEnrolled,
    (SELECT COUNT(*) FROM Exam.Exam WHERE CourseID = c.CourseID AND IsActive = 1) AS ExamCount,
    (SELECT COUNT(*) FROM Exam.Question WHERE CourseID = c.CourseID AND IsActive = 1) AS QuestionCount
FROM Academic.Course c;
GO

-- =============================================
-- View: VW_ExamDetails
-- Description: Complete exam information
-- =============================================
CREATE OR ALTER VIEW Exam.VW_ExamDetails
AS
SELECT 
    e.ExamID,
    e.ExamName,
    e.ExamYear,
    e.ExamType,
    c.CourseID,
    c.CourseName,
    c.CourseCode,
    i.InstructorID,
    u.FirstName + ' ' + u.LastName AS InstructorName,
    e.IntakeID,
    ik.IntakeName,
    e.BranchID,
    b.BranchName,
    e.TrackID,
    t.TrackName,
    e.TotalMarks,
    e.PassMarks,
    e.DurationMinutes,
    e.StartDateTime,
    e.EndDateTime,
    e.ExamWindow,
    e.AllowanceOptions,
    e.IsActive,
    (SELECT COUNT(*) FROM Exam.ExamQuestion WHERE ExamID = e.ExamID) AS QuestionCount,
    (SELECT COUNT(*) FROM Exam.StudentExam WHERE ExamID = e.ExamID) AS StudentsAssigned,
    (SELECT COUNT(*) FROM Exam.StudentExam WHERE ExamID = e.ExamID AND SubmissionTime IS NOT NULL) AS SubmissionsReceived,
    CASE 
        WHEN GETDATE() < e.StartDateTime THEN 'Upcoming'
        WHEN GETDATE() > e.EndDateTime THEN 'Expired'
        ELSE 'Active'
    END AS ExamStatus
FROM Exam.Exam e
INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
INNER JOIN Academic.Instructor i ON e.InstructorID = i.InstructorID
INNER JOIN Security.[User] u ON i.UserID = u.UserID
INNER JOIN Academic.Intake ik ON e.IntakeID = ik.IntakeID
INNER JOIN Academic.Branch b ON e.BranchID = b.BranchID
INNER JOIN Academic.Track t ON e.TrackID = t.TrackID;
GO

-- =============================================
-- View: VW_QuestionPool
-- Description: All questions with details
-- =============================================
CREATE OR ALTER VIEW Exam.VW_QuestionPool
AS
SELECT 
    q.QuestionID,
    q.QuestionText,
    q.QuestionType,
    q.DifficultyLevel,
    q.Points,
    c.CourseID,
    c.CourseName,
    c.CourseCode,
    i.InstructorID,
    u.FirstName + ' ' + u.LastName AS CreatorName,
    q.IsActive,
    q.CreatedDate,
    q.ModifiedDate,
    (SELECT COUNT(*) FROM Exam.ExamQuestion WHERE QuestionID = q.QuestionID) AS UsedInExamCount
FROM Exam.Question q
INNER JOIN Academic.Course c ON q.CourseID = c.CourseID
INNER JOIN Academic.Instructor i ON q.InstructorID = i.InstructorID
INNER JOIN Security.[User] u ON i.UserID = u.UserID;
GO

-- =============================================
-- View: VW_StudentExamResults
-- Description: Student exam results with details
-- =============================================
CREATE OR ALTER VIEW Exam.VW_StudentExamResults
AS
SELECT 
    se.StudentExamID,
    s.StudentID,
    us.FirstName + ' ' + us.LastName AS StudentName,
    e.ExamID,
    e.ExamName,
    e.ExamType,
    c.CourseName,
    c.CourseCode,
    e.TotalMarks,
    e.PassMarks,
    se.TotalScore,
    Exam.FN_CalculateExamGrade(se.TotalScore, e.TotalMarks) AS Percentage,
    se.IsPassed,
    se.IsGraded,
    se.StartTime,
    se.SubmissionTime,
    DATEDIFF(MINUTE, se.StartTime, se.SubmissionTime) AS TimeTakenMinutes,
    i.IntakeName,
    b.BranchName,
    t.TrackName
FROM Exam.StudentExam se
INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
INNER JOIN Security.[User] us ON s.UserID = us.UserID
INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
INNER JOIN Academic.Intake i ON s.IntakeID = i.IntakeID
INNER JOIN Academic.Branch b ON s.BranchID = b.BranchID
INNER JOIN Academic.Track t ON s.TrackID = t.TrackID
WHERE se.SubmissionTime IS NOT NULL;
GO

-- =============================================
-- View: VW_StudentAnswerDetails
-- Description: Student answers with question details
-- =============================================
CREATE OR ALTER VIEW Exam.VW_StudentAnswerDetails
AS
SELECT 
    sa.StudentAnswerID,
    se.StudentExamID,
    s.StudentID,
    u.FirstName + ' ' + u.LastName AS StudentName,
    e.ExamID,
    e.ExamName,
    q.QuestionID,
    q.QuestionText,
    q.QuestionType,
    sa.StudentAnswerText,
    qo.OptionText AS SelectedOptionText,
    sa.IsCorrect,
    eq.QuestionMarks AS MaxMarks,
    sa.MarksObtained,
    sa.NeedsManualGrading,
    sa.InstructorComments,
    sa.AnsweredDate,
    sa.GradedDate
FROM Exam.StudentAnswer sa
INNER JOIN Exam.StudentExam se ON sa.StudentExamID = se.StudentExamID
INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
INNER JOIN Security.[User] u ON s.UserID = u.UserID
INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
INNER JOIN Exam.Question q ON sa.QuestionID = q.QuestionID
INNER JOIN Exam.ExamQuestion eq ON e.ExamID = eq.ExamID AND q.QuestionID = eq.QuestionID
LEFT JOIN Exam.QuestionOption qo ON sa.SelectedOptionID = qo.OptionID;
GO

-- =============================================
-- View: VW_CourseEnrollment
-- Description: Student course enrollments with grades
-- =============================================
CREATE OR ALTER VIEW Academic.VW_CourseEnrollment
AS
SELECT 
    sc.StudentCourseID,
    s.StudentID,
    u.FirstName + ' ' + u.LastName AS StudentName,
    c.CourseID,
    c.CourseName,
    c.CourseCode,
    c.MaxDegree,
    c.MinDegree,
    sc.EnrollmentDate,
    sc.CompletionDate,
    sc.FinalGrade,
    sc.IsPassed,
    CASE 
        WHEN sc.FinalGrade >= 90 THEN 'A'
        WHEN sc.FinalGrade >= 85 THEN 'A-'
        WHEN sc.FinalGrade >= 80 THEN 'B+'
        WHEN sc.FinalGrade >= 75 THEN 'B'
        WHEN sc.FinalGrade >= 70 THEN 'B-'
        WHEN sc.FinalGrade >= 65 THEN 'C+'
        WHEN sc.FinalGrade >= 60 THEN 'C'
        WHEN sc.FinalGrade >= 50 THEN 'D'
        ELSE 'F'
    END AS LetterGrade
FROM Academic.StudentCourse sc
INNER JOIN Academic.Student s ON sc.StudentID = s.StudentID
INNER JOIN Security.[User] u ON s.UserID = u.UserID
INNER JOIN Academic.Course c ON sc.CourseID = c.CourseID;
GO

-- =============================================
-- View: VW_InstructorCourseAssignment
-- Description: Instructor course assignments
-- =============================================
CREATE OR ALTER VIEW Academic.VW_InstructorCourseAssignment
AS
SELECT 
    ci.CourseInstructorID,
    i.InstructorID,
    u.FirstName + ' ' + u.LastName AS InstructorName,
    c.CourseID,
    c.CourseName,
    c.CourseCode,
    ik.IntakeID,
    ik.IntakeName,
    b.BranchID,
    b.BranchName,
    t.TrackID,
    t.TrackName,
    ci.AssignedDate,
    ci.IsActive,
    (SELECT COUNT(*) FROM Academic.StudentCourse sc
     INNER JOIN Academic.Student s ON sc.StudentID = s.StudentID
     WHERE sc.CourseID = ci.CourseID 
        AND s.IntakeID = ci.IntakeID 
        AND s.BranchID = ci.BranchID 
        AND s.TrackID = ci.TrackID
    ) AS StudentCount
FROM Academic.CourseInstructor ci
INNER JOIN Academic.Instructor i ON ci.InstructorID = i.InstructorID
INNER JOIN Security.[User] u ON i.UserID = u.UserID
INNER JOIN Academic.Course c ON ci.CourseID = c.CourseID
INNER JOIN Academic.Intake ik ON ci.IntakeID = ik.IntakeID
INNER JOIN Academic.Branch b ON ci.BranchID = b.BranchID
INNER JOIN Academic.Track t ON ci.TrackID = t.TrackID;
GO

-- =============================================
-- View: VW_PendingGrading
-- Description: Answers pending manual grading
-- =============================================
CREATE OR ALTER VIEW Exam.VW_PendingGrading
AS
SELECT 
    sa.StudentAnswerID,
    e.InstructorID,
    ui.FirstName + ' ' + ui.LastName AS InstructorName,
    s.StudentID,
    us.FirstName + ' ' + us.LastName AS StudentName,
    e.ExamID,
    e.ExamName,
    c.CourseName,
    q.QuestionID,
    q.QuestionText,
    q.QuestionType,
    sa.StudentAnswerText,
    eq.QuestionMarks AS MaxMarks,
    sa.AnsweredDate,
    (SELECT CorrectAnswer FROM Exam.QuestionAnswer WHERE QuestionID = q.QuestionID) AS ModelAnswer
FROM Exam.StudentAnswer sa
INNER JOIN Exam.StudentExam se ON sa.StudentExamID = se.StudentExamID
INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
INNER JOIN Security.[User] us ON s.UserID = us.UserID
INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
INNER JOIN Academic.Instructor i ON e.InstructorID = i.InstructorID
INNER JOIN Security.[User] ui ON i.UserID = ui.UserID
INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
INNER JOIN Exam.Question q ON sa.QuestionID = q.QuestionID
INNER JOIN Exam.ExamQuestion eq ON e.ExamID = eq.ExamID AND q.QuestionID = eq.QuestionID
WHERE sa.NeedsManualGrading = 1 
    AND sa.MarksObtained IS NULL;
GO

-- =============================================
-- View: VW_ExamStatistics
-- Description: Statistical view of all exams
-- =============================================
CREATE OR ALTER VIEW Exam.VW_ExamStatistics
AS
SELECT 
    e.ExamID,
    e.ExamName,
    c.CourseName,
    e.TotalMarks,
    e.PassMarks,
    COUNT(DISTINCT se.StudentID) AS TotalStudents,
    SUM(CASE WHEN se.SubmissionTime IS NOT NULL THEN 1 ELSE 0 END) AS CompletedCount,
    SUM(CASE WHEN se.IsPassed = 1 THEN 1 ELSE 0 END) AS PassedCount,
    SUM(CASE WHEN se.IsPassed = 0 THEN 1 ELSE 0 END) AS FailedCount,
    AVG(se.TotalScore) AS AverageScore,
    MAX(se.TotalScore) AS HighestScore,
    MIN(se.TotalScore) AS LowestScore,
    STDEV(se.TotalScore) AS StandardDeviation
FROM Exam.Exam e
INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
LEFT JOIN Exam.StudentExam se ON e.ExamID = se.ExamID AND se.SubmissionTime IS NOT NULL
GROUP BY 
    e.ExamID, e.ExamName, c.CourseName, e.TotalMarks, e.PassMarks;
GO

-- =============================================
-- View: VW_DashboardOverview
-- Description: System-wide statistics for dashboard
-- =============================================
CREATE OR ALTER VIEW Security.VW_DashboardOverview
AS
SELECT 
    (SELECT COUNT(*) FROM Security.[User] WHERE IsActive = 1) AS TotalActiveUsers,
    (SELECT COUNT(*) FROM Academic.Student WHERE IsActive = 1) AS TotalStudents,
    (SELECT COUNT(*) FROM Academic.Instructor WHERE IsActive = 1) AS TotalInstructors,
    (SELECT COUNT(*) FROM Academic.Course WHERE IsActive = 1) AS TotalCourses,
    (SELECT COUNT(*) FROM Exam.Exam WHERE IsActive = 1) AS TotalExams,
    (SELECT COUNT(*) FROM Exam.Question WHERE IsActive = 1) AS TotalQuestions,
    (SELECT COUNT(*) FROM Exam.StudentExam WHERE SubmissionTime IS NOT NULL) AS TotalExamsCompleted,
    (SELECT COUNT(*) FROM Academic.Branch WHERE IsActive = 1) AS TotalBranches,
    (SELECT COUNT(*) FROM Academic.Track WHERE IsActive = 1) AS TotalTracks,
    (SELECT COUNT(*) FROM Academic.Intake WHERE IsActive = 1) AS TotalIntakes,
    (SELECT COUNT(*) FROM Exam.StudentAnswer WHERE NeedsManualGrading = 1) AS PendingGrading;
GO

-- =============================================
-- View: VW_TextAnswersAnalysis (BONUS FEATURE)
-- Description: Advanced view for text answer analysis with AI-like scoring
-- Shows valid/invalid answers with similarity scores for instructor review
-- =============================================
CREATE OR ALTER VIEW Exam.VW_TextAnswersAnalysis
AS
SELECT 
    -- Student Information
    sa.StudentAnswerID,
    s.StudentID,
    u.FirstName + ' ' + u.LastName AS StudentName,
    u.Email AS StudentEmail,
    
    -- Exam Information
    e.ExamID,
    e.ExamName,
    c.CourseID,
    c.CourseName,
    ins.InstructorID,
    ui.FirstName + ' ' + ui.LastName AS InstructorName,
    
    -- Question Information
    q.QuestionID,
    q.QuestionText,
    eq.QuestionMarks AS MaxMarks,
    
    -- Answer Content
    sa.StudentAnswerText,
    qa.CorrectAnswer AS ModelAnswer,
    qa.AnswerPattern AS RegexPattern,
    qa.CaseSensitive,
    
    -- BONUS: AI-like Similarity Analysis
    Exam.FN_TextAnswerSimilarity(sa.StudentAnswerText, qa.CorrectAnswer) AS SimilarityScore,
    
    -- Intelligent Classification
    CASE 
        WHEN Exam.FN_TextAnswerSimilarity(sa.StudentAnswerText, qa.CorrectAnswer) >= 85.0 
            THEN 'Valid - High Match'
        WHEN Exam.FN_TextAnswerSimilarity(sa.StudentAnswerText, qa.CorrectAnswer) >= 60.0 
            THEN 'Valid - Good Match'
        WHEN Exam.FN_TextAnswerSimilarity(sa.StudentAnswerText, qa.CorrectAnswer) >= 40.0 
            THEN 'Review Required - Partial Match'
        WHEN Exam.FN_TextAnswerSimilarity(sa.StudentAnswerText, qa.CorrectAnswer) >= 20.0 
            THEN 'Invalid - Low Match'
        ELSE 'Invalid - No Match'
    END AS AnswerClassification,
    
    -- Auto-suggested Marks (for instructor guidance)
    CAST(
        (Exam.FN_TextAnswerSimilarity(sa.StudentAnswerText, qa.CorrectAnswer) / 100.0) * eq.QuestionMarks
    AS DECIMAL(5,2)) AS SuggestedMarks,
    
    -- Grading Status
    sa.MarksObtained AS AssignedMarks,
    sa.IsCorrect,
    sa.NeedsManualGrading,
    sa.InstructorComments,
    sa.AnsweredDate,
    sa.GradedDate,
    
    -- Analysis Metrics
    LEN(LTRIM(RTRIM(sa.StudentAnswerText))) AS AnswerLength,
    LEN(LTRIM(RTRIM(qa.CorrectAnswer))) AS ModelAnswerLength,
    
    -- Keyword Matching Count
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
    
    -- Time Metrics
    DATEDIFF(HOUR, sa.AnsweredDate, GETDATE()) AS HoursWaiting,
    CASE 
        WHEN sa.MarksObtained IS NULL AND sa.NeedsManualGrading = 1 
        THEN 1 ELSE 0 
    END AS IsPendingGrading,
    
    -- Priority Score (for sorting)
    CASE 
        WHEN sa.MarksObtained IS NULL AND sa.NeedsManualGrading = 1 
        THEN DATEDIFF(HOUR, sa.AnsweredDate, GETDATE()) * 10
        ELSE 0
    END AS GradingPriorityScore

FROM Exam.StudentAnswer sa
INNER JOIN Exam.StudentExam se ON sa.StudentExamID = se.StudentExamID
INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
INNER JOIN Security.[User] u ON s.UserID = u.UserID
INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
INNER JOIN Academic.Instructor ins ON e.InstructorID = ins.InstructorID
INNER JOIN Security.[User] ui ON ins.UserID = ui.UserID
INNER JOIN Exam.Question q ON sa.QuestionID = q.QuestionID
INNER JOIN Exam.ExamQuestion eq ON e.ExamID = eq.ExamID AND q.QuestionID = eq.QuestionID
LEFT JOIN Exam.QuestionAnswer qa ON q.QuestionID = qa.QuestionID

WHERE q.QuestionType = 'Text'
    AND sa.StudentAnswerText IS NOT NULL
    AND LTRIM(RTRIM(sa.StudentAnswerText)) != '';
GO

PRINT 'All views created successfully!';
GO
