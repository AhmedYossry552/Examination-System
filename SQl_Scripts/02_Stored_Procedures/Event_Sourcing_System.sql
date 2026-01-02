/*
============================================================================
Event Sourcing System Stored Procedures
============================================================================
Description: Procedures for managing events and audit trail
Author: Examination System Team
Created: 2025-11-13
============================================================================
*/

USE ExaminationSystemDB;
GO

-- =============================================
-- 1. Append Event to Store
-- =============================================
CREATE OR ALTER PROCEDURE EventStore.SP_AppendEvent
    @AggregateID NVARCHAR(50),
    @AggregateType NVARCHAR(50),
    @EventType NVARCHAR(100),
    @EventData NVARCHAR(MAX),
    @UserID INT,
    @UserType NVARCHAR(20),
    @CorrelationID NVARCHAR(50) = NULL,
    @CausationID NVARCHAR(50) = NULL,
    @SessionToken NVARCHAR(255) = NULL,
    @IPAddress NVARCHAR(50) = NULL,
    @UserAgent NVARCHAR(500) = NULL,
    @Metadata NVARCHAR(MAX) = NULL,
    @EventID BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get next version for this aggregate
        DECLARE @NextVersion INT;
        SELECT @NextVersion = ISNULL(MAX(EventVersion), 0) + 1
        FROM EventStore.Events
        WHERE AggregateID = @AggregateID 
          AND AggregateType = @AggregateType;
        
        -- Insert event
        INSERT INTO EventStore.Events (
            AggregateID, AggregateType, EventType, EventData, EventVersion,
            UserID, UserType, CorrelationID, CausationID,
            SessionToken, IPAddress, UserAgent, Metadata
        )
        VALUES (
            @AggregateID, @AggregateType, @EventType, @EventData, @NextVersion,
            @UserID, @UserType, @CorrelationID, @CausationID,
            @SessionToken, @IPAddress, @UserAgent, @Metadata
        );
        
        SET @EventID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- 2. Get Events for Aggregate
-- =============================================
CREATE OR ALTER PROCEDURE EventStore.SP_GetAggregateEvents
    @AggregateID NVARCHAR(50),
    @AggregateType NVARCHAR(50),
    @FromVersion INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        EventID,
        AggregateID,
        AggregateType,
        EventType,
        EventData,
        EventVersion,
        OccurredAt,
        UserID,
        UserType,
        CorrelationID,
        CausationID,
        Metadata
    FROM EventStore.Events
    WHERE AggregateID = @AggregateID
      AND AggregateType = @AggregateType
      AND EventVersion > @FromVersion
    ORDER BY EventVersion ASC;
END
GO

-- =============================================
-- 3. Get User Activity Timeline
-- =============================================
CREATE OR ALTER PROCEDURE EventStore.SP_GetUserTimeline
    @UserID INT,
    @StartDate DATETIME2(7) = NULL,
    @EndDate DATETIME2(7) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Default date range if not provided
    IF @StartDate IS NULL SET @StartDate = DATEADD(DAY, -30, GETDATE());
    IF @EndDate IS NULL SET @EndDate = GETDATE();
    
    -- Get total count
    DECLARE @TotalCount INT;
    SELECT @TotalCount = COUNT(*)
    FROM EventStore.Events
    WHERE UserID = @UserID
      AND OccurredAt BETWEEN @StartDate AND @EndDate;
    
    -- Get paged results
    SELECT 
        EventID,
        EventType,
        AggregateType,
        AggregateID,
        EventData,
        OccurredAt,
        IPAddress,
        @TotalCount AS TotalRecords,
        CEILING(CAST(@TotalCount AS FLOAT) / @PageSize) AS TotalPages
    FROM EventStore.Events
    WHERE UserID = @UserID
      AND OccurredAt BETWEEN @StartDate AND @EndDate
    ORDER BY OccurredAt DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- =============================================
-- 4. Get System Activity (Admin Dashboard)
-- =============================================
CREATE OR ALTER PROCEDURE EventStore.SP_GetSystemActivity
    @EventType NVARCHAR(100) = NULL,
    @AggregateType NVARCHAR(50) = NULL,
    @StartDate DATETIME2(7) = NULL,
    @EndDate DATETIME2(7) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 100
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @StartDate IS NULL SET @StartDate = DATEADD(HOUR, -24, GETDATE());
    IF @EndDate IS NULL SET @EndDate = GETDATE();
    
    SELECT 
        e.EventID,
        e.EventType,
        e.AggregateType,
        e.AggregateID,
        e.OccurredAt,
        e.UserID,
        u.Username,
        e.UserType,
        e.IPAddress,
        COUNT(*) OVER() AS TotalRecords
    FROM EventStore.Events e
    INNER JOIN Security.[User] u ON e.UserID = u.UserID
    WHERE e.OccurredAt BETWEEN @StartDate AND @EndDate
      AND (@EventType IS NULL OR e.EventType = @EventType)
      AND (@AggregateType IS NULL OR e.AggregateType = @AggregateType)
    ORDER BY e.OccurredAt DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- =============================================
-- 5. Get Student Exam Journey
-- =============================================
CREATE OR ALTER PROCEDURE EventStore.SP_GetStudentExamJourney
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get all events related to this student and exam
    SELECT 
        e.EventID,
        e.EventType,
        e.EventData,
        e.OccurredAt,
        DATEDIFF(SECOND, 
            LAG(e.OccurredAt) OVER (ORDER BY e.OccurredAt),
            e.OccurredAt
        ) AS SecondsSinceLastEvent
    FROM EventStore.Events e
    WHERE e.UserID = (SELECT UserID FROM Academic.Student WHERE StudentID = @StudentID)
      AND (
          (e.AggregateType = 'Exam' AND e.AggregateID = CAST(@ExamID AS NVARCHAR(50)))
          OR
          (e.AggregateType = 'Question' AND e.EventData LIKE '%"ExamID":' + CAST(@ExamID AS NVARCHAR(10)) + '%')
      )
    ORDER BY e.OccurredAt ASC;
END
GO

-- =============================================
-- 6. Get Correlated Events
-- =============================================
CREATE OR ALTER PROCEDURE EventStore.SP_GetCorrelatedEvents
    @CorrelationID NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.EventID,
        e.EventType,
        e.AggregateType,
        e.AggregateID,
        e.EventData,
        e.OccurredAt,
        e.UserID,
        u.Username,
        e.CausationID
    FROM EventStore.Events e
    INNER JOIN Security.[User] u ON e.UserID = u.UserID
    WHERE e.CorrelationID = @CorrelationID
    ORDER BY e.OccurredAt ASC;
END
GO

-- =============================================
-- 7. Create Snapshot
-- =============================================
CREATE OR ALTER PROCEDURE EventStore.SP_CreateSnapshot
    @AggregateID NVARCHAR(50),
    @AggregateType NVARCHAR(50),
    @SnapshotData NVARCHAR(MAX),
    @SnapshotID BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get current version
        DECLARE @CurrentVersion INT;
        SELECT @CurrentVersion = ISNULL(MAX(EventVersion), 0)
        FROM EventStore.Events
        WHERE AggregateID = @AggregateID
          AND AggregateType = @AggregateType;
        
        -- Create snapshot
        INSERT INTO EventStore.Snapshots (
            AggregateID, AggregateType, SnapshotVersion, SnapshotData
        )
        VALUES (
            @AggregateID, @AggregateType, @CurrentVersion, @SnapshotData
        );
        
        SET @SnapshotID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- 8. Event Statistics
-- =============================================
CREATE OR ALTER PROCEDURE EventStore.SP_GetEventStatistics
    @StartDate DATETIME2(7) = NULL,
    @EndDate DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @StartDate IS NULL SET @StartDate = DATEADD(DAY, -7, GETDATE());
    IF @EndDate IS NULL SET @EndDate = GETDATE();
    
    -- Events by type
    SELECT 
        EventType,
        COUNT(*) AS EventCount,
        COUNT(DISTINCT UserID) AS UniqueUsers,
        MIN(OccurredAt) AS FirstOccurrence,
        MAX(OccurredAt) AS LastOccurrence
    FROM EventStore.Events
    WHERE OccurredAt BETWEEN @StartDate AND @EndDate
    GROUP BY EventType
    ORDER BY EventCount DESC;
    
    -- Events by hour
    SELECT 
        DATEPART(HOUR, OccurredAt) AS HourOfDay,
        COUNT(*) AS EventCount
    FROM EventStore.Events
    WHERE OccurredAt BETWEEN @StartDate AND @EndDate
    GROUP BY DATEPART(HOUR, OccurredAt)
    ORDER BY HourOfDay;
    
    -- Most active users
    SELECT TOP 10
        e.UserID,
        u.Username,
        u.FirstName + ' ' + u.LastName AS FullName,
        e.UserType,
        COUNT(*) AS EventCount
    FROM EventStore.Events e
    INNER JOIN Security.[User] u ON e.UserID = u.UserID
    WHERE e.OccurredAt BETWEEN @StartDate AND @EndDate
    GROUP BY e.UserID, u.Username, u.FirstName, u.LastName, e.UserType
    ORDER BY EventCount DESC;
END
GO

-- =============================================
-- 9. Cleanup Old Events (Maintenance)
-- =============================================
CREATE OR ALTER PROCEDURE EventStore.SP_ArchiveOldEvents
    @DaysToKeep INT = 365
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @CutoffDate DATETIME2(7) = DATEADD(DAY, -@DaysToKeep, GETDATE());
        DECLARE @DeletedCount INT;
        
        -- Archive to a backup table (create if doesn't exist)
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EventsArchive')
        BEGIN
            SELECT * INTO EventStore.EventsArchive
            FROM EventStore.Events
            WHERE 1 = 0;
        END
        
        -- Move old events to archive
        INSERT INTO EventStore.EventsArchive
        SELECT * FROM EventStore.Events
        WHERE OccurredAt < @CutoffDate;
        
        SET @DeletedCount = @@ROWCOUNT;
        
        -- Delete archived events
        DELETE FROM EventStore.Events
        WHERE OccurredAt < @CutoffDate;
        
        COMMIT TRANSACTION;
        
        SELECT @DeletedCount AS ArchivedEventCount;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT '✓ Event Sourcing procedures created successfully';
GO
