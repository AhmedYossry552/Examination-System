/*=============================================
  Examination System - Automated Backup Configuration
  Description: Configures daily automated backup using SQL Server Agent
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE msdb;
GO

PRINT 'Configuring Automated Backup System...';
GO

-- =============================================
-- Step 1: Create Backup Directory (via xp_cmdshell)
-- Note: Ensure xp_cmdshell is enabled or create directory manually
-- =============================================

-- Enable xp_cmdshell (if needed)
-- EXEC sp_configure 'show advanced options', 1;
-- RECONFIGURE;
-- EXEC sp_configure 'xp_cmdshell', 1;
-- RECONFIGURE;

-- Create backup directory
-- EXEC xp_cmdshell 'mkdir C:\SQLBackups\ExaminationSystem';
GO

-- =============================================
-- Step 2: Create Full Backup Job
-- =============================================

-- Delete job if exists
IF EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = 'ExamSystem_DailyFullBackup')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = 'ExamSystem_DailyFullBackup';
END
GO

-- Create new job
DECLARE @jobId BINARY(16);

EXEC msdb.dbo.sp_add_job 
    @job_name = N'ExamSystem_DailyFullBackup',
    @enabled = 1,
    @description = N'Daily full backup of Examination System Database',
    @category_name = N'Database Maintenance',
    @owner_login_name = N'sa',
    @job_id = @jobId OUTPUT;

PRINT 'Backup job created.';
GO

-- =============================================
-- Step 3: Add Backup Job Step
-- =============================================

DECLARE @BackupScript NVARCHAR(MAX) = N'
DECLARE @BackupPath NVARCHAR(500);
DECLARE @FileName NVARCHAR(500);
DECLARE @CurrentDate VARCHAR(20);

-- Generate filename with date
SET @CurrentDate = CONVERT(VARCHAR(20), GETDATE(), 112) + ''_'' + REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), '':'', '''');
SET @FileName = ''ExaminationSystemDB_Full_'' + @CurrentDate + ''.bak'';
SET @BackupPath = ''C:\SQLBackups\ExaminationSystem\'' + @FileName;

-- Perform full backup
BACKUP DATABASE [ExaminationSystemDB]
TO DISK = @BackupPath
WITH 
    FORMAT,
    INIT,
    NAME = ''ExaminationSystemDB-Full Database Backup'',
    SKIP,
    NOREWIND,
    NOUNLOAD,
    COMPRESSION,
    STATS = 10,
    CHECKSUM;

-- Verify backup
RESTORE VERIFYONLY 
FROM DISK = @BackupPath;

PRINT ''Full backup completed: '' + @BackupPath;
';

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'ExamSystem_DailyFullBackup',
    @step_name = N'Perform Full Backup',
    @step_id = 1,
    @subsystem = N'TSQL',
    @command = @BackupScript,
    @database_name = N'master',
    @retry_attempts = 3,
    @retry_interval = 5;

PRINT 'Backup step added.';
GO

-- =============================================
-- Step 4: Add Backup Cleanup Step (Delete old backups)
-- =============================================

DECLARE @CleanupScript NVARCHAR(MAX) = N'
-- Delete backups older than 30 days
DECLARE @DeleteDate DATETIME;
SET @DeleteDate = DATEADD(day, -30, GETDATE());

EXECUTE master.dbo.xp_delete_file 
    0,
    N''C:\SQLBackups\ExaminationSystem\'',
    N''bak'',
    @DeleteDate,
    1;

PRINT ''Old backups cleaned up.'';
';

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'ExamSystem_DailyFullBackup',
    @step_name = N'Cleanup Old Backups',
    @step_id = 2,
    @subsystem = N'TSQL',
    @command = @CleanupScript,
    @database_name = N'master',
    @on_success_action = 1; -- Quit with success

PRINT 'Cleanup step added.';
GO

-- =============================================
-- Step 5: Create Schedule (Daily at 2:00 AM)
-- =============================================

EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'ExamSystem_DailyFullBackup',
    @name = N'Daily at 2 AM',
    @enabled = 1,
    @freq_type = 4, -- Daily
    @freq_interval = 1,
    @freq_subday_type = 1,
    @freq_subday_interval = 0,
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 1,
    @active_start_date = 20240101,
    @active_end_date = 99991231,
    @active_start_time = 20000, -- 2:00 AM
    @active_end_time = 235959;

PRINT 'Schedule created: Daily at 2:00 AM';
GO

-- =============================================
-- Step 6: Add Job to Local Server
-- =============================================

EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'ExamSystem_DailyFullBackup',
    @server_name = N'(local)';

PRINT 'Job added to local server.';
GO

-- =============================================
-- Step 7: Create Transaction Log Backup Job (Every 2 hours)
-- =============================================

-- Delete job if exists
IF EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = 'ExamSystem_LogBackup')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = 'ExamSystem_LogBackup';
END
GO

DECLARE @logJobId BINARY(16);

EXEC msdb.dbo.sp_add_job 
    @job_name = N'ExamSystem_LogBackup',
    @enabled = 1,
    @description = N'Transaction log backup every 2 hours',
    @category_name = N'Database Maintenance',
    @owner_login_name = N'sa',
    @job_id = @logJobId OUTPUT;

-- Add log backup step
DECLARE @LogBackupScript NVARCHAR(MAX) = N'
DECLARE @BackupPath NVARCHAR(500);
DECLARE @FileName NVARCHAR(500);
DECLARE @CurrentDate VARCHAR(20);

SET @CurrentDate = CONVERT(VARCHAR(20), GETDATE(), 112) + ''_'' + REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), '':'', '''');
SET @FileName = ''ExaminationSystemDB_Log_'' + @CurrentDate + ''.trn'';
SET @BackupPath = ''C:\SQLBackups\ExaminationSystem\Logs\'' + @FileName;

BACKUP LOG [ExaminationSystemDB]
TO DISK = @BackupPath
WITH 
    FORMAT,
    INIT,
    NAME = ''ExaminationSystemDB-Transaction Log Backup'',
    SKIP,
    NOREWIND,
    NOUNLOAD,
    COMPRESSION,
    STATS = 10;

PRINT ''Log backup completed: '' + @BackupPath;
';

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'ExamSystem_LogBackup',
    @step_name = N'Backup Transaction Log',
    @step_id = 1,
    @subsystem = N'TSQL',
    @command = @LogBackupScript,
    @database_name = N'master',
    @retry_attempts = 2,
    @retry_interval = 5;

-- Schedule every 2 hours
EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'ExamSystem_LogBackup',
    @name = N'Every 2 Hours',
    @enabled = 1,
    @freq_type = 4, -- Daily
    @freq_interval = 1,
    @freq_subday_type = 8, -- Hours
    @freq_subday_interval = 2, -- Every 2 hours
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 1,
    @active_start_date = 20240101,
    @active_end_date = 99991231,
    @active_start_time = 0,
    @active_end_time = 235959;

EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'ExamSystem_LogBackup',
    @server_name = N'(local)';

PRINT 'Transaction log backup job created.';
GO

-- =============================================
-- Manual Backup Procedure
-- =============================================

USE ExaminationSystemDB;
GO

CREATE OR ALTER PROCEDURE Security.SP_Admin_ManualBackup
    @BackupType NVARCHAR(20) = 'FULL' -- FULL, DIFF, LOG
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BackupPath NVARCHAR(500);
    DECLARE @FileName NVARCHAR(500);
    DECLARE @CurrentDate VARCHAR(20);
    DECLARE @SQL NVARCHAR(MAX);
    
    SET @CurrentDate = CONVERT(VARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), ':', '');
    
    IF @BackupType = 'FULL'
    BEGIN
        SET @FileName = 'ExaminationSystemDB_Manual_Full_' + @CurrentDate + '.bak';
        SET @BackupPath = 'C:\SQLBackups\ExaminationSystem\Manual\' + @FileName;
        
        BACKUP DATABASE [ExaminationSystemDB]
        TO DISK = @BackupPath
        WITH FORMAT, INIT, NAME = 'Manual Full Backup', COMPRESSION, STATS = 10;
        
        PRINT 'Manual full backup completed: ' + @BackupPath;
    END
    ELSE IF @BackupType = 'DIFF'
    BEGIN
        SET @FileName = 'ExaminationSystemDB_Manual_Diff_' + @CurrentDate + '.bak';
        SET @BackupPath = 'C:\SQLBackups\ExaminationSystem\Manual\' + @FileName;
        
        BACKUP DATABASE [ExaminationSystemDB]
        TO DISK = @BackupPath
        WITH DIFFERENTIAL, FORMAT, INIT, NAME = 'Manual Differential Backup', COMPRESSION, STATS = 10;
        
        PRINT 'Manual differential backup completed: ' + @BackupPath;
    END
    ELSE IF @BackupType = 'LOG'
    BEGIN
        SET @FileName = 'ExaminationSystemDB_Manual_Log_' + @CurrentDate + '.trn';
        SET @BackupPath = 'C:\SQLBackups\ExaminationSystem\Manual\' + @FileName;
        
        BACKUP LOG [ExaminationSystemDB]
        TO DISK = @BackupPath
        WITH FORMAT, INIT, NAME = 'Manual Log Backup', COMPRESSION, STATS = 10;
        
        PRINT 'Manual log backup completed: ' + @BackupPath;
    END
END
GO

PRINT 'Backup configuration completed successfully!';
GO

-- =============================================
-- Instructions for Manual Backup
-- =============================================

/*
To perform manual backup:

-- Full backup
EXEC Security.SP_Admin_ManualBackup @BackupType = 'FULL';

-- Differential backup
EXEC Security.SP_Admin_ManualBackup @BackupType = 'DIFF';

-- Transaction log backup
EXEC Security.SP_Admin_ManualBackup @BackupType = 'LOG';
*/

-- =============================================
-- Restore Instructions
-- =============================================

/*
To restore database:

-- 1. Restore full backup
RESTORE DATABASE [ExaminationSystemDB]
FROM DISK = 'C:\SQLBackups\ExaminationSystem\ExaminationSystemDB_Full_20240101_020000.bak'
WITH REPLACE, NORECOVERY;

-- 2. Restore transaction log (if needed)
RESTORE LOG [ExaminationSystemDB]
FROM DISK = 'C:\SQLBackups\ExaminationSystem\Logs\ExaminationSystemDB_Log_20240101_040000.trn'
WITH RECOVERY;
*/
