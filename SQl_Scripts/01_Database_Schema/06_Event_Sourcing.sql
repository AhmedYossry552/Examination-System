/*
============================================================================
Event Sourcing System - Complete Event Tracking
============================================================================
Description: Track every action in the system for complete audit trail
Author: Examination System Team
Created: 2025-11-13
============================================================================
*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Event Store Table
-- =============================================
CREATE TABLE EventStore.Events (
    EventID BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- Aggregate Information
    AggregateID NVARCHAR(50) NOT NULL,              -- StudentID, ExamID, etc.
    AggregateType NVARCHAR(50) NOT NULL,            -- Student, Exam, Question, etc.
    
    -- Event Information
    EventType NVARCHAR(100) NOT NULL,               -- QuestionAnswered, ExamStarted, etc.
    EventData NVARCHAR(MAX) NOT NULL,               -- JSON payload with event details
    EventVersion INT NOT NULL DEFAULT 1,
    
    -- Timing
    OccurredAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    
    -- User Context
    UserID INT NOT NULL,
    UserType NVARCHAR(20) NOT NULL,
    
    -- Correlation (for tracking related events)
    CorrelationID NVARCHAR(50) NULL,                -- Links related events together
    CausationID NVARCHAR(50) NULL,                  -- Event that caused this event
    
    -- Additional Context
    SessionToken NVARCHAR(255) NULL,
    IPAddress NVARCHAR(50) NULL,
    UserAgent NVARCHAR(500) NULL,
    
    -- Metadata
    Metadata NVARCHAR(MAX) NULL,                    -- JSON additional info
    
    CONSTRAINT FK_Events_User FOREIGN KEY (UserID) 
        REFERENCES Security.[User](UserID)
);
GO

-- =============================================
-- Event Snapshots (for performance)
-- =============================================
CREATE TABLE EventStore.Snapshots (
    SnapshotID BIGINT IDENTITY(1,1) PRIMARY KEY,
    AggregateID NVARCHAR(50) NOT NULL,
    AggregateType NVARCHAR(50) NOT NULL,
    SnapshotVersion INT NOT NULL,
    SnapshotData NVARCHAR(MAX) NOT NULL,            -- JSON current state
    CreatedAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    
    INDEX IX_Snapshots_Aggregate (AggregateID, AggregateType, SnapshotVersion)
);
GO

-- =============================================
-- Event Types Reference
-- =============================================
CREATE TABLE EventStore.EventTypes (
    EventTypeID INT IDENTITY(1,1) PRIMARY KEY,
    EventTypeName NVARCHAR(100) NOT NULL UNIQUE,
    AggregateType NVARCHAR(50) NOT NULL,
    Description NVARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE()
);
GO

-- Insert predefined event types
INSERT INTO EventStore.EventTypes (EventTypeName, AggregateType, Description) VALUES
-- User Events
('UserLoggedIn', 'User', 'User successfully logged into the system'),
('UserLoggedOut', 'User', 'User logged out of the system'),
('UserCreated', 'User', 'New user account created'),
('UserUpdated', 'User', 'User account information updated'),
('PasswordChanged', 'User', 'User password was changed'),
('PasswordResetRequested', 'User', 'User requested password reset'),

-- Exam Events
('ExamCreated', 'Exam', 'New exam created'),
('ExamStarted', 'Exam', 'Student started an exam'),
('ExamSubmitted', 'Exam', 'Student submitted exam answers'),
('ExamGraded', 'Exam', 'Exam was graded'),
('ExamReviewedByInstructor', 'Exam', 'Instructor reviewed exam'),

-- Question Events
('QuestionAnswered', 'Question', 'Student answered a question'),
('AnswerChanged', 'Question', 'Student changed their answer'),
('QuestionCreated', 'Question', 'New question added to pool'),
('QuestionUpdated', 'Question', 'Question was modified'),

-- Notification Events
('NotificationSent', 'Notification', 'Notification sent to user'),
('NotificationRead', 'Notification', 'User read notification'),

-- Email Events
('EmailQueued', 'Email', 'Email added to queue'),
('EmailSent', 'Email', 'Email successfully sent'),
('EmailFailed', 'Email', 'Email sending failed'),

-- Course Events
('StudentEnrolled', 'Course', 'Student enrolled in course'),
('CourseCompleted', 'Course', 'Student completed course'),

-- Session Events
('SessionCreated', 'Session', 'New user session created'),
('SessionExpired', 'Session', 'User session expired'),
('SessionRefreshed', 'Session', 'User session refreshed');
GO

-- =============================================
-- Indexes for Performance
-- =============================================
CREATE NONCLUSTERED INDEX IX_Events_Aggregate 
    ON EventStore.Events(AggregateID, AggregateType, EventVersion);

CREATE NONCLUSTERED INDEX IX_Events_Type 
    ON EventStore.Events(EventType, OccurredAt DESC);

CREATE NONCLUSTERED INDEX IX_Events_User 
    ON EventStore.Events(UserID, OccurredAt DESC);

CREATE NONCLUSTERED INDEX IX_Events_Correlation 
    ON EventStore.Events(CorrelationID) 
    WHERE CorrelationID IS NOT NULL;

CREATE NONCLUSTERED INDEX IX_Events_Time 
    ON EventStore.Events(OccurredAt DESC)
    INCLUDE (EventType, AggregateType, UserID);
GO

PRINT '✓ Event Sourcing tables created successfully';
GO
