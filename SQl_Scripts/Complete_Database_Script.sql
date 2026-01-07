/*=============================================
  EXAMINATION SYSTEM DATABASE - COMPLETE INSTALLATION SCRIPT
  
  Description: Complete database creation and setup script
  Database: ExaminationSystemDB
  Author: ITI Team
  Date: 2024
  Version: 1.0
  
  INSTRUCTIONS:
  -------------
  1. Run this script in SQL Server Management Studio
  2. Ensure you have sysadmin privileges
  3. Script will create database, tables, procedures, functions, views, triggers, users, and test data
  4. Estimated execution time: 2-3 minutes
  5. Requires SQL Server 2016 or higher
  
  IMPORTANT NOTES:
  ----------------
  - Creates database at C:\SQLData\ (modify paths if needed)
  - Creates SQL logins with default passwords (CHANGE IN PRODUCTION!)
  - Creates backup jobs (requires SQL Server Agent)
  - Inserts test data for immediate testing
  
  POST-INSTALLATION:
  ------------------
  1. Change all default passwords
  2. Configure backup directory permissions
  3. Test all user accounts
  4. Review security settings
  5. Run test queries from 10_Testing\Test_Queries.sql
  
===============================================*/

SET NOCOUNT ON;
GO

PRINT '====================================================================';
PRINT 'EXAMINATION SYSTEM DATABASE - COMPLETE INSTALLATION';
PRINT '====================================================================';
PRINT '';
PRINT 'Starting installation at: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';
GO

-- =============================================
-- STEP 1: Create Database
-- =============================================
PRINT 'STEP 1/16: Creating Database with Schemas...';
GO

:r "01_Database_Schema\01_Create_Database.sql"
GO

PRINT '✓ Database created successfully';
PRINT '';
GO

-- =============================================
-- STEP 2: Create Tables
-- =============================================
PRINT 'STEP 2/17: Creating Core Tables...';
GO

:r "01_Database_Schema\02_Create_Tables.sql"
GO

PRINT '✓ Core tables created successfully';
PRINT '';
GO

-- =============================================
-- STEP 3: Create Indexes
-- =============================================
PRINT 'STEP 3/17: Creating Performance Indexes...';
GO

:r "01_Database_Schema\03_Create_Indexes.sql"
GO

PRINT '✓ Indexes created successfully';
PRINT '';
GO

-- =============================================
-- STEP 4: Create Constraints
-- =============================================
PRINT 'STEP 4/17: Creating Constraints...';
GO

:r "01_Database_Schema\04_Create_Constraints.sql"
GO

PRINT '✓ Constraints created successfully';
PRINT '';
GO

-- =============================================
-- STEP 5: Create Enhanced Tables (NEW!)
-- =============================================
PRINT 'STEP 5/17: Creating Enhanced Tables (Session, Notifications, Email)...';
GO

:r "01_Database_Schema\05_Enhanced_Tables.sql"
GO

PRINT '✓ Enhanced tables created successfully';
PRINT '';
GO

-- =============================================
-- STEP 6: Create Event Sourcing Tables (ADVANCED!)
-- =============================================
PRINT 'STEP 6/17: Creating Event Sourcing System...';
GO

:r "01_Database_Schema\06_Event_Sourcing.sql"
GO

PRINT '✓ Event Sourcing tables created successfully';
PRINT '';
GO

-- =============================================
-- STEP 7: Create Authentication Enhancement (JWT!)
-- =============================================
PRINT 'STEP 7/17: Creating Authentication Enhancement (RefreshTokens + API Keys)...';
GO

:r "01_Database_Schema\07_Authentication_Enhancement.sql"
GO

PRINT '✓ Authentication enhancement tables created successfully';
PRINT '';
GO

-- =============================================
-- STEP 8: Create Core Stored Procedures
-- =============================================
PRINT 'STEP 8/17: Creating Core Stored Procedures...';
GO

:r "02_Stored_Procedures\Admin_Procedures.sql"
:r "02_Stored_Procedures\Student_Procedures.sql"
:r "02_Stored_Procedures\Instructor_Procedures.sql"
:r "02_Stored_Procedures\Question_Procedures.sql"
:r "02_Stored_Procedures\Exam_Procedures.sql"
:r "02_Stored_Procedures\Course_Procedures.sql"
GO

PRINT '✓ Core stored procedures created successfully';
PRINT '';
GO

-- =============================================
-- STEP 9: Create Enhanced Procedures (NEW!)
-- =============================================
PRINT 'STEP 9/17: Creating Enhanced Procedures (Session, Notifications, Email)...';
GO

:r "02_Stored_Procedures\Session_Management.sql"
:r "02_Stored_Procedures\Notification_System.sql"
:r "02_Stored_Procedures\Email_Queue_System.sql"
:r "02_Stored_Procedures\Utility_Procedures.sql"
:r "02_Stored_Procedures\API_Response_Procedures.sql"
GO

PRINT '✓ Enhanced procedures created successfully';
PRINT '';
GO

-- =============================================
-- STEP 10: Create Advanced Procedures (SMART!)
-- =============================================
PRINT 'STEP 10/17: Creating Advanced Analytics & Automation...';
GO

:r "02_Stored_Procedures\Event_Sourcing_System.sql"
:r "02_Stored_Procedures\Remedial_Exam_System.sql"
:r "02_Stored_Procedures\Smart_Analytics_System.sql"
GO

PRINT '✓ Advanced procedures created successfully';
PRINT '';
GO

-- =============================================
-- STEP 11: Create Authentication Enhancement Procedures
-- =============================================
PRINT 'STEP 11/17: Creating Authentication Enhancement Procedures...';
GO

:r "02_Stored_Procedures\Authentication_Enhancement.sql"
GO

PRINT '✓ Authentication enhancement procedures created successfully';
PRINT '';
GO

-- =============================================
-- STEP 12: Create Functions
-- =============================================
PRINT 'STEP 12/17: Creating Functions...';
GO

:r "03_Functions\Business_Functions.sql"
GO

PRINT '✓ Functions created successfully';
PRINT '';
GO

-- =============================================
-- STEP 13: Create Views
-- =============================================
PRINT 'STEP 13/17: Creating Views...';
GO

:r "04_Views\All_Views.sql"
GO

PRINT '✓ Views created successfully';
PRINT '';
GO

-- =============================================
-- STEP 14: Create Advanced Views (MONITORING!)
-- =============================================
PRINT 'STEP 14/17: Creating Real-Time Monitoring Views...';
GO

:r "04_Views\Real_Time_Monitoring.sql"
GO

PRINT '✓ Monitoring views created successfully';
PRINT '';
GO

-- =============================================
-- STEP 15: Create Triggers
-- =============================================
PRINT 'STEP 15/17: Creating Triggers...';
GO

:r "05_Triggers\All_Triggers.sql"
GO

PRINT '✓ Triggers created successfully';
PRINT '';
GO

-- =============================================
-- STEP 16: Configure Security
-- =============================================
PRINT 'STEP 16/17: Configuring Security...';
GO

:r "06_Security\Create_Users.sql"
:r "06_Security\Assign_Permissions.sql"
GO

PRINT '✓ Security configured successfully';
PRINT '';
GO

-- =============================================
-- STEP 17: Insert Test Data
-- =============================================
PRINT 'STEP 17/17: Inserting Test Data...';
GO

:r "08_Test_Data\Insert_Test_Data.sql"
:r "08_Test_Data\Insert_Advanced_Test_Data.sql"
GO

PRINT '✓ All test data inserted successfully';
PRINT '';
GO

-- =============================================
-- OPTIONAL: Configure Backup (Comment out if SQL Agent not available)
-- =============================================
/*
PRINT 'OPTIONAL: Configuring Automated Backup...';
GO

:r "07_Backup\Configure_Backup.sql"
GO

PRINT '✓ Backup configured successfully';
PRINT '';
GO
*/

-- =============================================
-- Installation Summary
-- =============================================
USE ExaminationSystemDB;
GO

PRINT '====================================================================';
PRINT 'INSTALLATION COMPLETED SUCCESSFULLY!';
PRINT '====================================================================';
PRINT '';
PRINT 'Database Statistics:';
PRINT '--------------------';

SELECT 'Schemas' AS ObjectType, COUNT(*) AS Count
FROM sys.schemas
WHERE name IN ('Academic', 'Exam', 'Security', 'EventStore', 'Analytics')
UNION ALL
SELECT 'Tables', COUNT(*)
FROM sys.tables
WHERE schema_id IN (SELECT schema_id FROM sys.schemas WHERE name IN ('Academic', 'Exam', 'Security', 'EventStore'))
UNION ALL
SELECT 'Stored Procedures', COUNT(*)
FROM sys.procedures
WHERE schema_id IN (SELECT schema_id FROM sys.schemas WHERE name IN ('Academic', 'Exam', 'Security', 'EventStore', 'Analytics'))
UNION ALL
SELECT 'Functions', COUNT(*)
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF') 
AND schema_id IN (SELECT schema_id FROM sys.schemas WHERE name IN ('Academic', 'Exam', 'Security'))
UNION ALL
SELECT 'Views', COUNT(*)
FROM sys.views
WHERE schema_id IN (SELECT schema_id FROM sys.schemas WHERE name IN ('Academic', 'Exam', 'Security'))
UNION ALL
SELECT 'Triggers', COUNT(*)
FROM sys.triggers
WHERE parent_class = 1
AND OBJECT_SCHEMA_NAME(parent_id) IN ('Academic', 'Exam', 'Security')
UNION ALL
SELECT 'Indexes', COUNT(*)
FROM sys.indexes
WHERE object_id IN (
    SELECT object_id FROM sys.tables 
    WHERE schema_id IN (SELECT schema_id FROM sys.schemas WHERE name IN ('Academic', 'Exam', 'Security', 'EventStore'))
)
AND type > 0;

PRINT '';
PRINT 'Test Data Summary:';
PRINT '------------------';

-- Core Data
SELECT 'Users' AS Entity, COUNT(*) AS Count FROM Security.[User]
UNION ALL SELECT 'Students', COUNT(*) FROM Academic.Student
UNION ALL SELECT 'Instructors', COUNT(*) FROM Academic.Instructor
UNION ALL SELECT 'Courses', COUNT(*) FROM Academic.Course
UNION ALL SELECT 'Questions', COUNT(*) FROM Exam.Question
UNION ALL SELECT 'Exams', COUNT(*) FROM Exam.Exam
UNION ALL SELECT 'Branches', COUNT(*) FROM Academic.Branch
UNION ALL SELECT 'Tracks', COUNT(*) FROM Academic.Track
UNION ALL SELECT 'Intakes', COUNT(*) FROM Academic.Intake
-- Advanced Features Data
UNION ALL SELECT 'User Sessions', COUNT(*) FROM Security.UserSessions
UNION ALL SELECT 'Notifications', COUNT(*) FROM Security.Notifications
UNION ALL SELECT 'Email Queue', COUNT(*) FROM Security.EmailQueue
UNION ALL SELECT 'Events', COUNT(*) FROM EventStore.Events
UNION ALL SELECT 'System Settings', COUNT(*) FROM Security.SystemSettings
UNION ALL SELECT 'Refresh Tokens', COUNT(*) FROM Security.RefreshTokens
UNION ALL SELECT 'API Keys', COUNT(*) FROM Security.APIKeys;

PRINT '';
PRINT '====================================================================';
PRINT 'NEXT STEPS:';
PRINT '====================================================================';
PRINT '';
PRINT '1. TEST THE SYSTEM:';
PRINT '   - Run: 10_Testing\Test_Queries.sql';
PRINT '';
PRINT '2. REVIEW DOCUMENTATION:';
PRINT '   - README: README.md (Full project overview)';
PRINT '   - Database Objects: 09_Documentation\Database_Objects.txt';
PRINT '   - User Accounts: 09_Documentation\User_Accounts.txt';
PRINT '   - ERD: 09_Documentation\ERD.md';
PRINT '   - Advanced Features: ADVANCED_FEATURES_GUIDE.md';
PRINT '   - Final Status: FINAL_PROJECT_STATUS.md';
PRINT '';
PRINT '3. DEFAULT CREDENTIALS (CHANGE THESE!):';
PRINT '   - Admin: admin / Admin@123';
PRINT '   - Manager: manager1 / Manager@123';
PRINT '   - Instructor: instructor1 / Inst@123';
PRINT '   - Student: student1 / Stud@123';
PRINT '';
PRINT '4. SQL SERVER LOGINS (CHANGE THESE!):';
PRINT '   - ExamSystemAdmin / Admin@2024!Strong';
PRINT '   - ExamSystemTrainingManager / Manager@2024!Strong';
PRINT '   - ExamSystemInstructor / Instructor@2024!Strong';
PRINT '   - ExamSystemStudent / Student@2024!Strong';
PRINT '';
PRINT '5. FOR API DEVELOPMENT:';
PRINT '   - All stored procedures are ready for API consumption';
PRINT '   - Connection string examples in User_Accounts.txt';
PRINT '   - Use JWT authentication with UserType roles';
PRINT '';
PRINT '6. BACKUP CONFIGURATION:';
PRINT '   - Manual backup: EXEC Security.SP_Admin_ManualBackup';
PRINT '   - Automated backup jobs created (if SQL Agent enabled)';
PRINT '   - Backup location: C:\SQLBackups\ExaminationSystem\';
PRINT '';
PRINT '====================================================================';
PRINT 'Installation completed at: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '====================================================================';
GO

/*
====================================================================
TROUBLESHOOTING
====================================================================

Issue: Cannot create database files
Solution: Create directory C:\SQLData\ or modify paths in 01_Create_Database.sql

Issue: xp_cmdshell not available for backup
Solution: Comment out backup configuration section or enable xp_cmdshell

Issue: SQL Agent jobs not created
Solution: Ensure SQL Server Agent is running

Issue: Permission denied errors
Solution: Run with sysadmin privileges

Issue: Path-related errors with :r commands
Solution: Run from SSMS or use -i parameter with sqlcmd

====================================================================
SUPPORT
====================================================================

For issues or questions:
1. Review documentation in 09_Documentation/
2. Check ERD.md for database design
3. Run test queries to verify functionality
4. Review audit logs: SELECT * FROM Security.AuditLog

====================================================================
*/
