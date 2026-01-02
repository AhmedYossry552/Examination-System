USE [ExaminationSystemDB];
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;

PRINT 'Starting data reset (no drops, no procedure changes)...';

BEGIN TRY
    BEGIN TRAN;

    -- Target schemas to clear
    DECLARE @schemas TABLE (Name SYSNAME);
    INSERT INTO @schemas(Name) VALUES (N'Exam'),(N'Academic'),(N'Security'),(N'EventStore');

    -- Disable all foreign key constraints for targeted schemas
    DECLARE @sql NVARCHAR(MAX) = N'';
    SELECT @sql = STRING_AGG(CONCAT(N'ALTER TABLE [', s.name, N'].[', t.name, N'] NOCHECK CONSTRAINT ALL;'), CHAR(10))
    FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name IN (SELECT Name FROM @schemas);
    EXEC sp_executesql @sql;

    -- Disable all triggers on targeted tables
    SET @sql = N'';
    SELECT @sql = STRING_AGG(CONCAT(N'DISABLE TRIGGER ALL ON [', s.name, N'].[', t.name, N'];'), CHAR(10))
    FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name IN (SELECT Name FROM @schemas);
    EXEC sp_executesql @sql;

    -- Explicit ordered deletes for core tables
    DELETE FROM Exam.StudentAnswer;
    DELETE FROM Exam.StudentExam;
    DELETE FROM Exam.QuestionOption;
    DELETE FROM Exam.QuestionAnswer;
    DELETE FROM Exam.Question;
    DELETE FROM Exam.Exam;

    DELETE FROM Academic.StudentCourse;
    DELETE FROM Academic.CourseInstructor;
    DELETE FROM Academic.Course;
    DELETE FROM Academic.Student;
    DELETE FROM Academic.Instructor;

    DELETE FROM Security.RefreshTokens;
    DELETE FROM Security.APIRequestLog;
    DELETE FROM Security.APIKeys;
    DELETE FROM Security.[User];

    DELETE FROM EventStore.Events;

    -- Fallback: Delete data from any remaining tables in targeted schemas
    SET @sql = N'';
    SELECT @sql = STRING_AGG(CONCAT(N'DELETE FROM [', s.name, N'].[', t.name, N'];'), CHAR(10))
    FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name IN (SELECT Name FROM @schemas);
    EXEC sp_executesql @sql;

    -- Reseed identities to 0 so next insert starts at 1 (explicit for core tables)
    DBCC CHECKIDENT ('Exam.StudentAnswer', RESEED, 0);
    DBCC CHECKIDENT ('Exam.StudentExam', RESEED, 0);
    DBCC CHECKIDENT ('Exam.QuestionOption', RESEED, 0);
    DBCC CHECKIDENT ('Exam.QuestionAnswer', RESEED, 0);
    DBCC CHECKIDENT ('Exam.Question', RESEED, 0);
    DBCC CHECKIDENT ('Exam.Exam', RESEED, 0);

    DBCC CHECKIDENT ('Academic.StudentCourse', RESEED, 0);
    DBCC CHECKIDENT ('Academic.CourseInstructor', RESEED, 0);
    DBCC CHECKIDENT ('Academic.Course', RESEED, 0);
    DBCC CHECKIDENT ('Academic.Student', RESEED, 0);
    DBCC CHECKIDENT ('Academic.Instructor', RESEED, 0);

    DBCC CHECKIDENT ('Security.RefreshTokens', RESEED, 0);
    DBCC CHECKIDENT ('Security.APIKeys', RESEED, 0);
    DBCC CHECKIDENT ('Security.[User]', RESEED, 0);
    DBCC CHECKIDENT ('EventStore.Events', RESEED, 0);

    -- Dynamic reseed for any other identity tables
    SET @sql = N'';
    SELECT @sql = STRING_AGG(CONCAT(N'DBCC CHECKIDENT (''', s.name, N'.', t.name, N''', RESEED, 0);'), CHAR(10))
    FROM sys.identity_columns ic
    JOIN sys.tables t ON t.object_id = ic.object_id
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name IN (SELECT Name FROM @schemas);
    EXEC sp_executesql @sql;

    -- Re-enable constraints without immediate validation to avoid FK order issues
    SET @sql = N'';
    SELECT @sql = STRING_AGG(CONCAT(N'ALTER TABLE [', s.name, N'].[', t.name, N'] WITH NOCHECK CHECK CONSTRAINT ALL;'), CHAR(10))
    FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name IN (SELECT Name FROM @schemas);
    EXEC sp_executesql @sql;

    -- Re-enable triggers on targeted tables
    SET @sql = N'';
    SELECT @sql = STRING_AGG(CONCAT(N'ENABLE TRIGGER ALL ON [', s.name, N'].[', t.name, N'];'), CHAR(10))
    FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name IN (SELECT Name FROM @schemas);
    EXEC sp_executesql @sql;

    COMMIT TRAN;
    PRINT N'✓ Data reset complete for Exam, Academic, Security, EventStore';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE();
    DECLARE @ErrLine INT = ERROR_LINE();
    PRINT CONCAT(N'✗ Reset failed at line ', @ErrLine, N': ', @ErrMsg);
    THROW;
END CATCH;