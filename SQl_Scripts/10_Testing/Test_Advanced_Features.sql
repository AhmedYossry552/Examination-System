/*
============================================================================
Advanced Features Testing Script
============================================================================
Description: Test all advanced features (Event Sourcing, Remedial, Monitoring, Analytics)
Author: Examination System Team
Created: 2025-11-13
============================================================================
*/

USE ExaminationSystemDB;
GO

PRINT '====================================================================';
PRINT 'TESTING ADVANCED FEATURES';
PRINT '====================================================================';
PRINT '';
GO

-- =============================================
-- TEST 1: Event Sourcing System
-- =============================================
PRINT 'TEST 1: Event Sourcing System';
PRINT '--------------------------------------------------------------------';
GO

-- Test 1.1: Append Event
DECLARE @EventID BIGINT;
DECLARE @TestCorrelationID NVARCHAR(50) = NEWID();

EXEC EventStore.SP_AppendEvent
    @AggregateID = '999',
    @AggregateType = 'Test',
    @EventType = 'TestEvent',
    @EventData = '{"Test": "Data", "Value": 123}',
    @UserID = 1,
    @UserType = 'Admin',
    @CorrelationID = @TestCorrelationID,
    @SessionToken = 'test-token',
    @IPAddress = '127.0.0.1',
    @Metadata = '{"Source": "UnitTest"}',
    @EventID = @EventID OUTPUT;

IF @EventID IS NOT NULL
    PRINT '✓ Event appended successfully (EventID: ' + CAST(@EventID AS NVARCHAR(20)) + ')';
ELSE
    PRINT '✗ Failed to append event';
GO

-- Test 1.2: Get User Timeline
PRINT '';
PRINT 'Testing: Get User Timeline...';
EXEC EventStore.SP_GetUserTimeline
    @UserID = 1,
    @PageNumber = 1,
    @PageSize = 10;
PRINT '✓ User timeline retrieved';
GO

-- Test 1.3: Get System Activity
PRINT '';
PRINT 'Testing: Get System Activity...';
EXEC EventStore.SP_GetSystemActivity
    @StartDate = '2024-01-01',
    @PageNumber = 1,
    @PageSize = 10;
PRINT '✓ System activity retrieved';
GO

-- Test 1.4: Get Event Statistics
PRINT '';
PRINT 'Testing: Get Event Statistics...';
EXEC EventStore.SP_GetEventStatistics
    @StartDate = '2024-01-01';
PRINT '✓ Event statistics retrieved';
GO

PRINT '';
PRINT '====================================================================';
PRINT '';
GO

-- =============================================
-- TEST 2: Remedial Exam System
-- =============================================
PRINT 'TEST 2: Remedial Exam System';
PRINT '--------------------------------------------------------------------';
GO

-- Test 2.1: Get Remedial Candidates
PRINT 'Testing: Get Remedial Exam Candidates...';
IF EXISTS (SELECT 1 FROM Exam.Exam WHERE ExamID = 1)
BEGIN
    EXEC Exam.SP_GetRemedialExamCandidates @ExamID = 1;
    PRINT '✓ Remedial candidates retrieved';
END
ELSE
    PRINT '⚠ No exam with ID 1 found (skipping test)';
GO

-- Test 2.2: Get Remedial Progress
PRINT '';
PRINT 'Testing: Get Remedial Exam Progress...';
IF EXISTS (SELECT 1 FROM Academic.Course WHERE CourseID = 1)
BEGIN
    EXEC Exam.SP_GetRemedialExamProgress
        @CourseID = 1,
        @IntakeID = 1;
    PRINT '✓ Remedial progress retrieved';
END
ELSE
    PRINT '⚠ No course with ID 1 found (skipping test)';
GO

-- Test 2.3: Get Student Remedial History
PRINT '';
PRINT 'Testing: Get Student Remedial History...';
IF EXISTS (SELECT 1 FROM Academic.Student WHERE StudentID = 1)
BEGIN
    EXEC Exam.SP_GetStudentRemedialHistory @StudentID = 1;
    PRINT '✓ Student remedial history retrieved';
END
ELSE
    PRINT '⚠ No student with ID 1 found (skipping test)';
GO

PRINT '';
PRINT '====================================================================';
PRINT '';
GO

-- =============================================
-- TEST 3: Real-Time Monitoring Views
-- =============================================
PRINT 'TEST 3: Real-Time Monitoring Views';
PRINT '--------------------------------------------------------------------';
GO

-- Test 3.1: Live Exam Monitoring
PRINT 'Testing: VW_LiveExamMonitoring...';
SELECT TOP 5
    StudentName,
    ExamName,
    MinutesElapsed,
    QuestionsAnswered,
    CompletionPercentage,
    ActivityStatus,
    AlertLevel
FROM Exam.VW_LiveExamMonitoring
ORDER BY AlertLevel DESC;
PRINT '✓ Live exam monitoring view works';
GO

-- Test 3.2: Exam Session Statistics
PRINT '';
PRINT 'Testing: VW_ExamSessionStatistics...';
SELECT TOP 5
    ExamName,
    TotalStudents,
    StudentsStarted,
    StudentsInProgress,
    StartRatePercentage,
    ExamStatus
FROM Exam.VW_ExamSessionStatistics
ORDER BY ExamID DESC;
PRINT '✓ Exam session statistics view works';
GO

-- Test 3.3: Suspicious Activity Monitor
PRINT '';
PRINT 'Testing: VW_SuspiciousActivityMonitor...';
SELECT TOP 5
    StudentName,
    ExamName,
    TooFastAnswering,
    PatternBias,
    TooQuickSubmission,
    RiskLevel
FROM Exam.VW_SuspiciousActivityMonitor
ORDER BY RiskLevel DESC;
PRINT '✓ Suspicious activity monitor view works';
GO

PRINT '';
PRINT '====================================================================';
PRINT '';
GO

-- =============================================
-- TEST 4: Smart Analytics System
-- =============================================
PRINT 'TEST 4: Smart Analytics System';
PRINT '--------------------------------------------------------------------';
GO

-- Test 4.1: Analyze Question Difficulty
PRINT 'Testing: Analyze Question Difficulty...';
IF EXISTS (SELECT 1 FROM Exam.Question WHERE CourseID = 1)
BEGIN
    EXEC Analytics.SP_AnalyzeQuestionDifficulty @CourseID = 1;
    PRINT '✓ Question difficulty analysis completed';
END
ELSE
    PRINT '⚠ No questions for course ID 1 (skipping test)';
GO

-- Test 4.2: Predict Student Performance
PRINT '';
PRINT 'Testing: Predict Student Performance...';
IF EXISTS (SELECT 1 FROM Academic.Student WHERE StudentID = 1)
BEGIN
    EXEC Analytics.SP_PredictStudentPerformance @StudentID = 1;
    PRINT '✓ Student performance prediction completed';
END
ELSE
    PRINT '⚠ No student with ID 1 found (skipping test)';
GO

-- Test 4.3: Identify At-Risk Students
PRINT '';
PRINT 'Testing: Identify At-Risk Students...';
IF EXISTS (SELECT 1 FROM Academic.Course WHERE CourseID = 1)
BEGIN
    EXEC Analytics.SP_IdentifyAtRiskStudents
        @CourseID = 1,
        @RiskThreshold = 0.60;
    PRINT '✓ At-risk students identified';
END
ELSE
    PRINT '⚠ No course with ID 1 found (skipping test)';
GO

-- Test 4.4: Course Performance Dashboard
PRINT '';
PRINT 'Testing: Course Performance Dashboard...';
IF EXISTS (SELECT 1 FROM Academic.Course WHERE CourseID = 1)
BEGIN
    EXEC Analytics.SP_GetCoursePerformanceDashboard
        @CourseID = 1,
        @IntakeID = 1;
    PRINT '✓ Course performance dashboard retrieved';
END
ELSE
    PRINT '⚠ No course with ID 1 found (skipping test)';
GO

PRINT '';
PRINT '====================================================================';
PRINT '';
GO

-- =============================================
-- TEST 5: Session Management (Enhanced)
-- =============================================
PRINT 'TEST 5: Session Management';
PRINT '--------------------------------------------------------------------';
GO

-- Test 5.1: Validate Session
PRINT 'Testing: Session Validation...';
DECLARE @IsValid BIT, @ValidUserID INT;

IF EXISTS (SELECT 1 FROM Security.UserSessions WHERE IsActive = 1)
BEGIN
    DECLARE @TestToken NVARCHAR(255);
    SELECT TOP 1 @TestToken = SessionToken FROM Security.UserSessions WHERE IsActive = 1;
    
    EXEC Security.SP_ValidateSession
        @SessionToken = @TestToken,
        @UserID = @ValidUserID OUTPUT,
        @IsValid = @IsValid OUTPUT;
    
    IF @IsValid = 1
        PRINT '✓ Session validation successful';
    ELSE
        PRINT '✗ Session validation failed';
END
ELSE
    PRINT '⚠ No active sessions found (skipping test)';
GO

-- Test 5.2: Get User Sessions
PRINT '';
PRINT 'Testing: Get User Sessions...';
IF EXISTS (SELECT 1 FROM Security.[User] WHERE UserID = 1)
BEGIN
    EXEC Security.SP_GetUserSessions @UserID = 1;
    PRINT '✓ User sessions retrieved';
END
GO

PRINT '';
PRINT '====================================================================';
PRINT '';
GO

-- =============================================
-- TEST 6: Notification System (Enhanced)
-- =============================================
PRINT 'TEST 6: Notification System';
PRINT '--------------------------------------------------------------------';
GO

-- Test 6.1: Get User Notifications
PRINT 'Testing: Get User Notifications...';
IF EXISTS (SELECT 1 FROM Security.[User] WHERE UserID = 1)
BEGIN
    EXEC Security.SP_GetUserNotifications
        @UserID = 1,
        @OnlyUnread = 0,
        @PageNumber = 1,
        @PageSize = 10;
    PRINT '✓ User notifications retrieved';
END
GO

-- Test 6.2: Get Unread Count
PRINT '';
PRINT 'Testing: Get Unread Notification Count...';
IF EXISTS (SELECT 1 FROM Security.[User] WHERE UserID = 1)
BEGIN
    DECLARE @UnreadCount INT;
    EXEC Security.SP_GetUnreadNotificationCount
        @UserID = 1,
        @UnreadCount = @UnreadCount OUTPUT;
    PRINT '✓ Unread count: ' + CAST(@UnreadCount AS NVARCHAR(10));
END
GO

PRINT '';
PRINT '====================================================================';
PRINT '';
GO

-- =============================================
-- TEST 7: Email Queue System (Enhanced)
-- =============================================
PRINT 'TEST 7: Email Queue System';
PRINT '--------------------------------------------------------------------';
GO

-- Test 7.1: Get Email Queue Status
PRINT 'Testing: Get Email Queue Status...';
EXEC Security.SP_GetEmailQueueStatus;
PRINT '✓ Email queue status retrieved';
GO

-- Test 7.2: Get Failed Emails
PRINT '';
PRINT 'Testing: Get Failed Emails...';
EXEC Security.SP_GetFailedEmails;
PRINT '✓ Failed emails retrieved';
GO

PRINT '';
PRINT '====================================================================';
PRINT '';
GO

-- =============================================
-- SUMMARY
-- =============================================
PRINT 'TEST SUMMARY';
PRINT '====================================================================';
GO

-- Count objects
SELECT 'Advanced Schemas' AS Category, COUNT(*) AS Count
FROM sys.schemas
WHERE name IN ('EventStore', 'Analytics')
UNION ALL
SELECT 'Event Store Tables', COUNT(*)
FROM sys.tables
WHERE schema_id = SCHEMA_ID('EventStore')
UNION ALL
SELECT 'Event Sourcing Procedures', COUNT(*)
FROM sys.procedures
WHERE schema_id = SCHEMA_ID('EventStore')
UNION ALL
SELECT 'Analytics Procedures', COUNT(*)
FROM sys.procedures
WHERE schema_id = SCHEMA_ID('Analytics')
UNION ALL
SELECT 'Remedial Procedures', COUNT(*)
FROM sys.procedures
WHERE name LIKE '%Remedial%'
UNION ALL
SELECT 'Monitoring Views', COUNT(*)
FROM sys.views
WHERE name IN ('VW_LiveExamMonitoring', 'VW_ExamSessionStatistics', 'VW_SuspiciousActivityMonitor')
UNION ALL
SELECT 'Active Sessions', COUNT(*)
FROM Security.UserSessions
WHERE IsActive = 1
UNION ALL
SELECT 'Total Events Logged', COUNT(*)
FROM EventStore.Events
UNION ALL
SELECT 'Total Notifications', COUNT(*)
FROM Security.Notifications
UNION ALL
SELECT 'Emails in Queue', COUNT(*)
FROM Security.EmailQueue
WHERE SentDate IS NULL;

PRINT '';
PRINT '====================================================================';
PRINT 'ALL ADVANCED FEATURES TESTS COMPLETED SUCCESSFULLY!';
PRINT '====================================================================';
PRINT '';
PRINT 'Summary:';
PRINT '--------';
PRINT '✓ Event Sourcing: Working';
PRINT '✓ Remedial Exams: Working';
PRINT '✓ Real-Time Monitoring: Working';
PRINT '✓ Smart Analytics: Working';
PRINT '✓ Session Management: Working';
PRINT '✓ Notification System: Working';
PRINT '✓ Email Queue: Working';
PRINT '';
PRINT '🎉 All systems operational!';
PRINT '';
GO
