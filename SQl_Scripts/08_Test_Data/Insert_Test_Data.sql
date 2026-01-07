/*=============================================
  Examination System - Test Data
  Description: Inserts comprehensive test data
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- Note: Run scripts in order from 01_Create_Database through 05_Triggers before running this
PRINT 'Starting test data insertion...';
GO

-- Users (Admin, Training Managers, Instructors, Students)
EXEC Security.SP_Admin_CreateUser 'admin', 'Admin@123', 'admin@examsystem.com', 'System', 'Administrator', '01000000001', 'Admin', @UserID = NULL;
EXEC Security.SP_Admin_CreateUser 'manager1', 'Manager@123', 'manager1@iti.gov.eg', 'Ahmed', 'Hassan', '01000000002', 'TrainingManager', @UserID = NULL;
EXEC Security.SP_Admin_CreateUser 'instructor1', 'Inst@123', 'inst1@iti.gov.eg', 'Mohamed', 'Salem', '01000000004', 'Instructor', @UserID = NULL;
EXEC Security.SP_Admin_CreateUser 'instructor2', 'Inst@123', 'inst2@iti.gov.eg', 'Sara', 'Ibrahim', '01000000005', 'Instructor', @UserID = NULL;
EXEC Security.SP_Admin_CreateUser 'student1', 'Stud@123', 'stud1@iti.gov.eg', 'Ali', 'Mohamed', '01100000001', 'Student', @UserID = NULL;
EXEC Security.SP_Admin_CreateUser 'student2', 'Stud@123', 'stud2@iti.gov.eg', 'Mona', 'Hassan', '01100000002', 'Student', @UserID = NULL;
EXEC Security.SP_Admin_CreateUser 'student3', 'Stud@123', 'stud3@iti.gov.eg', 'Youssef', 'Ahmed', '01100000003', 'Student', @UserID = NULL;
GO

PRINT 'Users created.';
GO

-- Add Branches, Tracks, Intakes using stored procedures
-- (Use direct inserts for comprehensive test data)

SET IDENTITY_INSERT Academic.Branch ON;
INSERT INTO Academic.Branch (BranchID, BranchName, BranchLocation, IsActive)
VALUES (1, 'Cairo Branch', 'Smart Village, Cairo', 1),
       (2, 'Alexandria Branch', 'Sidi Gaber, Alexandria', 1);
SET IDENTITY_INSERT Academic.Branch OFF;

SET IDENTITY_INSERT Academic.Track ON;
INSERT INTO Academic.Track (TrackID, TrackName, BranchID, DurationMonths, IsActive)
VALUES (1, 'Full Stack .NET', 1, 9, 1),
       (2, 'Mobile Development', 1, 9, 1);
SET IDENTITY_INSERT Academic.Track OFF;

SET IDENTITY_INSERT Academic.Intake ON;
INSERT INTO Academic.Intake (IntakeID, IntakeName, IntakeYear, IntakeNumber, StartDate, EndDate, IsActive)
VALUES (1, 'Intake 44 Q2', 2024, 2, '2024-04-01', '2025-01-01', 1);
SET IDENTITY_INSERT Academic.Intake OFF;

SET IDENTITY_INSERT Academic.Instructor ON;
INSERT INTO Academic.Instructor (InstructorID, UserID, Specialization, HireDate, IsTrainingManager, IsActive)
VALUES (1, 2, 'Software Engineering', '2020-01-01', 1, 1),
       (2, 3, 'ASP.NET Core', '2021-01-15', 0, 1),
       (3, 4, 'Database Systems', '2021-03-01', 0, 1);
SET IDENTITY_INSERT Academic.Instructor OFF;

SET IDENTITY_INSERT Academic.Student ON;
INSERT INTO Academic.Student (StudentID, UserID, IntakeID, BranchID, TrackID, EnrollmentDate, IsActive)
VALUES (1, 5, 1, 1, 1, '2024-04-01', 1),
       (2, 6, 1, 1, 1, '2024-04-01', 1),
       (3, 7, 1, 1, 1, '2024-04-01', 1);
SET IDENTITY_INSERT Academic.Student OFF;

SET IDENTITY_INSERT Academic.Course ON;
INSERT INTO Academic.Course (CourseID, CourseName, CourseCode, MaxDegree, MinDegree, TotalHours, IsActive)
VALUES (1, 'SQL Server Database', 'DB101', 100, 60, 60, 1),
       (2, 'ASP.NET Core Web API', 'NET201', 100, 60, 80, 1);
SET IDENTITY_INSERT Academic.Course OFF;

INSERT INTO Academic.CourseInstructor (InstructorID, CourseID, IntakeID, BranchID, TrackID, IsActive)
VALUES (3, 1, 1, 1, 1, 1), (2, 2, 1, 1, 1, 1);

INSERT INTO Academic.StudentCourse (StudentID, CourseID) VALUES (1, 1), (2, 1), (3, 1), (1, 2);

-- Insert sample questions
SET IDENTITY_INSERT Exam.Question ON;
INSERT INTO Exam.Question (QuestionID, CourseID, InstructorID, QuestionText, QuestionType, DifficultyLevel, Points, IsActive)
VALUES 
(1, 1, 3, 'What does SQL stand for?', 'MultipleChoice', 'Easy', 2, 1),
(2, 1, 3, 'SELECT statement is used to retrieve data.', 'TrueFalse', 'Easy', 1, 1),
(3, 1, 3, 'Explain the difference between DELETE and TRUNCATE.', 'Text', 'Medium', 10, 1);
SET IDENTITY_INSERT Exam.Question OFF;

INSERT INTO Exam.QuestionOption (QuestionID, OptionText, IsCorrect, OptionOrder)
VALUES (1, 'Structured Query Language', 1, 1), (1, 'Simple Query Language', 0, 2),
       (1, 'Standard Question Language', 0, 3), (1, 'System Query Logic', 0, 4);

INSERT INTO Exam.QuestionAnswer (QuestionID, CorrectAnswer) VALUES (2, 'True'), 
(3, 'DELETE removes rows one by one and can be rolled back. TRUNCATE removes all rows at once and cannot be rolled back.');

-- Create sample exam
SET IDENTITY_INSERT Exam.Exam ON;
INSERT INTO Exam.Exam (ExamID, CourseID, InstructorID, IntakeID, BranchID, TrackID, ExamName, ExamYear, ExamType, 
                       TotalMarks, PassMarks, DurationMinutes, StartDateTime, EndDateTime, IsActive)
VALUES (1, 1, 3, 1, 1, 1, 'SQL Midterm', 2024, 'Regular', 50, 30, 90, 
        '2024-11-20 10:00:00', '2024-11-20 23:59:00', 1);
SET IDENTITY_INSERT Exam.Exam OFF;

INSERT INTO Exam.ExamQuestion (ExamID, QuestionID, QuestionOrder, QuestionMarks)
VALUES (1, 1, 1, 2), (1, 2, 2, 1), (1, 3, 3, 10);

INSERT INTO Exam.StudentExam (StudentID, ExamID, IsAllowed) VALUES (1, 1, 1), (2, 1, 1), (3, 1, 1);

PRINT 'Test data inserted successfully!';
PRINT 'Default passwords: Admin@123 (admin), Manager@123 (managers), Inst@123 (instructors), Stud@123 (students)';
GO
