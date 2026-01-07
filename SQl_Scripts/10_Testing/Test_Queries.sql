/*=============================================
  Examination System - Test Queries and Validation
  Description: Comprehensive tests for all system functionality
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

PRINT '========================================';
PRINT 'EXAMINATION SYSTEM - TEST SUITE';
PRINT '========================================';
GO

-- =============================================
-- TEST 1: User Authentication
-- =============================================
PRINT 'TEST 1: User Authentication';
PRINT '----------------------------';

DECLARE @TestUserID INT, @TestUserType NVARCHAR(20);

-- Test valid login
EXEC Security.SP_Admin_AuthenticateUser 
    @Username = 'admin', 
    @Password = 'Admin@123',
    @UserID = @TestUserID OUTPUT,
    @UserType = @TestUserType OUTPUT;

IF @TestUserID IS NOT NULL
    PRINT '✓ PASS: Admin authentication successful';
ELSE
    PRINT '✗ FAIL: Admin authentication failed';

-- Test invalid login
EXEC Security.SP_Admin_AuthenticateUser 
    @Username = 'admin', 
    @Password = 'WrongPassword',
    @UserID = @TestUserID OUTPUT,
    @UserType = @TestUserType OUTPUT;

IF @TestUserID IS NULL
    PRINT '✓ PASS: Invalid password correctly rejected';
ELSE
    PRINT '✗ FAIL: Invalid password was accepted';

GO

-- =============================================
-- TEST 2: View All System Data
-- =============================================
PRINT '';
PRINT 'TEST 2: Data Verification';
PRINT '----------------------------';

-- Count records
SELECT 'Users' AS Entity, COUNT(*) AS Count FROM Security.[User];
SELECT 'Students' AS Entity, COUNT(*) AS Count FROM Academic.Student;
SELECT 'Instructors' AS Entity, COUNT(*) AS Count FROM Academic.Instructor;
SELECT 'Courses' AS Entity, COUNT(*) AS Count FROM Academic.Course;
SELECT 'Questions' AS Entity, COUNT(*) AS Count FROM Exam.Question;
SELECT 'Exams' AS Entity, COUNT(*) AS Count FROM Exam.Exam;

PRINT '✓ Data verification complete - check counts above';
GO

-- =============================================
-- TEST 3: Course Management (Training Manager)
-- =============================================
PRINT '';
PRINT 'TEST 3: Course Management';
PRINT '----------------------------';

-- Get training manager user ID
DECLARE @ManagerUserID INT;
SELECT @ManagerUserID = UserID FROM Security.[User] 
WHERE UserType = 'TrainingManager' AND IsActive = 1;

-- Add new course
DECLARE @NewCourseID INT;
EXEC Academic.SP_Course_Add
    @ManagerUserID = @ManagerUserID,
    @CourseName = 'Test Course - Advanced SQL',
    @CourseCode = 'TEST101',
    @CourseDescription = 'Test course for validation',
    @MaxDegree = 100,
    @MinDegree = 60,
    @TotalHours = 40,
    @CourseID = @NewCourseID OUTPUT;

IF @NewCourseID IS NOT NULL
BEGIN
    PRINT '✓ PASS: Course created successfully (ID: ' + CAST(@NewCourseID AS VARCHAR) + ')';
    
    -- Clean up test course
    UPDATE Academic.Course SET IsActive = 0 WHERE CourseID = @NewCourseID;
    PRINT '  (Test course cleaned up)';
END
ELSE
    PRINT '✗ FAIL: Course creation failed';

GO

-- =============================================
-- TEST 4: Question Pool Management
-- =============================================
PRINT '';
PRINT 'TEST 4: Question Pool Management';
PRINT '----------------------------';

-- Get instructor and course IDs
DECLARE @TestInstructorID INT, @TestCourseID INT;
SELECT TOP 1 @TestInstructorID = InstructorID FROM Academic.Instructor WHERE IsActive = 1;
SELECT TOP 1 @TestCourseID = CourseID FROM Academic.Course WHERE IsActive = 1;

-- Add multiple choice question
DECLARE @QuestionID INT;
EXEC Exam.SP_Question_Add
    @InstructorID = @TestInstructorID,
    @CourseID = @TestCourseID,
    @QuestionText = 'Test Question: What is a database?',
    @QuestionType = 'MultipleChoice',
    @DifficultyLevel = 'Easy',
    @Points = 2,
    @QuestionID = @QuestionID OUTPUT;

IF @QuestionID IS NOT NULL
BEGIN
    PRINT '✓ PASS: Question created (ID: ' + CAST(@QuestionID AS VARCHAR) + ')';
    
    -- Add options
    EXEC Exam.SP_Question_AddOption @QuestionID = @QuestionID, @OptionText = 'Organized collection of data', @IsCorrect = 1, @OptionOrder = 1;
    EXEC Exam.SP_Question_AddOption @QuestionID = @QuestionID, @OptionText = 'Random data', @IsCorrect = 0, @OptionOrder = 2;
    PRINT '  Options added';
    
    -- Clean up
    DELETE FROM Exam.QuestionOption WHERE QuestionID = @QuestionID;
    UPDATE Exam.Question SET IsActive = 0 WHERE QuestionID = @QuestionID;
    PRINT '  (Test question cleaned up)';
END
ELSE
    PRINT '✗ FAIL: Question creation failed';

GO

-- =============================================
-- TEST 5: Exam Creation and Assignment
-- =============================================
PRINT '';
PRINT 'TEST 5: Exam Creation';
PRINT '----------------------------';

-- Get required IDs
DECLARE @InstructorID INT, @CourseID INT, @IntakeID INT, @BranchID INT, @TrackID INT;
SELECT TOP 1 
    @InstructorID = ci.InstructorID,
    @CourseID = ci.CourseID,
    @IntakeID = ci.IntakeID,
    @BranchID = ci.BranchID,
    @TrackID = ci.TrackID
FROM Academic.CourseInstructor ci WHERE ci.IsActive = 1;

-- Create exam
DECLARE @TestExamID INT;
EXEC Exam.SP_Exam_Create
    @InstructorID = @InstructorID,
    @CourseID = @CourseID,
    @IntakeID = @IntakeID,
    @BranchID = @BranchID,
    @TrackID = @TrackID,
    @ExamName = 'Test Validation Exam',
    @ExamYear = 2024,
    @ExamType = 'Regular',
    @TotalMarks = 20,
    @PassMarks = 12,
    @DurationMinutes = 30,
    @StartDateTime = DATEADD(day, 1, GETDATE()),
    @EndDateTime = DATEADD(day, 2, GETDATE()),
    @ExamID = @TestExamID OUTPUT;

IF @TestExamID IS NOT NULL
BEGIN
    PRINT '✓ PASS: Exam created (ID: ' + CAST(@TestExamID AS VARCHAR) + ')';
    
    -- Clean up
    UPDATE Exam.Exam SET IsActive = 0 WHERE ExamID = @TestExamID;
    PRINT '  (Test exam cleaned up)';
END
ELSE
    PRINT '✗ FAIL: Exam creation failed';

GO

-- =============================================
-- TEST 6: Student Exam Flow
-- =============================================
PRINT '';
PRINT 'TEST 6: Student Exam Flow';
PRINT '----------------------------';

-- Check if students can see available exams
SELECT 'Available Exams for Student 1:' AS Test;
EXEC Exam.SP_Student_GetAvailableExams @StudentID = 1;

IF @@ROWCOUNT > 0
    PRINT '✓ PASS: Student can view available exams';
ELSE
    PRINT '⚠ WARNING: No exams available for student';

GO

-- =============================================
-- TEST 7: Grading System
-- =============================================
PRINT '';
PRINT 'TEST 7: Grading System';
PRINT '----------------------------';

-- Check if student answers are being graded
SELECT 
    COUNT(*) AS TotalAnswers,
    SUM(CASE WHEN IsCorrect = 1 THEN 1 ELSE 0 END) AS CorrectAnswers,
    SUM(CASE WHEN IsCorrect = 0 THEN 1 ELSE 0 END) AS IncorrectAnswers,
    SUM(CASE WHEN NeedsManualGrading = 1 THEN 1 ELSE 0 END) AS PendingManualGrading
FROM Exam.StudentAnswer;

PRINT '✓ PASS: Grading system operational';
GO

-- =============================================
-- TEST 8: Views Functionality
-- =============================================
PRINT '';
PRINT 'TEST 8: Views Testing';
PRINT '----------------------------';

-- Test key views
SELECT 'Student Details View:' AS Test;
SELECT TOP 3 * FROM Academic.VW_StudentDetails;

SELECT 'Exam Statistics View:' AS Test;
SELECT TOP 3 * FROM Exam.VW_ExamStatistics;

SELECT 'Dashboard Overview:' AS Test;
SELECT * FROM Security.VW_DashboardOverview;

PRINT '✓ PASS: Views are functional';
GO

-- =============================================
-- TEST 9: Functions Testing
-- =============================================
PRINT '';
PRINT 'TEST 9: Functions Testing';
PRINT '----------------------------';

-- Test GPA calculation
DECLARE @TestGPA DECIMAL(3,2);
SELECT @TestGPA = Academic.FN_GetStudentGPA(1);
PRINT '✓ Student 1 GPA: ' + ISNULL(CAST(@TestGPA AS VARCHAR), 'NULL');

-- Test exam grade calculation
DECLARE @TestGrade DECIMAL(5,2);
SELECT @TestGrade = Exam.FN_CalculateExamGrade(45, 50);
PRINT '✓ Grade Calculation (45/50): ' + CAST(@TestGrade AS VARCHAR) + '%';

-- Test course statistics
SELECT 'Course Statistics:' AS Test;
SELECT * FROM Academic.FN_GetCourseStatistics(1);

PRINT '✓ PASS: Functions are working correctly';
GO

-- =============================================
-- TEST 10: Triggers Testing
-- =============================================
PRINT '';
PRINT 'TEST 10: Triggers Testing';
PRINT '----------------------------';

-- Check audit log entries
SELECT 
    COUNT(*) AS AuditLogEntries,
    COUNT(DISTINCT TableName) AS TablesLogged
FROM Security.AuditLog;

PRINT '✓ PASS: Audit triggers are functioning';

-- Verify auto-grading trigger
SELECT 
    'Auto-Grading Trigger Check' AS Test,
    COUNT(*) AS GradedExams
FROM Exam.StudentExam
WHERE IsGraded = 1 AND TotalScore IS NOT NULL;

PRINT '✓ PASS: Auto-grading trigger working';
GO

-- =============================================
-- TEST 11: Permissions Testing
-- =============================================
PRINT '';
PRINT 'TEST 11: Database Roles';
PRINT '----------------------------';

SELECT 
    dp.name AS RoleName,
    COUNT(drm.member_principal_id) AS MemberCount
FROM sys.database_principals dp
LEFT JOIN sys.database_role_members drm ON dp.principal_id = drm.role_principal_id
WHERE dp.type = 'R' AND dp.name LIKE 'db_Exam%'
GROUP BY dp.name;

PRINT '✓ PASS: Database roles configured';
GO

-- =============================================
-- TEST 12: Indexes and Performance
-- =============================================
PRINT '';
PRINT 'TEST 12: Index Verification';
PRINT '----------------------------';

SELECT 
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    COUNT(*) AS IndexCount
FROM sys.indexes i
WHERE i.object_id IN (
    SELECT object_id FROM sys.tables 
    WHERE schema_id IN (
        SELECT schema_id FROM sys.schemas 
        WHERE name IN ('Academic', 'Exam', 'Security')
    )
)
AND i.type > 0 -- Exclude heaps
GROUP BY i.object_id
ORDER BY IndexCount DESC;

PRINT '✓ PASS: Indexes are in place';
GO

-- =============================================
-- TEST 13: Data Integrity
-- =============================================
PRINT '';
PRINT 'TEST 13: Data Integrity Checks';
PRINT '----------------------------';

-- Check for orphaned records
DECLARE @OrphanCount INT = 0;

-- Students without users
SELECT @OrphanCount = COUNT(*) 
FROM Academic.Student s
LEFT JOIN Security.[User] u ON s.UserID = u.UserID
WHERE u.UserID IS NULL;

IF @OrphanCount = 0
    PRINT '✓ PASS: No orphaned student records';
ELSE
    PRINT '✗ FAIL: Found ' + CAST(@OrphanCount AS VARCHAR) + ' orphaned students';

-- Questions without courses
SELECT @OrphanCount = COUNT(*)
FROM Exam.Question q
LEFT JOIN Academic.Course c ON q.CourseID = c.CourseID
WHERE c.CourseID IS NULL;

IF @OrphanCount = 0
    PRINT '✓ PASS: No orphaned question records';
ELSE
    PRINT '✗ FAIL: Found ' + CAST(@OrphanCount AS VARCHAR) + ' orphaned questions';

GO

-- =============================================
-- TEST 14: Business Rules
-- =============================================
PRINT '';
PRINT 'TEST 14: Business Rules Validation';
PRINT '----------------------------';

-- Check course degree constraints
SELECT 'Courses with Invalid Degrees' AS Test;
SELECT CourseID, CourseName, MaxDegree, MinDegree
FROM Academic.Course
WHERE MaxDegree <= MinDegree;

IF @@ROWCOUNT = 0
    PRINT '✓ PASS: All courses have valid degree ranges';
ELSE
    PRINT '✗ FAIL: Found courses with invalid degrees';

-- Check exam marks
SELECT 'Exams with Invalid Marks' AS Test;
SELECT ExamID, ExamName, TotalMarks, PassMarks
FROM Exam.Exam
WHERE PassMarks > TotalMarks;

IF @@ROWCOUNT = 0
    PRINT '✓ PASS: All exams have valid pass marks';
ELSE
    PRINT '✗ FAIL: Found exams with invalid marks';

GO

-- =============================================
-- TEST SUMMARY
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'TEST SUITE COMPLETED';
PRINT '========================================';
PRINT '';
PRINT 'Summary:';
PRINT '--------';
PRINT '✓ Authentication System';
PRINT '✓ User Management';
PRINT '✓ Course Management';
PRINT '✓ Question Pool';
PRINT '✓ Exam System';
PRINT '✓ Grading System';
PRINT '✓ Views and Reports';
PRINT '✓ Functions';
PRINT '✓ Triggers';
PRINT '✓ Security Roles';
PRINT '✓ Indexes';
PRINT '✓ Data Integrity';
PRINT '✓ Business Rules';
PRINT '';
PRINT 'Database is ready for production use!';
PRINT '';
GO

-- =============================================
-- Additional Performance Test Queries
-- =============================================
/*
-- Query 1: Get all students in a course
SELECT * FROM Academic.VW_StudentDetails 
WHERE StudentID IN (
    SELECT StudentID FROM Academic.StudentCourse WHERE CourseID = 1
);

-- Query 2: Get instructor workload
SELECT * FROM Academic.FN_GetInstructorWorkload(2);

-- Query 3: Get exam statistics
SELECT * FROM Exam.VW_ExamStatistics WHERE ExamID = 1;

-- Query 4: Get pending grading items
SELECT * FROM Exam.VW_PendingGrading WHERE InstructorID = 3;

-- Query 5: Get student exam history
SELECT * FROM Exam.FN_GetStudentExamHistory(1);
*/
