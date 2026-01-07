USE ExaminationSystemDB;
GO

-- Complete fix for the type clash issue
CREATE OR ALTER PROCEDURE EventStore.SP_ArchiveOldEvents
    @DaysToKeep INT = 365
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Fix: Explicit cast to ensure DATETIME2 compatibility
        DECLARE @CutoffDate DATETIME2(7);
        SET @CutoffDate = CAST(DATEADD(DAY, -@DaysToKeep, SYSUTCDATETIME()) AS DATETIME2(7));
        
        DECLARE @DeletedCount INT;
        
        -- Archive to a backup table (create if doesn't exist)
        IF NOT EXISTS (
            SELECT * FROM sys.tables t
            INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
            WHERE t.name = 'EventsArchive' AND s.name = 'EventStore'
        )
        BEGIN
            -- Create archive table with same structure
            CREATE TABLE EventStore.EventsArchive (
                EventID BIGINT IDENTITY(1,1) PRIMARY KEY,
                AggregateID NVARCHAR(50) NOT NULL,
                AggregateType NVARCHAR(50) NOT NULL,
                EventType NVARCHAR(100) NOT NULL,
                EventData NVARCHAR(MAX) NOT NULL,
                EventVersion INT NOT NULL DEFAULT 1,
                OccurredAt DATETIME2(7) NOT NULL,
                UserID INT NOT NULL,
                UserType NVARCHAR(20) NOT NULL,
                CorrelationID NVARCHAR(50) NULL,
                CausationID NVARCHAR(50) NULL,
                SessionToken NVARCHAR(255) NULL,
                IPAddress NVARCHAR(50) NULL,
                UserAgent NVARCHAR(500) NULL,
                Metadata NVARCHAR(MAX) NULL,
                ArchivedAt DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME()
            );
        END
        
        -- Move old events to archive
        INSERT INTO EventStore.EventsArchive (
            EventID, AggregateID, AggregateType, EventType, EventData, EventVersion,
            OccurredAt, UserID, UserType, CorrelationID, CausationID,
            SessionToken, IPAddress, UserAgent, Metadata
        )
        SELECT 
            EventID, AggregateID, AggregateType, EventType, EventData, EventVersion,
            OccurredAt, UserID, UserType, CorrelationID, CausationID,
            SessionToken, IPAddress, UserAgent, Metadata
        FROM EventStore.Events
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

PRINT 'SP_ArchiveOldEvents completely fixed with explicit type casting!';
GO
