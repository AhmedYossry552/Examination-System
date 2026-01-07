/*=============================================
  Examination System - Utility Procedures for API
  Description: Pagination, Search, and API-specific utilities
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Procedure: SP_GetStudents_Paginated
-- Description: Gets students with pagination for API
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_GetStudents_Paginated
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @IntakeID INT = NULL,
    @BranchID INT = NULL,
    @TrackID INT = NULL,
    @SortBy NVARCHAR(50) = 'StudentID',
    @SortOrder NVARCHAR(4) = 'ASC',
    @TotalRecords INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get total count
    SELECT @TotalRecords = COUNT(*)
    FROM Academic.Student s
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    WHERE (@SearchTerm IS NULL OR 
           u.FirstName LIKE '%' + @SearchTerm + '%' OR 
           u.LastName LIKE '%' + @SearchTerm + '%' OR
           u.Email LIKE '%' + @SearchTerm + '%')
        AND (@IntakeID IS NULL OR s.IntakeID = @IntakeID)
        AND (@BranchID IS NULL OR s.BranchID = @BranchID)
        AND (@TrackID IS NULL OR s.TrackID = @TrackID)
        AND s.IsActive = 1;
    
    -- Get paginated results
    SELECT 
        s.StudentID,
        u.Username,
        u.Email,
        u.FirstName,
        u.LastName,
        u.FullName,
        u.PhoneNumber,
        s.EnrollmentDate,
        s.GPA,
        i.IntakeName,
        b.BranchName,
        t.TrackName,
        (SELECT COUNT(*) FROM Academic.StudentCourse WHERE StudentID = s.StudentID) AS CoursesEnrolled,
        @TotalRecords AS TotalRecords,
        CEILING(CAST(@TotalRecords AS FLOAT) / @PageSize) AS TotalPages,
        @PageNumber AS CurrentPage
    FROM Academic.Student s
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    INNER JOIN Academic.Intake i ON s.IntakeID = i.IntakeID
    INNER JOIN Academic.Branch b ON s.BranchID = b.BranchID
    INNER JOIN Academic.Track t ON s.TrackID = t.TrackID
    WHERE (@SearchTerm IS NULL OR 
           u.FirstName LIKE '%' + @SearchTerm + '%' OR 
           u.LastName LIKE '%' + @SearchTerm + '%' OR
           u.Email LIKE '%' + @SearchTerm + '%')
        AND (@IntakeID IS NULL OR s.IntakeID = @IntakeID)
        AND (@BranchID IS NULL OR s.BranchID = @BranchID)
        AND (@TrackID IS NULL OR s.TrackID = @TrackID)
        AND s.IsActive = 1
    ORDER BY 
        CASE WHEN @SortBy = 'StudentID' AND @SortOrder = 'ASC' THEN s.StudentID END ASC,
        CASE WHEN @SortBy = 'StudentID' AND @SortOrder = 'DESC' THEN s.StudentID END DESC,
        CASE WHEN @SortBy = 'Name' AND @SortOrder = 'ASC' THEN u.FirstName END ASC,
        CASE WHEN @SortBy = 'Name' AND @SortOrder = 'DESC' THEN u.FirstName END DESC,
        CASE WHEN @SortBy = 'Email' AND @SortOrder = 'ASC' THEN u.Email END ASC,
        CASE WHEN @SortBy = 'Email' AND @SortOrder = 'DESC' THEN u.Email END DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- =============================================
-- Procedure: SP_GetExams_Paginated
-- Description: Gets exams with pagination and filters
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_GetExams_Paginated
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @CourseID INT = NULL,
    @InstructorID INT = NULL,
    @ExamType NVARCHAR(20) = NULL,
    @ExamStatus NVARCHAR(20) = NULL, -- Upcoming, Active, Expired
    @SortBy NVARCHAR(50) = 'StartDateTime',
    @SortOrder NVARCHAR(4) = 'DESC',
    @TotalRecords INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get total count
    SELECT @TotalRecords = COUNT(*)
    FROM Exam.Exam e
    WHERE (@SearchTerm IS NULL OR e.ExamName LIKE '%' + @SearchTerm + '%')
        AND (@CourseID IS NULL OR e.CourseID = @CourseID)
        AND (@InstructorID IS NULL OR e.InstructorID = @InstructorID)
        AND (@ExamType IS NULL OR e.ExamType = @ExamType)
        AND (@ExamStatus IS NULL OR 
            (@ExamStatus = 'Upcoming' AND GETDATE() < e.StartDateTime) OR
            (@ExamStatus = 'Active' AND GETDATE() BETWEEN e.StartDateTime AND e.EndDateTime) OR
            (@ExamStatus = 'Expired' AND GETDATE() > e.EndDateTime))
        AND e.IsActive = 1;
    
    -- Get paginated results
    SELECT 
        e.ExamID,
        e.ExamName,
        e.ExamType,
        c.CourseName,
        u.FirstName + ' ' + u.LastName AS InstructorName,
        e.TotalMarks,
        e.PassMarks,
        e.DurationMinutes,
        e.StartDateTime,
        e.EndDateTime,
        (SELECT COUNT(*) FROM Exam.ExamQuestion WHERE ExamID = e.ExamID) AS QuestionCount,
        (SELECT COUNT(*) FROM Exam.StudentExam WHERE ExamID = e.ExamID) AS StudentsAssigned,
        (SELECT COUNT(*) FROM Exam.StudentExam WHERE ExamID = e.ExamID AND SubmissionTime IS NOT NULL) AS SubmissionsReceived,
        CASE 
            WHEN GETDATE() < e.StartDateTime THEN 'Upcoming'
            WHEN GETDATE() > e.EndDateTime THEN 'Expired'
            ELSE 'Active'
        END AS ExamStatus,
        @TotalRecords AS TotalRecords,
        CEILING(CAST(@TotalRecords AS FLOAT) / @PageSize) AS TotalPages,
        @PageNumber AS CurrentPage
    FROM Exam.Exam e
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    INNER JOIN Academic.Instructor i ON e.InstructorID = i.InstructorID
    INNER JOIN Security.[User] u ON i.UserID = u.UserID
    WHERE (@SearchTerm IS NULL OR e.ExamName LIKE '%' + @SearchTerm + '%')
        AND (@CourseID IS NULL OR e.CourseID = @CourseID)
        AND (@InstructorID IS NULL OR e.InstructorID = @InstructorID)
        AND (@ExamType IS NULL OR e.ExamType = @ExamType)
        AND (@ExamStatus IS NULL OR 
            (@ExamStatus = 'Upcoming' AND GETDATE() < e.StartDateTime) OR
            (@ExamStatus = 'Active' AND GETDATE() BETWEEN e.StartDateTime AND e.EndDateTime) OR
            (@ExamStatus = 'Expired' AND GETDATE() > e.EndDateTime))
        AND e.IsActive = 1
    ORDER BY 
        CASE WHEN @SortBy = 'StartDateTime' AND @SortOrder = 'ASC' THEN e.StartDateTime END ASC,
        CASE WHEN @SortBy = 'StartDateTime' AND @SortOrder = 'DESC' THEN e.StartDateTime END DESC,
        CASE WHEN @SortBy = 'ExamName' AND @SortOrder = 'ASC' THEN e.ExamName END ASC,
        CASE WHEN @SortBy = 'ExamName' AND @SortOrder = 'DESC' THEN e.ExamName END DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- =============================================
-- Procedure: SP_GetQuestions_Paginated
-- Description: Gets questions with pagination for question bank
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_GetQuestions_Paginated
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @SearchTerm NVARCHAR(100) = NULL,
    @CourseID INT = NULL,
    @QuestionType NVARCHAR(20) = NULL,
    @DifficultyLevel NVARCHAR(20) = NULL,
    @InstructorID INT = NULL,
    @SortBy NVARCHAR(50) = 'CreatedDate',
    @SortOrder NVARCHAR(4) = 'DESC',
    @TotalRecords INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT @TotalRecords = COUNT(*)
    FROM Exam.Question q
    WHERE (@SearchTerm IS NULL OR q.QuestionText LIKE '%' + @SearchTerm + '%')
        AND (@CourseID IS NULL OR q.CourseID = @CourseID)
        AND (@QuestionType IS NULL OR q.QuestionType = @QuestionType)
        AND (@DifficultyLevel IS NULL OR q.DifficultyLevel = @DifficultyLevel)
        AND (@InstructorID IS NULL OR q.InstructorID = @InstructorID)
        AND q.IsActive = 1;
    
    SELECT 
        q.QuestionID,
        q.QuestionText,
        q.QuestionType,
        q.DifficultyLevel,
        q.Points,
        c.CourseName,
        u.FirstName + ' ' + u.LastName AS CreatorName,
        q.CreatedDate,
        (SELECT COUNT(*) FROM Exam.ExamQuestion WHERE QuestionID = q.QuestionID) AS UsedInExams,
        @TotalRecords AS TotalRecords,
        CEILING(CAST(@TotalRecords AS FLOAT) / @PageSize) AS TotalPages,
        @PageNumber AS CurrentPage
    FROM Exam.Question q
    INNER JOIN Academic.Course c ON q.CourseID = c.CourseID
    INNER JOIN Academic.Instructor i ON q.InstructorID = i.InstructorID
    INNER JOIN Security.[User] u ON i.UserID = u.UserID
    WHERE (@SearchTerm IS NULL OR q.QuestionText LIKE '%' + @SearchTerm + '%')
        AND (@CourseID IS NULL OR q.CourseID = @CourseID)
        AND (@QuestionType IS NULL OR q.QuestionType = @QuestionType)
        AND (@DifficultyLevel IS NULL OR q.DifficultyLevel = @DifficultyLevel)
        AND (@InstructorID IS NULL OR q.InstructorID = @InstructorID)
        AND q.IsActive = 1
    ORDER BY 
        CASE WHEN @SortBy = 'CreatedDate' AND @SortOrder = 'ASC' THEN q.CreatedDate END ASC,
        CASE WHEN @SortBy = 'CreatedDate' AND @SortOrder = 'DESC' THEN q.CreatedDate END DESC,
        CASE WHEN @SortBy = 'DifficultyLevel' AND @SortOrder = 'ASC' THEN q.DifficultyLevel END ASC,
        CASE WHEN @SortBy = 'DifficultyLevel' AND @SortOrder = 'DESC' THEN q.DifficultyLevel END DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- =============================================
-- Procedure: SP_GetLookupData
-- Description: Returns all lookup data for dropdowns in one call
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetLookupData
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Branches
    SELECT BranchID AS Value, BranchName AS Label, 'Branch' AS Type
    FROM Academic.Branch WHERE IsActive = 1;
    
    -- Tracks
    SELECT TrackID AS Value, TrackName AS Label, BranchID AS ParentId, 'Track' AS Type
    FROM Academic.Track WHERE IsActive = 1;
    
    -- Intakes
    SELECT IntakeID AS Value, IntakeName AS Label, 'Intake' AS Type
    FROM Academic.Intake WHERE IsActive = 1
    ORDER BY IntakeYear DESC, IntakeNumber DESC;
    
    -- Courses
    SELECT CourseID AS Value, CourseName AS Label, CourseCode AS Code, 'Course' AS Type
    FROM Academic.Course WHERE IsActive = 1;
    
    -- Question Types
    SELECT 'MultipleChoice' AS Value, 'Multiple Choice' AS Label, 'QuestionType' AS Type
    UNION ALL SELECT 'TrueFalse', 'True/False', 'QuestionType'
    UNION ALL SELECT 'Text', 'Text Answer', 'QuestionType';
    
    -- Difficulty Levels
    SELECT 'Easy' AS Value, 'Easy' AS Label, 'DifficultyLevel' AS Type
    UNION ALL SELECT 'Medium', 'Medium', 'DifficultyLevel'
    UNION ALL SELECT 'Hard', 'Hard', 'DifficultyLevel';
    
    -- Exam Types
    SELECT 'Regular' AS Value, 'Regular' AS Label, 'ExamType' AS Type
    UNION ALL SELECT 'Corrective', 'Corrective', 'ExamType';
END
GO

-- =============================================
-- Procedure: SP_GetDashboardStats
-- Description: Returns comprehensive dashboard statistics
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetDashboardStats
    @UserID INT,
    @UserType NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @UserType = 'Admin' OR @UserType = 'TrainingManager'
    BEGIN
        -- Admin/Manager Dashboard
        SELECT 
            'TotalStudents' AS StatType,
            COUNT(*) AS Value,
            'Students' AS Label
        FROM Academic.Student WHERE IsActive = 1
        UNION ALL
        SELECT 'TotalInstructors', COUNT(*), 'Instructors'
        FROM Academic.Instructor WHERE IsActive = 1
        UNION ALL
        SELECT 'TotalCourses', COUNT(*), 'Courses'
        FROM Academic.Course WHERE IsActive = 1
        UNION ALL
        SELECT 'TotalExams', COUNT(*), 'Exams'
        FROM Exam.Exam WHERE IsActive = 1
        UNION ALL
        SELECT 'ActiveExams', COUNT(*), 'Active Exams'
        FROM Exam.Exam 
        WHERE GETDATE() BETWEEN StartDateTime AND EndDateTime AND IsActive = 1
        UNION ALL
        SELECT 'PendingGrading', COUNT(*), 'Pending Grading'
        FROM Exam.StudentAnswer WHERE NeedsManualGrading = 1;
    END
    ELSE IF @UserType = 'Instructor'
    BEGIN
        -- Instructor Dashboard
        DECLARE @InstructorID INT;
        SELECT @InstructorID = InstructorID FROM Academic.Instructor WHERE UserID = @UserID;
        
        SELECT 
            'MyCourses' AS StatType,
            COUNT(DISTINCT CourseID) AS Value,
            'My Courses' AS Label
        FROM Academic.CourseInstructor WHERE InstructorID = @InstructorID AND IsActive = 1
        UNION ALL
        SELECT 'MyExams', COUNT(*), 'My Exams'
        FROM Exam.Exam WHERE InstructorID = @InstructorID AND IsActive = 1
        UNION ALL
        SELECT 'MyQuestions', COUNT(*), 'My Questions'
        FROM Exam.Question WHERE InstructorID = @InstructorID AND IsActive = 1
        UNION ALL
        SELECT 'PendingGrading', COUNT(*), 'Pending Grading'
        FROM Exam.StudentAnswer sa
        INNER JOIN Exam.StudentExam se ON sa.StudentExamID = se.StudentExamID
        INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
        WHERE e.InstructorID = @InstructorID AND sa.NeedsManualGrading = 1;
    END
    ELSE IF @UserType = 'Student'
    BEGIN
        -- Student Dashboard
        DECLARE @StudentID INT;
        SELECT @StudentID = StudentID FROM Academic.Student WHERE UserID = @UserID;
        
        SELECT 
            'EnrolledCourses' AS StatType,
            COUNT(*) AS Value,
            'Enrolled Courses' AS Label
        FROM Academic.StudentCourse WHERE StudentID = @StudentID
        UNION ALL
        SELECT 'CompletedExams', COUNT(*), 'Completed Exams'
        FROM Exam.StudentExam 
        WHERE StudentID = @StudentID AND SubmissionTime IS NOT NULL
        UNION ALL
        SELECT 'UpcomingExams', COUNT(*), 'Upcoming Exams'
        FROM Exam.StudentExam se
        INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
        WHERE se.StudentID = @StudentID 
            AND se.IsAllowed = 1 
            AND se.SubmissionTime IS NULL
            AND GETDATE() < e.EndDateTime
        UNION ALL
        SELECT 'AverageScore', CAST(AVG(TotalScore) AS INT), 'Average Score'
        FROM Exam.StudentExam 
        WHERE StudentID = @StudentID AND IsGraded = 1;
    END
END
GO

-- =============================================
-- Procedure: SP_SearchGlobal
-- Description: Global search across all entities
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_SearchGlobal
    @SearchTerm NVARCHAR(100),
    @UserType NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Search Students
    IF @UserType IN ('Admin', 'TrainingManager', 'Instructor')
    BEGIN
        SELECT TOP 5
            'Student' AS EntityType,
            StudentID AS EntityID,
            u.FirstName + ' ' + u.LastName AS Title,
            u.Email AS Subtitle,
            'student' AS Icon
        FROM Academic.Student s
        INNER JOIN Security.[User] u ON s.UserID = u.UserID
        WHERE (u.FirstName LIKE '%' + @SearchTerm + '%' 
            OR u.LastName LIKE '%' + @SearchTerm + '%'
            OR u.Email LIKE '%' + @SearchTerm + '%')
            AND s.IsActive = 1;
    END
    
    -- Search Courses
    SELECT TOP 5
        'Course' AS EntityType,
        CourseID AS EntityID,
        CourseName AS Title,
        CourseCode AS Subtitle,
        'course' AS Icon
    FROM Academic.Course
    WHERE (CourseName LIKE '%' + @SearchTerm + '%' 
        OR CourseCode LIKE '%' + @SearchTerm + '%')
        AND IsActive = 1;
    
    -- Search Exams
    SELECT TOP 5
        'Exam' AS EntityType,
        ExamID AS EntityID,
        ExamName AS Title,
        CONVERT(VARCHAR, StartDateTime, 106) AS Subtitle,
        'exam' AS Icon
    FROM Exam.Exam
    WHERE ExamName LIKE '%' + @SearchTerm + '%'
        AND IsActive = 1;
END
GO

PRINT 'Utility procedures for API created successfully!';
GO
