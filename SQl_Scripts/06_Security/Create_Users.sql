/*=============================================
  Examination System - SQL Users and Logins
  Description: Creates SQL Server logins and database users with roles
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE master;
GO

PRINT 'Creating SQL Server Logins...';
GO

-- =============================================
-- Create Logins
-- =============================================

-- Admin Login
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ExamSystemAdmin')
BEGIN
    CREATE LOGIN ExamSystemAdmin 
    WITH PASSWORD = 'Admin@2024!Strong', 
    DEFAULT_DATABASE = ExaminationSystemDB,
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
    PRINT 'Admin login created.';
END
GO

-- Training Manager Login
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ExamSystemTrainingManager')
BEGIN
    CREATE LOGIN ExamSystemTrainingManager 
    WITH PASSWORD = 'Manager@2024!Strong', 
    DEFAULT_DATABASE = ExaminationSystemDB,
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
    PRINT 'Training Manager login created.';
END
GO

-- Instructor Login (Template - create for each instructor)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ExamSystemInstructor')
BEGIN
    CREATE LOGIN ExamSystemInstructor 
    WITH PASSWORD = 'Instructor@2024!Strong', 
    DEFAULT_DATABASE = ExaminationSystemDB,
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
    PRINT 'Instructor login created.';
END
GO

-- Student Login (Template - create for each student)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ExamSystemStudent')
BEGIN
    CREATE LOGIN ExamSystemStudent 
    WITH PASSWORD = 'Student@2024!Strong', 
    DEFAULT_DATABASE = ExaminationSystemDB,
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = OFF;
    PRINT 'Student login created.';
END
GO

-- =============================================
-- Switch to Database
-- =============================================
USE ExaminationSystemDB;
GO

PRINT 'Creating Database Users...';
GO

-- =============================================
-- Create Database Users
-- =============================================

-- Admin User
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ExamSystemAdmin')
BEGIN
    CREATE USER ExamSystemAdmin FOR LOGIN ExamSystemAdmin;
    PRINT 'Admin user created.';
END
GO

-- Training Manager User
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ExamSystemTrainingManager')
BEGIN
    CREATE USER ExamSystemTrainingManager FOR LOGIN ExamSystemTrainingManager;
    PRINT 'Training Manager user created.';
END
GO

-- Instructor User
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ExamSystemInstructor')
BEGIN
    CREATE USER ExamSystemInstructor FOR LOGIN ExamSystemInstructor;
    PRINT 'Instructor user created.';
END
GO

-- Student User
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ExamSystemStudent')
BEGIN
    CREATE USER ExamSystemStudent FOR LOGIN ExamSystemStudent;
    PRINT 'Student user created.';
END
GO

-- =============================================
-- Create Database Roles
-- =============================================

-- Admin Role
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_ExamAdmin' AND type = 'R')
BEGIN
    CREATE ROLE db_ExamAdmin;
    PRINT 'Admin role created.';
END
GO

-- Training Manager Role
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_ExamTrainingManager' AND type = 'R')
BEGIN
    CREATE ROLE db_ExamTrainingManager;
    PRINT 'Training Manager role created.';
END
GO

-- Instructor Role
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_ExamInstructor' AND type = 'R')
BEGIN
    CREATE ROLE db_ExamInstructor;
    PRINT 'Instructor role created.';
END
GO

-- Student Role
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_ExamStudent' AND type = 'R')
BEGIN
    CREATE ROLE db_ExamStudent;
    PRINT 'Student role created.';
END
GO

-- =============================================
-- Assign Users to Roles
-- =============================================

-- Admin
ALTER ROLE db_ExamAdmin ADD MEMBER ExamSystemAdmin;
ALTER ROLE db_datareader ADD MEMBER ExamSystemAdmin;
ALTER ROLE db_datawriter ADD MEMBER ExamSystemAdmin;
GO

-- Training Manager
ALTER ROLE db_ExamTrainingManager ADD MEMBER ExamSystemTrainingManager;
GO

-- Instructor
ALTER ROLE db_ExamInstructor ADD MEMBER ExamSystemInstructor;
GO

-- Student
ALTER ROLE db_ExamStudent ADD MEMBER ExamSystemStudent;
GO

PRINT 'Users assigned to roles successfully!';
GO
