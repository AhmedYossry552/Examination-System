/*
============================================================================
Advanced Features Test Data
============================================================================
Description: Sample data for Event Sourcing, Sessions, Notifications, Email Queue
Author: Examination System Team
Created: 2025-11-13
============================================================================
*/

USE ExaminationSystemDB;
GO

PRINT 'Inserting test data for advanced features...';
GO

-- =============================================
-- 1. Create Sample User Sessions
-- =============================================
PRINT 'Creating sample user sessions...';
GO

DECLARE @SessionID1 INT, @SessionID2 INT, @SessionID3 INT;

-- Admin session
EXEC Security.SP_CreateUserSession
    @UserID = 1,
    @SessionToken = 'admin-session-token-123',
    @IPAddress = '192.168.1.100',
    @UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0',
    @SessionID = @SessionID1 OUTPUT;

-- Instructor session
EXEC Security.SP_CreateUserSession
    @UserID = 3,
    @SessionToken = 'instructor-session-token-456',
    @IPAddress = '192.168.1.101',
    @UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/120.0',
    @SessionID = @SessionID2 OUTPUT;

-- Student session
EXEC Security.SP_CreateUserSession
    @UserID = 5,
    @SessionToken = 'student-session-token-789',
    @IPAddress = '192.168.1.102',
    @UserAgent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0) Safari/605.1',
    @SessionID = @SessionID3 OUTPUT;

PRINT '✓ Sample sessions created';
GO

-- =============================================
-- 2. Create Sample Notifications
-- =============================================
PRINT 'Creating sample notifications...';
GO

DECLARE @NotifID INT;

-- Notification for student 1
EXEC Security.SP_CreateNotification
    @UserID = 5,
    @NotificationType = 'ExamAssigned',
    @Title = 'New Exam Available',
    @Message = 'You have been assigned a new exam: SQL Basics Midterm',
    @RelatedEntityType = 'Exam',
    @RelatedEntityID = 1,
    @Priority = 'High',
    @NotificationID = @NotifID OUTPUT;

-- Notification for student 2
EXEC Security.SP_CreateNotification
    @UserID = 6,
    @NotificationType = 'GradeReleased',
    @Title = 'Exam Results Available',
    @Message = 'Your grade for SQL Basics Midterm has been released',
    @RelatedEntityType = 'Exam',
    @RelatedEntityID = 1,
    @Priority = 'Normal',
    @NotificationID = @NotifID OUTPUT;

-- System notification for all
EXEC Security.SP_CreateNotification
    @UserID = 5,
    @NotificationType = 'SystemAlert',
    @Title = 'System Maintenance',
    @Message = 'The system will undergo maintenance on Saturday from 2 AM to 4 AM',
    @Priority = 'Low',
    @NotificationID = @NotifID OUTPUT;

-- Reminder notification
EXEC Security.SP_CreateNotification
    @UserID = 5,
    @NotificationType = 'ExamReminder',
    @Title = 'Exam Reminder',
    @Message = 'Your exam starts in 1 hour. Please be ready!',
    @RelatedEntityType = 'Exam',
    @RelatedEntityID = 1,
    @Priority = 'Urgent',
    @NotificationID = @NotifID OUTPUT;

PRINT '✓ Sample notifications created';
GO

-- =============================================
-- 3. Create Sample Email Queue Entries
-- =============================================
PRINT 'Creating sample email queue entries...';
GO

DECLARE @EmailID INT;

-- Welcome email (corrected parameters)
IF EXISTS (SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'Security' AND name = 'SP_SendWelcomeEmail')
BEGIN
    EXEC Security.SP_SendWelcomeEmail
        @UserID = 5;  -- ← صحح! parameter واحد بس
END
ELSE
BEGIN
    EXEC Security.SP_AddToEmailQueue
        @ToEmail = 'student@example.com',
        @Subject = 'Welcome to Examination System',
        @Body = '<html><body><h2>Welcome!</h2><p>Welcome to our examination system.</p></body></html>',
        @EmailType = 'Welcome',
        @Priority = 'Normal',
        @EmailID = @EmailID OUTPUT;
END

-- Exam assignment email (corrected schema and parameters)
IF EXISTS (SELECT * FROM sys.procedures WHERE SCHEMA_NAME(schema_id) = 'Exam' AND name = 'SP_SendExamAssignmentEmail')
BEGIN
    EXEC Exam.SP_SendExamAssignmentEmail
        @StudentID = 1,
        @ExamID = 1;  -- ← صحح! محذوف @EmailID OUTPUT
END
ELSE
BEGIN
    EXEC Security.SP_AddToEmailQueue
        @ToEmail = 'student@example.com',
        @Subject = 'Exam Assignment Notification',
        @Body = '<html><body><h2>New Exam Assigned</h2><p>You have been assigned a new exam.</p></body></html>',
        @EmailType = 'ExamAssignment',
        @Priority = 'High',
        @EmailID = @EmailID OUTPUT;
END

-- Manual email to queue
EXEC Security.SP_AddToEmailQueue
    @ToEmail = 'test@example.com',
    @Subject = 'Test Email - System Notification',
    @Body = '<html><body><h2>Test Email</h2><p>This is a test email from the examination system.</p></body></html>',
    @EmailType = 'Test',
    @Priority = 'Normal',
    @EmailID = @EmailID OUTPUT;

-- Scheduled email (using SP_AddToEmailQueue since SP_ScheduleEmail might not exist)
EXEC Security.SP_AddToEmailQueue
    @ToEmail = 'admin@example.com',
    @Subject = 'Weekly Report',
    @Body = '<html><body><h2>Weekly Activity Report</h2><p>Your weekly system activity report is ready.</p></body></html>',
    @EmailType = 'Report',
    @Priority = 'Normal',
    @EmailID = @EmailID OUTPUT;

PRINT '✓ Sample email queue entries created';
GO

-- =============================================
-- 4. Create Sample Events (Direct Insert - Simplified)
-- =============================================
PRINT 'Creating sample events...';
GO

-- Insert sample events directly into Events table (if exists)
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'EventStore' AND TABLE_NAME = 'Events')
BEGIN
    INSERT INTO EventStore.Events (
        AggregateID, AggregateType, EventType, EventData,
        UserID, UserType, CorrelationID, 
        SessionToken, IPAddress, UserAgent, EventVersion
    ) VALUES 
    ('1', 'User', 'UserLoggedIn', '{"Username": "admin", "LoginTime": "2024-11-13T09:00:00", "IPAddress": "192.168.1.100"}',
     1, 'Admin', NEWID(), 'admin-session-token-123', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0', 1),
    
    ('1', 'Exam', 'ExamStarted', '{"ExamID": 1, "StudentID": 1, "StartTime": "2024-11-13T10:00:00"}',
     5, 'Student', NEWID(), 'student-session-token-789', '192.168.1.102', 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0) Safari/605.1', 1),
    
    ('10', 'Question', 'QuestionAnswered', '{"QuestionID": 10, "StudentExamID": 1, "Answer": "B", "IsCorrect": true, "TimeSpent": 45}',
     5, 'Student', NEWID(), 'student-session-token-789', '192.168.1.102', NULL, 1),
    
    ('1', 'Exam', 'ExamSubmitted', '{"ExamID": 1, "StudentID": 1, "SubmitTime": "2024-11-13T11:30:00", "QuestionsAnswered": 20}',
     5, 'Student', NEWID(), 'student-session-token-789', '192.168.1.102', NULL, 2),
    
    ('1', 'Notification', 'NotificationSent', '{"NotificationID": 1, "RecipientID": 5, "Type": "GradeReleased"}',
     1, 'System', NEWID(), NULL, NULL, NULL, 1);
END
ELSE
BEGIN
    PRINT 'Events table not found - skipping event creation';
END

PRINT '✓ Sample events created';
GO

-- =============================================
-- 5. Insert System Settings (if not exist)
-- =============================================
PRINT 'Verifying system settings...';
GO

-- Update some settings for testing
UPDATE Security.SystemSettings
SET SettingValue = '720'  -- 12 hours
WHERE SettingKey = 'Session.TimeoutMinutes';

UPDATE Security.SystemSettings
SET SettingValue = '5'  -- Allow 5 devices
WHERE SettingKey = 'Session.MaxConcurrentSessions';

UPDATE Security.SystemSettings
SET SettingValue = '30'  -- Auto-save every 30 seconds
WHERE SettingKey = 'Exam.AutoSaveInterval';

PRINT '✓ System settings updated';
GO

-- =============================================
-- Summary
-- =============================================
PRINT '';
PRINT '====================================================================';
PRINT 'ADVANCED TEST DATA SUMMARY';
PRINT '====================================================================';
PRINT '';

SELECT 'User Sessions' AS DataType, COUNT(*) AS RecordCount
FROM Security.UserSessions
UNION ALL
SELECT 'Notifications', COUNT(*)
FROM Security.Notifications
UNION ALL
SELECT 'Email Queue', COUNT(*)
FROM Security.EmailQueue
UNION ALL
SELECT 'System Settings', COUNT(*)
FROM Security.SystemSettings
UNION ALL
SELECT 'Events', 
    CASE 
        WHEN EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'EventStore' AND TABLE_NAME = 'Events')
        THEN (SELECT COUNT(*) FROM EventStore.Events)
        ELSE 0
    END;

PRINT '';
PRINT '✓ Advanced test data inserted successfully!';
PRINT '';
GO
