/*=============================================
  Examination System Database Creation Script
  Description: Creates database with multiple file groups for optimal performance
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE master;
GO

-- Drop database if exists (for development)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ExaminationSystemDB')
BEGIN
    ALTER DATABASE ExaminationSystemDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ExaminationSystemDB;
END
GO

-- Create database with primary file
CREATE DATABASE ExaminationSystemDB
ON PRIMARY
(
    NAME = N'ExamSystem_Primary',
    FILENAME = N'C:\ExaminationSYS\SQLData\ExamSystem_Primary.mdf',
    SIZE = 100MB,
    MAXSIZE = 1GB,
    FILEGROWTH = 50MB
),
-- File Group for User Data
FILEGROUP FG_Users
(
    NAME = N'ExamSystem_Users',
    FILENAME = N'C:\ExaminationSYS\SQLData\ExamSystem_Users.ndf',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 25MB
),
-- File Group for Course Data
FILEGROUP FG_Courses
(
    NAME = N'ExamSystem_Courses',
    FILENAME = N'C:\ExaminationSYS\SQLData\ExamSystem_Courses.ndf',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 25MB
),
-- File Group for Question Pool
FILEGROUP FG_Questions
(
    NAME = N'ExamSystem_Questions',
    FILENAME = N'C:\ExaminationSYS\SQLData\ExamSystem_Questions.ndf',
    SIZE = 100MB,
    MAXSIZE = 1GB,
    FILEGROWTH = 50MB
),
-- File Group for Exam Data
FILEGROUP FG_Exams
(
    NAME = N'ExamSystem_Exams',
    FILENAME = N'C:\ExaminationSYS\SQLData\ExamSystem_Exams.ndf',
    SIZE = 100MB,
    MAXSIZE = 1GB,
    FILEGROWTH = 50MB
),
-- File Group for Student Answers (Largest data)
FILEGROUP FG_Answers
(
    NAME = N'ExamSystem_Answers',
    FILENAME = N'C:\ExaminationSYS\SQLData\ExamSystem_Answers.ndf',
    SIZE = 200MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 100MB
)
-- Transaction Log
LOG ON
(
    NAME = N'ExamSystem_Log',
    FILENAME = N'C:\ExaminationSYS\SQLData\ExamSystem_Log.ldf',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 25MB
);
GO

-- Set database options
ALTER DATABASE ExaminationSystemDB SET RECOVERY FULL;
ALTER DATABASE ExaminationSystemDB SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE ExaminationSystemDB SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE ExaminationSystemDB SET PAGE_VERIFY CHECKSUM;
GO

-- Use the database
USE ExaminationSystemDB;
GO

-- Create schemas for better organization
CREATE SCHEMA Academic AUTHORIZATION dbo;
GO

CREATE SCHEMA Exam AUTHORIZATION dbo;
GO

CREATE SCHEMA Security AUTHORIZATION dbo;
GO

CREATE SCHEMA EventStore AUTHORIZATION dbo;
GO

CREATE SCHEMA Analytics AUTHORIZATION dbo;
GO

PRINT 'Database ExaminationSystemDB created successfully with 5 schemas (Academic, Exam, Security, EventStore, Analytics)!';
GO

/*=============================================
  File Group Information Query
  Run this to verify file groups
===============================================*/
SELECT 
    fg.name AS FileGroupName,
    f.name AS LogicalFileName,
    f.physical_name AS PhysicalFileName,
    f.size * 8 / 1024 AS SizeMB,
    f.max_size * 8 / 1024 AS MaxSizeMB
FROM sys.filegroups fg
INNER JOIN sys.database_files f ON fg.data_space_id = f.data_space_id
WHERE fg.type = 'FG'
UNION ALL
SELECT 
    'LOG' AS FileGroupName,
    f.name AS LogicalFileName,
    f.physical_name AS PhysicalFileName,
    f.size * 8 / 1024 AS SizeMB,
    f.max_size * 8 / 1024 AS MaxSizeMB
FROM sys.database_files f
WHERE f.type = 1;
GO
