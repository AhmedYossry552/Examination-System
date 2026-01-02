-- =============================================
-- Fresh Test Data Script for Examination System
-- Created: January 2026
-- Description: Clean existing data and insert fresh test data
-- =============================================

USE [ExaminationSystemDB]
GO

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

PRINT '=========================================='
PRINT 'Starting Fresh Test Data Setup'
PRINT '=========================================='
PRINT ''

-- =============================================
-- PART 1: DELETE ALL EXISTING DATA
-- =============================================
PRINT 'STEP 1: Deleting existing data...'

-- Delete in proper order respecting foreign keys
-- First: tables with no dependents or lowest level
-- Note: Question table requires QUOTED_IDENTIFIER ON which is already set at top of script

-- Disable Question deletion trigger temporarily
ALTER TABLE [Exam].[Question] DISABLE TRIGGER [TR_Question_InsteadOfDelete];

-- Delete Exam schema tables (in dependency order)
DELETE FROM [Exam].[StudentAnswer];
DELETE FROM [Exam].[StudentExam];
DELETE FROM [Exam].[ExamQuestion];
DELETE FROM [Exam].[QuestionAnswer];
DELETE FROM [Exam].[QuestionOption];
DELETE FROM [Exam].[Exam];
DELETE FROM [Exam].[Question];

-- Re-enable the trigger
ALTER TABLE [Exam].[Question] ENABLE TRIGGER [TR_Question_InsteadOfDelete];

-- Delete Academic schema tables
DELETE FROM [Academic].[StudentCourse];
DELETE FROM [Academic].[CourseInstructor];
DELETE FROM [Academic].[Student];
DELETE FROM [Academic].[Instructor];
DELETE FROM [Academic].[Course];
DELETE FROM [Academic].[Track];
DELETE FROM [Academic].[Intake];
DELETE FROM [Academic].[Branch];

-- Delete EventStore schema tables
BEGIN TRY
    DELETE FROM [EventStore].[Snapshots];
    DELETE FROM [EventStore].[Events];
    DELETE FROM [EventStore].[EventsArchive];
END TRY
BEGIN CATCH
    PRINT 'EventStore tables skipped: ' + ERROR_MESSAGE();
END CATCH

-- Delete Security schema tables
BEGIN TRY
    DELETE FROM [Security].[UserSessions];
    DELETE FROM [Security].[RefreshTokens];
    DELETE FROM [Security].[User];
END TRY
BEGIN CATCH
    PRINT 'Some Security tables skipped: ' + ERROR_MESSAGE();
END CATCH

-- Reset identity columns
DBCC CHECKIDENT ('[Security].[User]', RESEED, 0);
DBCC CHECKIDENT ('[Academic].[Branch]', RESEED, 0);
DBCC CHECKIDENT ('[Academic].[Track]', RESEED, 0);
DBCC CHECKIDENT ('[Academic].[Intake]', RESEED, 0);
DBCC CHECKIDENT ('[Academic].[Course]', RESEED, 0);
DBCC CHECKIDENT ('[Academic].[Instructor]', RESEED, 0);
DBCC CHECKIDENT ('[Academic].[Student]', RESEED, 0);
DBCC CHECKIDENT ('[Academic].[CourseInstructor]', RESEED, 0);
DBCC CHECKIDENT ('[Academic].[StudentCourse]', RESEED, 0);
DBCC CHECKIDENT ('[Exam].[Question]', RESEED, 0);
DBCC CHECKIDENT ('[Exam].[QuestionOption]', RESEED, 0);
DBCC CHECKIDENT ('[Exam].[QuestionAnswer]', RESEED, 0);
DBCC CHECKIDENT ('[Exam].[Exam]', RESEED, 0);
DBCC CHECKIDENT ('[Exam].[ExamQuestion]', RESEED, 0);
DBCC CHECKIDENT ('[Exam].[StudentExam]', RESEED, 0);
DBCC CHECKIDENT ('[Exam].[StudentAnswer]', RESEED, 0);

PRINT 'All existing data deleted successfully!'
PRINT ''

-- =============================================
-- PART 2: INSERT FRESH TEST DATA
-- =============================================

-- =============================================
-- 2.1: BRANCHES
-- =============================================
PRINT 'STEP 2: Creating Branches...'

INSERT INTO [Academic].[Branch] (BranchName, BranchLocation, BranchManager, PhoneNumber, Email, IsActive, CreatedDate)
VALUES 
    ('Cairo Branch', 'Smart Village, 6th of October', 'Ahmed Hassan', '+20-2-35353535', 'cairo@iti.gov.eg', 1, GETDATE()),
    ('Alexandria Branch', 'Smouha, Alexandria', 'Mohamed Ali', '+20-3-42424242', 'alex@iti.gov.eg', 1, GETDATE()),
    ('Mansoura Branch', 'El-Mashaya, Mansoura', 'Khaled Ibrahim', '+20-50-2222222', 'mansoura@iti.gov.eg', 1, GETDATE());

PRINT '   - 3 branches created'

-- =============================================
-- 2.2: INTAKES
-- =============================================
PRINT 'STEP 3: Creating Intakes...'

INSERT INTO [Academic].[Intake] (IntakeName, IntakeYear, IntakeNumber, StartDate, EndDate, IsActive, CreatedDate)
VALUES 
    ('Intake 44', 2025, 1, '2025-01-01', '2025-09-30', 1, GETDATE()),
    ('Intake 45', 2025, 2, '2025-10-01', '2026-06-30', 1, GETDATE()),
    ('Intake 46', 2026, 1, '2026-01-01', '2026-09-30', 1, GETDATE());

PRINT '   - 3 intakes created'

-- =============================================
-- 2.3: TRACKS
-- =============================================
PRINT 'STEP 4: Creating Tracks...'

-- Cairo Tracks
INSERT INTO [Academic].[Track] (TrackName, BranchID, TrackDescription, DurationMonths, IsActive, CreatedDate)
VALUES 
    ('Full Stack .NET', 1, 'Complete .NET Development with Angular/React frontend', 9, 1, GETDATE()),
    ('Full Stack Python', 1, 'Python Development with Django/Flask and React', 9, 1, GETDATE()),
    ('Mobile Development', 1, 'Cross-platform mobile development with Flutter/React Native', 9, 1, GETDATE()),
    ('Data Science', 1, 'Machine Learning, AI, and Data Analysis', 9, 1, GETDATE());

-- Alexandria Tracks
INSERT INTO [Academic].[Track] (TrackName, BranchID, TrackDescription, DurationMonths, IsActive, CreatedDate)
VALUES 
    ('Full Stack .NET', 2, 'Complete .NET Development with Angular/React frontend', 9, 1, GETDATE()),
    ('Cloud Computing', 2, 'AWS, Azure, and DevOps practices', 9, 1, GETDATE());

-- Mansoura Tracks
INSERT INTO [Academic].[Track] (TrackName, BranchID, TrackDescription, DurationMonths, IsActive, CreatedDate)
VALUES 
    ('Full Stack .NET', 3, 'Complete .NET Development with Angular/React frontend', 9, 1, GETDATE()),
    ('Web Development', 3, 'Modern web development with JavaScript frameworks', 9, 1, GETDATE());

PRINT '   - 8 tracks created'

-- =============================================
-- 2.4: COURSES
-- =============================================
PRINT 'STEP 5: Creating Courses...'

INSERT INTO [Academic].[Course] (CourseName, CourseCode, CourseDescription, MaxDegree, MinDegree, TotalHours, IsActive, CreatedDate)
VALUES 
    ('Database Systems', 'DB101', 'SQL Server, Database Design, Normalization, Stored Procedures', 100, 50, 40, 1, GETDATE()),
    ('C# Programming', 'CS101', 'C# Fundamentals, OOP, LINQ, Async Programming', 100, 50, 60, 1, GETDATE()),
    ('ASP.NET Core', 'NET101', 'Web API, MVC, Entity Framework, Clean Architecture', 100, 50, 80, 1, GETDATE()),
    ('Angular Development', 'ANG101', 'Angular 17+, TypeScript, RxJS, Signals', 100, 50, 60, 1, GETDATE()),
    ('Python Fundamentals', 'PY101', 'Python Basics, Data Structures, File Handling', 100, 50, 40, 1, GETDATE()),
    ('Machine Learning', 'ML101', 'Supervised/Unsupervised Learning, Neural Networks', 100, 50, 60, 1, GETDATE()),
    ('Cloud Computing', 'CLD101', 'Azure/AWS Services, Deployment, CI/CD', 100, 50, 50, 1, GETDATE()),
    ('Software Engineering', 'SE101', 'Design Patterns, SOLID, Clean Code, Testing', 100, 50, 40, 1, GETDATE()),
    ('HTML & CSS', 'WEB101', 'Web Fundamentals, Responsive Design, Flexbox, Grid', 100, 50, 30, 1, GETDATE()),
    ('JavaScript', 'JS101', 'ES6+, DOM Manipulation, Async/Await, APIs', 100, 50, 50, 1, GETDATE());

PRINT '   - 10 courses created'

-- =============================================
-- 2.5: USERS (Admin, Instructors, Students)
-- =============================================
PRINT 'STEP 6: Creating Users...'

-- Password hash for 'Test@123' (SHA2_256 with NVARCHAR/Unicode)
-- Generated using: CONVERT(NVARCHAR(256), HASHBYTES('SHA2_256', N'Test@123'), 2)
-- Note: Use N prefix for Unicode string to match how SP handles NVARCHAR parameters
DECLARE @PasswordHash NVARCHAR(256) = 'DD47BFD8E648B833AB3E17671494FADB5C5DC004E73E38BADB6FF86B26DECC66'

-- Admin User
INSERT INTO [Security].[User] (Username, PasswordHash, Email, FirstName, LastName, PhoneNumber, UserType, IsActive, CreatedDate)
VALUES 
    ('admin', @PasswordHash, 'admin@examsystem.com', 'System', 'Administrator', '+20-100-0000000', 'Admin', 1, GETDATE());

-- Instructor Users (6 instructors)
INSERT INTO [Security].[User] (Username, PasswordHash, Email, FirstName, LastName, PhoneNumber, UserType, IsActive, CreatedDate)
VALUES 
    ('dr.ahmed', @PasswordHash, 'ahmed.hassan@iti.gov.eg', 'Ahmed', 'Hassan', '+20-100-1111111', 'Instructor', 1, GETDATE()),
    ('dr.sara', @PasswordHash, 'sara.mahmoud@iti.gov.eg', 'Sara', 'Mahmoud', '+20-100-2222222', 'Instructor', 1, GETDATE()),
    ('dr.omar', @PasswordHash, 'omar.ali@iti.gov.eg', 'Omar', 'Ali', '+20-100-3333333', 'Instructor', 1, GETDATE()),
    ('dr.fatma', @PasswordHash, 'fatma.ibrahim@iti.gov.eg', 'Fatma', 'Ibrahim', '+20-100-4444444', 'Instructor', 1, GETDATE()),
    ('eng.khaled', @PasswordHash, 'khaled.mostafa@iti.gov.eg', 'Khaled', 'Mostafa', '+20-100-5555555', 'Instructor', 1, GETDATE()),
    ('manager.training', @PasswordHash, 'training.manager@iti.gov.eg', 'Mohamed', 'Training', '+20-100-9999999', 'TrainingManager', 1, GETDATE());

-- Student Users (20 students)
INSERT INTO [Security].[User] (Username, PasswordHash, Email, FirstName, LastName, PhoneNumber, UserType, IsActive, CreatedDate)
VALUES 
    ('std.youssef', @PasswordHash, 'youssef.ahmed@student.iti.gov.eg', 'Youssef', 'Ahmed', '+20-101-0001001', 'Student', 1, GETDATE()),
    ('std.mariam', @PasswordHash, 'mariam.hassan@student.iti.gov.eg', 'Mariam', 'Hassan', '+20-101-0001002', 'Student', 1, GETDATE()),
    ('std.ali', @PasswordHash, 'ali.mohamed@student.iti.gov.eg', 'Ali', 'Mohamed', '+20-101-0001003', 'Student', 1, GETDATE()),
    ('std.nour', @PasswordHash, 'nour.mahmoud@student.iti.gov.eg', 'Nour', 'Mahmoud', '+20-101-0001004', 'Student', 1, GETDATE()),
    ('std.ahmed', @PasswordHash, 'ahmed.samir@student.iti.gov.eg', 'Ahmed', 'Samir', '+20-101-0001005', 'Student', 1, GETDATE()),
    ('std.fatma', @PasswordHash, 'fatma.ali@student.iti.gov.eg', 'Fatma', 'Ali', '+20-101-0001006', 'Student', 1, GETDATE()),
    ('std.omar', @PasswordHash, 'omar.khaled@student.iti.gov.eg', 'Omar', 'Khaled', '+20-101-0001007', 'Student', 1, GETDATE()),
    ('std.rana', @PasswordHash, 'rana.ibrahim@student.iti.gov.eg', 'Rana', 'Ibrahim', '+20-101-0001008', 'Student', 1, GETDATE()),
    ('std.khaled', @PasswordHash, 'khaled.ahmed@student.iti.gov.eg', 'Khaled', 'Ahmed', '+20-101-0001009', 'Student', 1, GETDATE()),
    ('std.sara', @PasswordHash, 'sara.mostafa@student.iti.gov.eg', 'Sara', 'Mostafa', '+20-101-0001010', 'Student', 1, GETDATE()),
    ('std.mahmoud', @PasswordHash, 'mahmoud.hassan@student.iti.gov.eg', 'Mahmoud', 'Hassan', '+20-101-0001011', 'Student', 1, GETDATE()),
    ('std.dina', @PasswordHash, 'dina.omar@student.iti.gov.eg', 'Dina', 'Omar', '+20-101-0001012', 'Student', 1, GETDATE()),
    ('std.karim', @PasswordHash, 'karim.mahmoud@student.iti.gov.eg', 'Karim', 'Mahmoud', '+20-101-0001013', 'Student', 1, GETDATE()),
    ('std.layla', @PasswordHash, 'layla.ahmed@student.iti.gov.eg', 'Layla', 'Ahmed', '+20-101-0001014', 'Student', 1, GETDATE()),
    ('std.hassan', @PasswordHash, 'hassan.ali@student.iti.gov.eg', 'Hassan', 'Ali', '+20-101-0001015', 'Student', 1, GETDATE()),
    ('std.mona', @PasswordHash, 'mona.khalil@student.iti.gov.eg', 'Mona', 'Khalil', '+20-101-0001016', 'Student', 1, GETDATE()),
    ('std.tarek', @PasswordHash, 'tarek.saeed@student.iti.gov.eg', 'Tarek', 'Saeed', '+20-101-0001017', 'Student', 1, GETDATE()),
    ('std.heba', @PasswordHash, 'heba.nasser@student.iti.gov.eg', 'Heba', 'Nasser', '+20-101-0001018', 'Student', 1, GETDATE()),
    ('std.mostafa', @PasswordHash, 'mostafa.ramadan@student.iti.gov.eg', 'Mostafa', 'Ramadan', '+20-101-0001019', 'Student', 1, GETDATE()),
    ('std.salma', @PasswordHash, 'salma.fathy@student.iti.gov.eg', 'Salma', 'Fathy', '+20-101-0001020', 'Student', 1, GETDATE());

PRINT '   - 1 admin, 6 instructors (1 training manager), 20 students created'

-- =============================================
-- 2.6: INSTRUCTORS
-- =============================================
PRINT 'STEP 7: Creating Instructor Records...'

-- Get UserIDs for instructors
INSERT INTO [Academic].[Instructor] (UserID, Specialization, HireDate, Salary, IsTrainingManager, IsActive, CreatedDate)
SELECT UserID, 
       CASE Username
           WHEN 'dr.ahmed' THEN 'Database & Backend Development'
           WHEN 'dr.sara' THEN 'Frontend & Angular Development'
           WHEN 'dr.omar' THEN '.NET Core & C# Development'
           WHEN 'dr.fatma' THEN 'Python & Machine Learning'
           WHEN 'eng.khaled' THEN 'Cloud Computing & DevOps'
           WHEN 'manager.training' THEN 'Training Management'
       END,
       DATEADD(YEAR, -3, GETDATE()),
       CASE Username
           WHEN 'manager.training' THEN 25000.00
           ELSE 18000.00
       END,
       CASE WHEN Username = 'manager.training' THEN 1 ELSE 0 END,
       1, GETDATE()
FROM [Security].[User]
WHERE UserType IN ('Instructor', 'TrainingManager');

PRINT '   - 6 instructor records created'

-- =============================================
-- 2.7: STUDENTS
-- =============================================
PRINT 'STEP 8: Creating Student Records...'

-- Distribute students across tracks and intakes
DECLARE @StudentUserID INT;
DECLARE @Counter INT = 1;

-- Get first student UserID
SELECT @StudentUserID = MIN(UserID) FROM [Security].[User] WHERE UserType = 'Student';

-- Insert students with distribution
INSERT INTO [Academic].[Student] (UserID, IntakeID, BranchID, TrackID, EnrollmentDate, GPA, IsActive, CreatedDate)
SELECT 
    UserID,
    CASE (ROW_NUMBER() OVER (ORDER BY UserID) - 1) % 3
        WHEN 0 THEN 1  -- Intake 44
        WHEN 1 THEN 2  -- Intake 45
        ELSE 3         -- Intake 46
    END AS IntakeID,
    CASE (ROW_NUMBER() OVER (ORDER BY UserID) - 1) % 3
        WHEN 0 THEN 1  -- Cairo
        WHEN 1 THEN 2  -- Alexandria
        ELSE 3         -- Mansoura
    END AS BranchID,
    CASE (ROW_NUMBER() OVER (ORDER BY UserID) - 1) % 4 + 1
        WHEN 1 THEN 1
        WHEN 2 THEN 2
        WHEN 3 THEN 3
        ELSE 4
    END AS TrackID,  -- Tracks 1-4 (main tracks)
    DATEADD(DAY, -(ROW_NUMBER() OVER (ORDER BY UserID) * 10), GETDATE()) AS EnrollmentDate,
    ROUND(RAND(CHECKSUM(NEWID())) * 1.5 + 2.5, 2) AS GPA,  -- GPA between 2.5 and 4.0
    1,
    GETDATE()
FROM [Security].[User]
WHERE UserType = 'Student';

PRINT '   - 20 student records created'

-- =============================================
-- 2.8: COURSE-INSTRUCTOR ASSIGNMENTS
-- =============================================
PRINT 'STEP 9: Assigning Instructors to Courses...'

-- Dr. Ahmed - Database Systems
INSERT INTO [Academic].[CourseInstructor] (CourseID, InstructorID, IntakeID, BranchID, TrackID, AssignedDate, IsActive, CreatedDate)
VALUES 
    (1, 1, 1, 1, 1, GETDATE(), 1, GETDATE()),  -- DB101 for Intake44, Cairo, .NET Track
    (1, 1, 2, 1, 1, GETDATE(), 1, GETDATE());  -- DB101 for Intake45, Cairo, .NET Track

-- Dr. Sara - Angular Development
INSERT INTO [Academic].[CourseInstructor] (CourseID, InstructorID, IntakeID, BranchID, TrackID, AssignedDate, IsActive, CreatedDate)
VALUES 
    (4, 2, 1, 1, 1, GETDATE(), 1, GETDATE()),  -- Angular for Intake44, Cairo, .NET Track
    (4, 2, 2, 1, 1, GETDATE(), 1, GETDATE());  -- Angular for Intake45, Cairo, .NET Track

-- Dr. Omar - C# & ASP.NET
INSERT INTO [Academic].[CourseInstructor] (CourseID, InstructorID, IntakeID, BranchID, TrackID, AssignedDate, IsActive, CreatedDate)
VALUES 
    (2, 3, 1, 1, 1, GETDATE(), 1, GETDATE()),  -- C# for Intake44
    (3, 3, 1, 1, 1, GETDATE(), 1, GETDATE()),  -- ASP.NET for Intake44
    (2, 3, 2, 1, 1, GETDATE(), 1, GETDATE());  -- C# for Intake45

-- Dr. Fatma - Python & ML
INSERT INTO [Academic].[CourseInstructor] (CourseID, InstructorID, IntakeID, BranchID, TrackID, AssignedDate, IsActive, CreatedDate)
VALUES 
    (5, 4, 1, 1, 2, GETDATE(), 1, GETDATE()),  -- Python for Python Track
    (6, 4, 1, 1, 4, GETDATE(), 1, GETDATE());  -- ML for Data Science Track

-- Eng. Khaled - Cloud Computing
INSERT INTO [Academic].[CourseInstructor] (CourseID, InstructorID, IntakeID, BranchID, TrackID, AssignedDate, IsActive, CreatedDate)
VALUES 
    (7, 5, 1, 2, 6, GETDATE(), 1, GETDATE());  -- Cloud for Alex Cloud Track

PRINT '   - 10 course-instructor assignments created'

-- =============================================
-- 2.9: STUDENT-COURSE ENROLLMENTS
-- =============================================
PRINT 'STEP 10: Enrolling Students in Courses...'

-- Enroll all students in Database Systems (Course 1)
INSERT INTO [Academic].[StudentCourse] (StudentID, CourseID, EnrollmentDate, CreatedDate)
SELECT StudentID, 1, EnrollmentDate, GETDATE()
FROM [Academic].[Student];

-- Enroll .NET track students in C#, ASP.NET, Angular
INSERT INTO [Academic].[StudentCourse] (StudentID, CourseID, EnrollmentDate, CreatedDate)
SELECT StudentID, 2, EnrollmentDate, GETDATE()  -- C#
FROM [Academic].[Student] WHERE TrackID IN (1, 5, 7);

INSERT INTO [Academic].[StudentCourse] (StudentID, CourseID, EnrollmentDate, CreatedDate)
SELECT StudentID, 3, EnrollmentDate, GETDATE()  -- ASP.NET
FROM [Academic].[Student] WHERE TrackID IN (1, 5, 7);

INSERT INTO [Academic].[StudentCourse] (StudentID, CourseID, EnrollmentDate, CreatedDate)
SELECT StudentID, 4, EnrollmentDate, GETDATE()  -- Angular
FROM [Academic].[Student] WHERE TrackID IN (1, 5, 7);

-- Enroll Python track students
INSERT INTO [Academic].[StudentCourse] (StudentID, CourseID, EnrollmentDate, CreatedDate)
SELECT StudentID, 5, EnrollmentDate, GETDATE()  -- Python
FROM [Academic].[Student] WHERE TrackID = 2;

-- Enroll Data Science track in ML
INSERT INTO [Academic].[StudentCourse] (StudentID, CourseID, EnrollmentDate, CreatedDate)
SELECT StudentID, 6, EnrollmentDate, GETDATE()  -- ML
FROM [Academic].[Student] WHERE TrackID = 4;

PRINT '   - Student enrollments created'

-- =============================================
-- 2.10: QUESTIONS (Question Bank)
-- =============================================
PRINT 'STEP 11: Creating Questions...'

SET IDENTITY_INSERT [Exam].[Question] ON;

-- Database Questions (Course 1, Instructor 1) - Questions 1-10
INSERT INTO [Exam].[Question] (QuestionID, CourseID, InstructorID, QuestionText, QuestionType, DifficultyLevel, Points, IsActive, CreatedDate)
VALUES 
    -- MCQ Questions
    (1, 1, 1, 'What is the primary purpose of a PRIMARY KEY in a database?', 'MultipleChoice', 'Easy', 2, 1, GETDATE()),
    (2, 1, 1, 'Which SQL clause is used to filter groups?', 'MultipleChoice', 'Medium', 3, 1, GETDATE()),
    (3, 1, 1, 'What is the default port for SQL Server?', 'MultipleChoice', 'Easy', 2, 1, GETDATE()),
    (4, 1, 1, 'Which normalization form eliminates transitive dependencies?', 'MultipleChoice', 'Hard', 4, 1, GETDATE()),
    (5, 1, 1, 'What type of JOIN returns all rows from both tables?', 'MultipleChoice', 'Medium', 3, 1, GETDATE()),
    -- TrueFalse Questions
    (6, 1, 1, 'A VIEW can always be updated directly.', 'TrueFalse', 'Medium', 2, 1, GETDATE()),
    (7, 1, 1, 'TRUNCATE TABLE is a DML command.', 'TrueFalse', 'Medium', 2, 1, GETDATE()),
    (8, 1, 1, 'A clustered index physically reorders the data in the table.', 'TrueFalse', 'Easy', 2, 1, GETDATE()),
    -- Text Questions
    (9, 1, 1, 'Explain the difference between INNER JOIN and LEFT JOIN with examples.', 'Text', 'Medium', 10, 1, GETDATE()),
    (10, 1, 1, 'What is database normalization? Explain 1NF, 2NF, and 3NF.', 'Text', 'Hard', 15, 1, GETDATE());

-- C# Questions (Course 2, Instructor 3) - Questions 11-18
INSERT INTO [Exam].[Question] (QuestionID, CourseID, InstructorID, QuestionText, QuestionType, DifficultyLevel, Points, IsActive, CreatedDate)
VALUES 
    (11, 2, 3, 'Which keyword is used to prevent a class from being inherited?', 'MultipleChoice', 'Easy', 2, 1, GETDATE()),
    (12, 2, 3, 'What is the difference between "ref" and "out" parameters?', 'MultipleChoice', 'Medium', 3, 1, GETDATE()),
    (13, 2, 3, 'Which interface must be implemented for a foreach loop?', 'MultipleChoice', 'Medium', 3, 1, GETDATE()),
    (14, 2, 3, 'What is the default access modifier for class members?', 'MultipleChoice', 'Easy', 2, 1, GETDATE()),
    (15, 2, 3, 'C# supports multiple inheritance through classes.', 'TrueFalse', 'Easy', 2, 1, GETDATE()),
    (16, 2, 3, 'Structs are reference types in C#.', 'TrueFalse', 'Easy', 2, 1, GETDATE()),
    (17, 2, 3, 'Explain the SOLID principles in object-oriented programming.', 'Text', 'Hard', 15, 1, GETDATE()),
    (18, 2, 3, 'What is dependency injection and why is it useful?', 'Text', 'Medium', 10, 1, GETDATE());

-- Angular Questions (Course 4, Instructor 2) - Questions 19-24
INSERT INTO [Exam].[Question] (QuestionID, CourseID, InstructorID, QuestionText, QuestionType, DifficultyLevel, Points, IsActive, CreatedDate)
VALUES 
    (19, 4, 2, 'What is the purpose of Angular signals?', 'MultipleChoice', 'Medium', 3, 1, GETDATE()),
    (20, 4, 2, 'Which decorator marks a class as an Angular component?', 'MultipleChoice', 'Easy', 2, 1, GETDATE()),
    (21, 4, 2, 'What is the difference between Subject and BehaviorSubject?', 'MultipleChoice', 'Hard', 4, 1, GETDATE()),
    (22, 4, 2, 'Angular uses one-way data binding only.', 'TrueFalse', 'Easy', 2, 1, GETDATE()),
    (23, 4, 2, 'Standalone components require NgModule declarations.', 'TrueFalse', 'Medium', 2, 1, GETDATE()),
    (24, 4, 2, 'Explain the Angular component lifecycle hooks.', 'Text', 'Medium', 10, 1, GETDATE());

SET IDENTITY_INSERT [Exam].[Question] OFF;

PRINT '   - 24 questions created'

-- =============================================
-- 2.11: QUESTION OPTIONS (for MCQ and TrueFalse)
-- =============================================
PRINT 'STEP 12: Creating Question Options...'

-- Question 1: PRIMARY KEY purpose
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (1, 'To uniquely identify each record in a table', 1, 1, GETDATE()),
    (1, 'To speed up all queries', 0, 2, GETDATE()),
    (1, 'To allow NULL values', 0, 3, GETDATE()),
    (1, 'To create relationships only', 0, 4, GETDATE());

-- Question 2: Filter groups
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (2, 'WHERE', 0, 1, GETDATE()),
    (2, 'HAVING', 1, 2, GETDATE()),
    (2, 'GROUP BY', 0, 3, GETDATE()),
    (2, 'ORDER BY', 0, 4, GETDATE());

-- Question 3: SQL Server port
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (3, '1433', 1, 1, GETDATE()),
    (3, '3306', 0, 2, GETDATE()),
    (3, '5432', 0, 3, GETDATE()),
    (3, '1521', 0, 4, GETDATE());

-- Question 4: 3NF
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (4, 'First Normal Form (1NF)', 0, 1, GETDATE()),
    (4, 'Second Normal Form (2NF)', 0, 2, GETDATE()),
    (4, 'Third Normal Form (3NF)', 1, 3, GETDATE()),
    (4, 'Boyce-Codd Normal Form (BCNF)', 0, 4, GETDATE());

-- Question 5: FULL JOIN
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (5, 'INNER JOIN', 0, 1, GETDATE()),
    (5, 'LEFT JOIN', 0, 2, GETDATE()),
    (5, 'RIGHT JOIN', 0, 3, GETDATE()),
    (5, 'FULL OUTER JOIN', 1, 4, GETDATE());

-- Question 6: VIEW update (True/False)
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (6, 'True', 0, 1, GETDATE()),
    (6, 'False', 1, 2, GETDATE());

-- Question 7: TRUNCATE (True/False)
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (7, 'True', 0, 1, GETDATE()),
    (7, 'False', 1, 2, GETDATE());

-- Question 8: Clustered index (True/False)
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (8, 'True', 1, 1, GETDATE()),
    (8, 'False', 0, 2, GETDATE());

-- C# Questions Options
-- Question 11: sealed keyword
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (11, 'static', 0, 1, GETDATE()),
    (11, 'sealed', 1, 2, GETDATE()),
    (11, 'abstract', 0, 3, GETDATE()),
    (11, 'virtual', 0, 4, GETDATE());

-- Question 12: ref vs out
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (12, 'ref requires initialization before passing', 1, 1, GETDATE()),
    (12, 'out requires initialization before passing', 0, 2, GETDATE()),
    (12, 'Both are exactly the same', 0, 3, GETDATE()),
    (12, 'Neither can be used with value types', 0, 4, GETDATE());

-- Question 13: IEnumerable
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (13, 'ICollection', 0, 1, GETDATE()),
    (13, 'IEnumerable', 1, 2, GETDATE()),
    (13, 'IList', 0, 3, GETDATE()),
    (13, 'IComparable', 0, 4, GETDATE());

-- Question 14: Default access modifier
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (14, 'public', 0, 1, GETDATE()),
    (14, 'private', 1, 2, GETDATE()),
    (14, 'protected', 0, 3, GETDATE()),
    (14, 'internal', 0, 4, GETDATE());

-- Question 15: Multiple inheritance (T/F)
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (15, 'True', 0, 1, GETDATE()),
    (15, 'False', 1, 2, GETDATE());

-- Question 16: Structs reference types (T/F)
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (16, 'True', 0, 1, GETDATE()),
    (16, 'False', 1, 2, GETDATE());

-- Angular Questions Options
-- Question 19: Signals purpose
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (19, 'To handle HTTP requests', 0, 1, GETDATE()),
    (19, 'To provide reactive state management', 1, 2, GETDATE()),
    (19, 'To style components', 0, 3, GETDATE()),
    (19, 'To route between pages', 0, 4, GETDATE());

-- Question 20: @Component decorator
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (20, '@Injectable', 0, 1, GETDATE()),
    (20, '@Component', 1, 2, GETDATE()),
    (20, '@NgModule', 0, 3, GETDATE()),
    (20, '@Directive', 0, 4, GETDATE());

-- Question 21: Subject vs BehaviorSubject
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (21, 'BehaviorSubject requires an initial value', 1, 1, GETDATE()),
    (21, 'Subject requires an initial value', 0, 2, GETDATE()),
    (21, 'They are identical', 0, 3, GETDATE()),
    (21, 'Subject can only emit once', 0, 4, GETDATE());

-- Question 22: One-way binding (T/F)
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (22, 'True', 0, 1, GETDATE()),
    (22, 'False', 1, 2, GETDATE());

-- Question 23: Standalone NgModule (T/F)
INSERT INTO [Exam].[QuestionOption] (QuestionID, OptionText, IsCorrect, OptionOrder, CreatedDate)
VALUES 
    (23, 'True', 0, 1, GETDATE()),
    (23, 'False', 1, 2, GETDATE());

PRINT '   - Question options created'

-- =============================================
-- 2.12: QUESTION ANSWERS (for Text questions)
-- =============================================
PRINT 'STEP 13: Creating Model Answers for Text Questions...'

INSERT INTO [Exam].[QuestionAnswer] (QuestionID, CorrectAnswer, AnswerPattern, CaseSensitive, CreatedDate)
VALUES 
    (9, 'INNER JOIN returns only matching rows from both tables. LEFT JOIN returns all rows from the left table and matching rows from the right table, with NULL for non-matching rows.', 'INNER.*LEFT.*matching.*NULL.*rows', 0, GETDATE()),
    (10, 'Database normalization is a process of organizing data to reduce redundancy. 1NF: atomic values, unique rows. 2NF: 1NF + no partial dependencies. 3NF: 2NF + no transitive dependencies.', '1NF.*2NF.*3NF.*normalization.*redundancy', 0, GETDATE()),
    (17, 'SOLID: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion. These principles make code more maintainable, flexible, and testable.', 'SOLID.*Single.*Open.*Liskov.*Interface.*Dependency', 0, GETDATE()),
    (18, 'Dependency Injection is a design pattern where dependencies are provided to a class rather than created inside it. It improves testability, loose coupling, and maintainability.', 'dependency.*injection.*coupling.*testability', 0, GETDATE()),
    (24, 'Angular lifecycle hooks: ngOnInit, ngOnChanges, ngDoCheck, ngAfterContentInit, ngAfterContentChecked, ngAfterViewInit, ngAfterViewChecked, ngOnDestroy. They allow executing code at specific component stages.', 'ngOnInit.*ngOnChanges.*ngOnDestroy.*lifecycle', 0, GETDATE());

PRINT '   - Model answers created'

-- =============================================
-- 2.13: EXAMS
-- =============================================
PRINT 'STEP 14: Creating Exams...'

SET IDENTITY_INSERT [Exam].[Exam] ON;

-- Database Exam (Active - Can be taken now)
INSERT INTO [Exam].[Exam] (ExamID, CourseID, InstructorID, IntakeID, BranchID, TrackID, ExamName, ExamYear, ExamType, TotalMarks, PassMarks, DurationMinutes, StartDateTime, EndDateTime, IsActive, CreatedDate)
VALUES 
    (1, 1, 1, 2, 1, 1, 'Database Systems - Midterm Exam', 2026, 'Regular', 50, 25, 90, 
     DATEADD(HOUR, 1, GETDATE()),  -- Starts in 1 hour
     DATEADD(HOUR, 25, GETDATE()), -- Ends in 25 hours
     1, GETDATE()),
    (2, 1, 1, 2, 1, 1, 'Database Systems - Final Exam', 2026, 'Regular', 100, 50, 120,
     DATEADD(DAY, 7, GETDATE()),   -- Starts in 7 days
     DATEADD(DAY, 8, GETDATE()),   -- Ends in 8 days
     1, GETDATE());

-- C# Exam
INSERT INTO [Exam].[Exam] (ExamID, CourseID, InstructorID, IntakeID, BranchID, TrackID, ExamName, ExamYear, ExamType, TotalMarks, PassMarks, DurationMinutes, StartDateTime, EndDateTime, IsActive, CreatedDate)
VALUES 
    (3, 2, 3, 2, 1, 1, 'C# Programming - Quiz 1', 2026, 'Regular', 30, 15, 45,
     DATEADD(HOUR, 2, GETDATE()),  -- Starts in 2 hours
     DATEADD(HOUR, 26, GETDATE()), -- Available for 24 hours
     1, GETDATE());

-- Angular Exam
INSERT INTO [Exam].[Exam] (ExamID, CourseID, InstructorID, IntakeID, BranchID, TrackID, ExamName, ExamYear, ExamType, TotalMarks, PassMarks, DurationMinutes, StartDateTime, EndDateTime, IsActive, CreatedDate)
VALUES 
    (4, 4, 2, 2, 1, 1, 'Angular Development - Practical Exam', 2026, 'Regular', 50, 25, 60,
     DATEADD(DAY, 3, GETDATE()),
     DATEADD(DAY, 4, GETDATE()),
     1, GETDATE());

-- Completed Exam (for testing results)
INSERT INTO [Exam].[Exam] (ExamID, CourseID, InstructorID, IntakeID, BranchID, TrackID, ExamName, ExamYear, ExamType, TotalMarks, PassMarks, DurationMinutes, StartDateTime, EndDateTime, IsActive, CreatedDate)
VALUES 
    (5, 1, 1, 1, 1, 1, 'Database Systems - Practice Quiz', 2025, 'Regular', 20, 10, 30,
     DATEADD(DAY, -7, GETDATE()),  -- Started 7 days ago
     DATEADD(DAY, -6, GETDATE()),  -- Ended 6 days ago
     0, GETDATE());

SET IDENTITY_INSERT [Exam].[Exam] OFF;

PRINT '   - 5 exams created'

-- =============================================
-- 2.14: EXAM QUESTIONS
-- =============================================
PRINT 'STEP 15: Adding Questions to Exams...'

-- Database Midterm (Exam 1) - 50 marks
INSERT INTO [Exam].[ExamQuestion] (ExamID, QuestionID, QuestionOrder, QuestionMarks, CreatedDate)
VALUES 
    (1, 1, 1, 5, GETDATE()),   -- PRIMARY KEY - 5 marks
    (1, 2, 2, 5, GETDATE()),   -- HAVING - 5 marks
    (1, 3, 3, 5, GETDATE()),   -- SQL Port - 5 marks
    (1, 4, 4, 8, GETDATE()),   -- 3NF - 8 marks
    (1, 5, 5, 7, GETDATE()),   -- FULL JOIN - 7 marks
    (1, 6, 6, 5, GETDATE()),   -- VIEW T/F - 5 marks
    (1, 7, 7, 5, GETDATE()),   -- TRUNCATE T/F - 5 marks
    (1, 9, 8, 10, GETDATE());  -- JOIN explanation - 10 marks

-- C# Quiz (Exam 3) - 30 marks
INSERT INTO [Exam].[ExamQuestion] (ExamID, QuestionID, QuestionOrder, QuestionMarks, CreatedDate)
VALUES 
    (3, 11, 1, 5, GETDATE()),  -- sealed
    (3, 12, 2, 7, GETDATE()),  -- ref vs out
    (3, 13, 3, 5, GETDATE()),  -- IEnumerable
    (3, 14, 4, 5, GETDATE()),  -- default access
    (3, 15, 5, 4, GETDATE()),  -- inheritance T/F
    (3, 16, 6, 4, GETDATE());  -- structs T/F

-- Angular Exam (Exam 4) - 50 marks
INSERT INTO [Exam].[ExamQuestion] (ExamID, QuestionID, QuestionOrder, QuestionMarks, CreatedDate)
VALUES 
    (4, 19, 1, 8, GETDATE()),   -- Signals
    (4, 20, 2, 7, GETDATE()),   -- @Component
    (4, 21, 3, 10, GETDATE()),  -- Subject vs BehaviorSubject
    (4, 22, 4, 5, GETDATE()),   -- One-way binding T/F
    (4, 23, 5, 5, GETDATE()),   -- Standalone T/F
    (4, 24, 6, 15, GETDATE());  -- Lifecycle hooks

-- Completed Practice Quiz (Exam 5) - 20 marks
INSERT INTO [Exam].[ExamQuestion] (ExamID, QuestionID, QuestionOrder, QuestionMarks, CreatedDate)
VALUES 
    (5, 1, 1, 5, GETDATE()),
    (5, 3, 2, 5, GETDATE()),
    (5, 6, 3, 5, GETDATE()),
    (5, 8, 4, 5, GETDATE());

PRINT '   - Exam questions assigned'

-- =============================================
-- 2.15: STUDENT EXAM ASSIGNMENTS
-- =============================================
PRINT 'STEP 16: Assigning Students to Exams...'

-- Assign all students to Database Midterm (Exam 1)
INSERT INTO [Exam].[StudentExam] (StudentID, ExamID, IsAllowed, CreatedDate)
SELECT StudentID, 1, 1, GETDATE()
FROM [Academic].[Student]
WHERE IntakeID = 2 AND TrackID = 1;

-- Assign students to C# Quiz (Exam 3)
INSERT INTO [Exam].[StudentExam] (StudentID, ExamID, IsAllowed, CreatedDate)
SELECT StudentID, 3, 1, GETDATE()
FROM [Academic].[Student]
WHERE IntakeID = 2 AND TrackID = 1;

-- Assign students to Angular Exam (Exam 4)
INSERT INTO [Exam].[StudentExam] (StudentID, ExamID, IsAllowed, CreatedDate)
SELECT StudentID, 4, 1, GETDATE()
FROM [Academic].[Student]
WHERE IntakeID = 2 AND TrackID = 1;

-- Create completed exam data for Practice Quiz (Exam 5)
INSERT INTO [Exam].[StudentExam] (StudentID, ExamID, IsAllowed, StartTime, SubmissionTime, TotalScore, IsPassed, IsGraded, CreatedDate)
SELECT 
    StudentID, 
    5, 
    1,
    DATEADD(DAY, -7, GETDATE()),
    DATEADD(DAY, -7, DATEADD(MINUTE, 25, GETDATE())),
    CASE (StudentID % 4)
        WHEN 0 THEN 18
        WHEN 1 THEN 15
        WHEN 2 THEN 12
        ELSE 8
    END,
    CASE WHEN (StudentID % 4) < 3 THEN 1 ELSE 0 END,
    1,
    GETDATE()
FROM [Academic].[Student]
WHERE IntakeID = 1 AND TrackID = 1;

PRINT '   - Students assigned to exams'

-- =============================================
-- 2.16: STUDENT ANSWERS FOR COMPLETED EXAM
-- =============================================
PRINT 'STEP 17: Creating Student Answers for Completed Exam...'

-- Get StudentExamIDs for completed exam
INSERT INTO [Exam].[StudentAnswer] (StudentExamID, QuestionID, SelectedOptionID, IsCorrect, MarksObtained, AnsweredDate)
SELECT 
    se.StudentExamID,
    eq.QuestionID,
    (SELECT TOP 1 OptionID FROM [Exam].[QuestionOption] qo WHERE qo.QuestionID = eq.QuestionID ORDER BY NEWID()),
    CASE WHEN RAND(CHECKSUM(NEWID())) > 0.3 THEN 1 ELSE 0 END,
    CASE WHEN RAND(CHECKSUM(NEWID())) > 0.3 THEN eq.QuestionMarks ELSE 0 END,
    se.SubmissionTime
FROM [Exam].[StudentExam] se
INNER JOIN [Exam].[ExamQuestion] eq ON se.ExamID = eq.ExamID
WHERE se.ExamID = 5 AND se.SubmissionTime IS NOT NULL;

PRINT '   - Student answers created'

-- =============================================
-- SUMMARY
-- =============================================
PRINT ''
PRINT '=========================================='
PRINT 'Fresh Test Data Setup Complete!'
PRINT '=========================================='
PRINT ''
PRINT 'Summary:'
PRINT '  - 3 Branches (Cairo, Alexandria, Mansoura)'
PRINT '  - 3 Intakes (44, 45, 46)'
PRINT '  - 8 Tracks'
PRINT '  - 10 Courses'
PRINT '  - 27 Users (1 Admin, 5 Instructors, 1 Training Manager, 20 Students)'
PRINT '  - 24 Questions (MCQ, TrueFalse, Text)'
PRINT '  - 5 Exams (1 completed, 4 upcoming/active)'
PRINT ''
PRINT 'Test Accounts:'
PRINT '  Admin:    admin / Test@123'
PRINT '  Instructor: dr.ahmed / Test@123'
PRINT '  Training Manager: manager.training / Test@123'
PRINT '  Student:  std.youssef / Test@123'
PRINT ''
PRINT 'Active Exams ready for testing:'
PRINT '  - Database Systems - Midterm Exam (starts in 1 hour)'
PRINT '  - C# Programming - Quiz 1 (starts in 2 hours)'
PRINT '  - Angular Development - Practical Exam (starts in 3 days)'
PRINT '=========================================='

GO
