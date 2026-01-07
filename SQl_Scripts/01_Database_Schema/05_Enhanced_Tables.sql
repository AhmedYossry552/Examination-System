/*=============================================
  Examination System - Enhanced Tables for Enterprise Features
  Description: Advanced tables for Session Management, Notifications, Email Queue
  Author: ITI Team
  Date: 2024
  Version: 1.0
  
  Tables Added:
  - UserSessions (JWT-like session management)
  - Notifications (In-app notification system)
  - EmailQueue (Automated email system)
  - PasswordResetTokens (Forgot password functionality)
  - SystemSettings (Dynamic configuration)
===============================================*/

USE ExaminationSystemDB;
GO

PRINT 'Creating Enhanced Tables for Enterprise Features...';
GO

-- =============================================
-- Clean up existing tables if they exist
-- =============================================
IF OBJECT_ID('Security.SystemSettings', 'U') IS NOT NULL
    DROP TABLE Security.SystemSettings;

IF OBJECT_ID('Security.PasswordResetTokens', 'U') IS NOT NULL  
    DROP TABLE Security.PasswordResetTokens;

IF OBJECT_ID('Security.EmailQueue', 'U') IS NOT NULL
    DROP TABLE Security.EmailQueue;

IF OBJECT_ID('Security.Notifications', 'U') IS NOT NULL
    DROP TABLE Security.Notifications;

IF OBJECT_ID('Security.UserSessions', 'U') IS NOT NULL
    DROP TABLE Security.UserSessions;

PRINT 'Existing enhanced tables cleaned up (if any)';
GO

-- =============================================
-- Table: UserSessions
-- Description: Manages user sessions for API authentication
-- =============================================
CREATE TABLE Security.UserSessions
(
    SessionID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    SessionToken NVARCHAR(500) NOT NULL UNIQUE,
    IPAddress NVARCHAR(50),
    UserAgent NVARCHAR(500),
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ExpiresAt DATETIME2(3) NOT NULL,
    LastActivityDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT FK_UserSessions_User FOREIGN KEY (UserID) 
        REFERENCES Security.[User](UserID)
) ON FG_Users;
GO

-- Index for session token lookup (very frequent)
CREATE NONCLUSTERED INDEX IX_UserSessions_Token 
ON Security.UserSessions(SessionToken, IsActive)
INCLUDE (UserID, ExpiresAt)
WHERE IsActive = 1;
GO

-- Index for user's active sessions
CREATE NONCLUSTERED INDEX IX_UserSessions_UserActive 
ON Security.UserSessions(UserID, IsActive, ExpiresAt)
WHERE IsActive = 1;
GO

PRINT 'UserSessions table created.';
GO

-- =============================================
-- Table: Notifications
-- Description: In-app notification system
-- =============================================
CREATE TABLE Security.Notifications
(
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    NotificationType NVARCHAR(50) NOT NULL, -- ExamAssigned, GradeReleased, ExamReminder, etc.
    Title NVARCHAR(200) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    RelatedEntityType NVARCHAR(50), -- Exam, Course, Grade, etc.
    RelatedEntityID INT,
    IsRead BIT NOT NULL DEFAULT 0,
    ReadDate DATETIME2(3),
    Priority NVARCHAR(20) NOT NULL DEFAULT 'Normal', -- Low, Normal, High, Urgent
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ExpiresAt DATETIME2(3),
    
    CONSTRAINT FK_Notifications_User FOREIGN KEY (UserID) 
        REFERENCES Security.[User](UserID),
    CONSTRAINT CK_Notifications_Type CHECK (NotificationType IN 
        ('ExamAssigned', 'GradeReleased', 'ExamReminder', 'PasswordReset', 
         'CourseEnrolled', 'ExamSubmitted', 'ManualGradingRequired', 'SystemAlert')),
    CONSTRAINT CK_Notifications_Priority CHECK (Priority IN 
        ('Low', 'Normal', 'High', 'Urgent'))
) ON FG_Users;
GO

-- Index for user's unread notifications (most common query)
CREATE NONCLUSTERED INDEX IX_Notifications_UserUnread 
ON Security.Notifications(UserID, IsRead)
INCLUDE (CreatedDate, ExpiresAt, NotificationType, Title, Priority)
WHERE IsRead = 0;
GO

-- Index for user's all notifications
CREATE NONCLUSTERED INDEX IX_Notifications_UserAll 
ON Security.Notifications(UserID, CreatedDate DESC)
INCLUDE (NotificationType, Title, IsRead, Priority);
GO

PRINT 'Notifications table created.';
GO

-- =============================================
-- Table: EmailQueue
-- Description: Automated email queue system
-- =============================================
CREATE TABLE Security.EmailQueue
(
    EmailID INT IDENTITY(1,1) PRIMARY KEY,
    ToEmail NVARCHAR(200) NOT NULL,
    ToName NVARCHAR(200),
    FromEmail NVARCHAR(200) NOT NULL DEFAULT 'noreply@examsystem.com',
    FromName NVARCHAR(200) NOT NULL DEFAULT 'Exam System',
    Subject NVARCHAR(500) NOT NULL,
    Body NVARCHAR(MAX) NOT NULL,
    EmailType NVARCHAR(50) NOT NULL, -- Welcome, ExamAssignment, Grade, PasswordReset, etc.
    Priority NVARCHAR(20) NOT NULL DEFAULT 'Normal',
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- Pending, Sent, Failed, Cancelled
    ScheduledDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    SentDate DATETIME2(3),
    FailureReason NVARCHAR(MAX),
    RetryCount INT NOT NULL DEFAULT 0,
    MaxRetries INT NOT NULL DEFAULT 3,
    RelatedEntityType NVARCHAR(50),
    RelatedEntityID INT,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3),
    
    CONSTRAINT CK_EmailQueue_Status CHECK (Status IN 
        ('Pending', 'Sent', 'Failed', 'Cancelled')),
    CONSTRAINT CK_EmailQueue_Priority CHECK (Priority IN 
        ('Low', 'Normal', 'High', 'Urgent'))
) ON FG_Users;
GO

-- Index for processing pending emails
CREATE NONCLUSTERED INDEX IX_EmailQueue_Pending 
ON Security.EmailQueue(Status, Priority)
INCLUDE (ScheduledDate, ToEmail, Subject)
WHERE Status = 'Pending';
GO

-- Index for failed emails that need retry
CREATE NONCLUSTERED INDEX IX_EmailQueue_Retry 
ON Security.EmailQueue(Status, RetryCount)
INCLUDE (ModifiedDate, MaxRetries, ToEmail)
WHERE Status = 'Failed';
GO

PRINT 'EmailQueue table created.';
GO

-- =============================================
-- Table: PasswordResetTokens
-- Description: Secure password reset tokens
-- =============================================
CREATE TABLE Security.PasswordResetTokens
(
    TokenID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Token NVARCHAR(500) NOT NULL UNIQUE,
    ExpiresAt DATETIME2(3) NOT NULL,
    IsUsed BIT NOT NULL DEFAULT 0,
    UsedDate DATETIME2(3),
    IPAddress NVARCHAR(50),
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_PasswordResetTokens_User FOREIGN KEY (UserID) 
        REFERENCES Security.[User](UserID)
) ON FG_Users;
GO

-- Index for token validation (very frequent)
CREATE NONCLUSTERED INDEX IX_PasswordResetTokens_Token 
ON Security.PasswordResetTokens(Token, IsUsed)
INCLUDE (ExpiresAt, UserID)
WHERE IsUsed = 0;
GO

-- Index for user's active tokens
CREATE NONCLUSTERED INDEX IX_PasswordResetTokens_UserActive 
ON Security.PasswordResetTokens(UserID, IsUsed, ExpiresAt)
WHERE IsUsed = 0;
GO

PRINT 'PasswordResetTokens table created.';
GO

-- =============================================
-- Table: SystemSettings
-- Description: Dynamic system configuration
-- =============================================
CREATE TABLE Security.SystemSettings
(
    SettingID INT IDENTITY(1,1) PRIMARY KEY,
    SettingKey NVARCHAR(100) NOT NULL UNIQUE,
    SettingValue NVARCHAR(MAX) NOT NULL,
    SettingType NVARCHAR(50) NOT NULL,
    Description NVARCHAR(500),
    Category NVARCHAR(50) NOT NULL,
    IsEditable BIT NOT NULL DEFAULT 1,
    ModifiedBy INT NULL,
    ModifiedDate DATETIME2(3) NULL,
    
    CONSTRAINT CK_SystemSettings_Type CHECK (SettingType IN 
        ('String', 'Integer', 'Boolean', 'JSON', 'Decimal')),
    CONSTRAINT FK_SystemSettings_ModifiedBy FOREIGN KEY (ModifiedBy) 
        REFERENCES Security.[User](UserID)
);
GO

-- Index for key lookup (very frequent)
CREATE NONCLUSTERED INDEX IX_SystemSettings_Key 
ON Security.SystemSettings(SettingKey);
GO

-- Index for category browsing
CREATE NONCLUSTERED INDEX IX_SystemSettings_Category 
ON Security.SystemSettings(Category);
GO

PRINT 'SystemSettings table created.';
GO

-- =============================================
-- Insert Default System Settings
-- =============================================
INSERT INTO Security.SystemSettings (SettingKey, SettingValue, SettingType, Description, Category)
VALUES
-- Email Settings
('Email.SMTPServer', 'smtp.gmail.com', 'String', 'SMTP server address', 'Email'),
('Email.SMTPPort', '587', 'Integer', 'SMTP port number', 'Email'),
('Email.EnableSSL', 'true', 'Boolean', 'Enable SSL for email', 'Email'),
('Email.FromEmail', 'noreply@examsystem.com', 'String', 'Default from email', 'Email'),
('Email.FromName', 'Exam System', 'String', 'Default from name', 'Email'),

-- Session Settings
('Session.TimeoutMinutes', '480', 'Integer', 'Session timeout in minutes (8 hours)', 'Session'),
('Session.MaxConcurrentSessions', '3', 'Integer', 'Max concurrent sessions per user', 'Session'),
('Session.InactivityTimeoutMinutes', '30', 'Integer', 'Auto-logout after inactivity', 'Session'),

-- Exam Settings
('Exam.AutoSaveInterval', '30', 'Integer', 'Auto-save answers every X seconds', 'Exam'),
('Exam.GracePeriodMinutes', '5', 'Integer', 'Grace period after exam end time', 'Exam'),
('Exam.AllowLateSubmission', 'false', 'Boolean', 'Allow submission after end time', 'Exam'),
('Exam.MaxQuestionsPerExam', '100', 'Integer', 'Maximum questions per exam', 'Exam'),

-- Notification Settings
('Notification.RetentionDays', '30', 'Integer', 'Keep notifications for X days', 'Notification'),
('Notification.EnableEmailNotifications', 'true', 'Boolean', 'Send email notifications', 'Notification'),
('Notification.EnablePushNotifications', 'false', 'Boolean', 'Enable push notifications', 'Notification'),

-- Security Settings
('Security.PasswordMinLength', '8', 'Integer', 'Minimum password length', 'Security'),
('Security.PasswordResetTokenExpiry', '60', 'Integer', 'Token expiry in minutes', 'Security'),
('Security.MaxLoginAttempts', '5', 'Integer', 'Max failed login attempts', 'Security'),
('Security.LockoutDurationMinutes', '30', 'Integer', 'Account lockout duration', 'Security');
GO

PRINT 'Default system settings inserted.';
GO

PRINT 'All enhanced tables created successfully!';
GO

-- =============================================
-- Summary
-- =============================================
/*
Enhanced Tables Created:
1. ✅ UserSessions - JWT-like session management
2. ✅ Notifications - In-app notifications
3. ✅ EmailQueue - Automated emails
4. ✅ PasswordResetTokens - Password reset
5. ✅ SystemSettings - Dynamic configuration

Total New Tables: 5
Total Indexes: 12
Default Settings: 18

These tables enable:
✓ Secure session management for API
✓ Real-time in-app notifications
✓ Automated email system
✓ Forgot password functionality
✓ Dynamic system configuration
✓ Production-ready features
*/
