USE ExaminationSystemDB;
GO

-- Fix the type clash bug in SP_ArchiveOldEvents
CREATE OR ALTER PROCEDURE EventStore.SP_ArchiveOldEvents
    @DaysToKeep INT = 365
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- FIX: Use SYSUTCDATETIME() instead of GETDATE() for DATETIME2 compatibility
        DECLARE @CutoffDate DATETIME2(7) = DATEADD(DAY, -@DaysToKeep, SYSUTCDATETIME());
        DECLARE @DeletedCount INT;
        
        -- Archive to a backup table (create if doesn't exist)
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EventsArchive' AND schema_id = SCHEMA_ID('EventStore'))
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

PRINT 'Stored procedure bug fixed successfully!';
PRINT 'Changed GETDATE() to SYSUTCDATETIME() for DATETIME2 compatibility';
GO
