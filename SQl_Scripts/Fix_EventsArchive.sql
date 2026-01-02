USE ExaminationSystemDB;
GO

-- Create EventsArchive table to fix Reverse Engineering issue
CREATE TABLE EventStore.EventsArchive (
    EventID BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- Aggregate Information
    AggregateID NVARCHAR(50) NOT NULL,
    AggregateType NVARCHAR(50) NOT NULL,
    
    -- Event Information
    EventType NVARCHAR(100) NOT NULL,
    EventData NVARCHAR(MAX) NOT NULL,
    EventVersion INT NOT NULL DEFAULT 1,
    
    -- Timing
    OccurredAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
    
    -- User Context
    UserID INT NOT NULL,
    UserType NVARCHAR(20) NOT NULL,
    
    -- Correlation
    CorrelationID NVARCHAR(50) NULL,
    CausationID NVARCHAR(50) NULL,
    
    -- Additional Context
    SessionToken NVARCHAR(255) NULL,
    IPAddress NVARCHAR(50) NULL,
    UserAgent NVARCHAR(500) NULL,
    
    -- Metadata
    Metadata NVARCHAR(MAX) NULL,
    
    -- Archive specific
    ArchivedAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

PRINT 'EventsArchive table created successfully!';
