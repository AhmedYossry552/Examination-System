/*=============================================
  Examination System - Index Creation Script
  Description: Creates non-clustered indexes for optimal query performance
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

PRINT 'Creating Indexes for Performance Optimization...';
GO

-- =============================================
-- Section 1: User Management Indexes
-- =============================================

-- User table indexes
CREATE NONCLUSTERED INDEX IX_User_UserType 
ON Security.[User](UserType) 
INCLUDE (FirstName, LastName, Email, IsActive);
GO

CREATE NONCLUSTERED INDEX IX_User_IsActive 
ON Security.[User](IsActive) 
WHERE IsActive = 1;
GO

CREATE NONCLUSTERED INDEX IX_User_Email 
ON Security.[User](Email);
GO

-- Instructor table indexes
CREATE NONCLUSTERED INDEX IX_Instructor_UserID 
ON Academic.Instructor(UserID) 
INCLUDE (IsTrainingManager, IsActive);
GO

CREATE NONCLUSTERED INDEX IX_Instructor_IsTrainingManager 
ON Academic.Instructor(IsTrainingManager) 
WHERE IsTrainingManager = 1;
GO

-- Student table indexes
CREATE NONCLUSTERED INDEX IX_Student_UserID 
ON Academic.Student(UserID) 
INCLUDE (IntakeID, BranchID, TrackID);
GO

CREATE NONCLUSTERED INDEX IX_Student_Intake_Branch_Track 
ON Academic.Student(IntakeID, BranchID, TrackID) 
INCLUDE (StudentID, GPA);
GO

CREATE NONCLUSTERED INDEX IX_Student_IsActive 
ON Academic.Student(IsActive) 
WHERE IsActive = 1;
GO

-- =============================================
-- Section 2: Academic Structure Indexes
-- =============================================

-- Branch indexes
CREATE NONCLUSTERED INDEX IX_Branch_IsActive 
ON Academic.Branch(IsActive) 
WHERE IsActive = 1;
GO

-- Track indexes
CREATE NONCLUSTERED INDEX IX_Track_BranchID 
ON Academic.Track(BranchID) 
INCLUDE (TrackName, IsActive);
GO

-- Intake indexes
CREATE NONCLUSTERED INDEX IX_Intake_Year 
ON Academic.Intake(IntakeYear, IntakeNumber) 
INCLUDE (IntakeName, StartDate, EndDate);
GO

CREATE NONCLUSTERED INDEX IX_Intake_Dates 
ON Academic.Intake(StartDate, EndDate) 
INCLUDE (IntakeID, IntakeName);
GO

-- =============================================
-- Section 3: Course Management Indexes
-- =============================================

-- Course indexes
CREATE NONCLUSTERED INDEX IX_Course_CourseName 
ON Academic.Course(CourseName) 
INCLUDE (CourseCode, MaxDegree, MinDegree);
GO

CREATE NONCLUSTERED INDEX IX_Course_IsActive 
ON Academic.Course(IsActive) 
WHERE IsActive = 1;
GO

CREATE NONCLUSTERED INDEX IX_Course_CourseCode 
ON Academic.Course(CourseCode);
GO

-- CourseInstructor indexes
CREATE NONCLUSTERED INDEX IX_CourseInstructor_InstructorID 
ON Academic.CourseInstructor(InstructorID) 
INCLUDE (CourseID, IntakeID, BranchID, TrackID);
GO

CREATE NONCLUSTERED INDEX IX_CourseInstructor_CourseID 
ON Academic.CourseInstructor(CourseID) 
INCLUDE (InstructorID, IntakeID);
GO

CREATE NONCLUSTERED INDEX IX_CourseInstructor_Intake_Branch_Track 
ON Academic.CourseInstructor(IntakeID, BranchID, TrackID) 
INCLUDE (CourseID, InstructorID);
GO

-- StudentCourse indexes
CREATE NONCLUSTERED INDEX IX_StudentCourse_StudentID 
ON Academic.StudentCourse(StudentID) 
INCLUDE (CourseID, FinalGrade, IsPassed);
GO

CREATE NONCLUSTERED INDEX IX_StudentCourse_CourseID 
ON Academic.StudentCourse(CourseID) 
INCLUDE (StudentID, FinalGrade);
GO

-- =============================================
-- Section 4: Question Pool Indexes
-- =============================================

-- Question indexes
CREATE NONCLUSTERED INDEX IX_Question_CourseID 
ON Exam.Question(CourseID) 
INCLUDE (QuestionType, DifficultyLevel, Points, IsActive);
GO

CREATE NONCLUSTERED INDEX IX_Question_InstructorID 
ON Exam.Question(InstructorID) 
INCLUDE (CourseID, QuestionType);
GO

CREATE NONCLUSTERED INDEX IX_Question_CourseID_Type 
ON Exam.Question(CourseID, QuestionType) 
INCLUDE (QuestionID, DifficultyLevel, Points)
WHERE IsActive = 1;
GO

CREATE NONCLUSTERED INDEX IX_Question_Difficulty 
ON Exam.Question(DifficultyLevel, CourseID) 
WHERE IsActive = 1;
GO

-- QuestionOption indexes
CREATE NONCLUSTERED INDEX IX_QuestionOption_QuestionID 
ON Exam.QuestionOption(QuestionID) 
INCLUDE (OptionText, IsCorrect, OptionOrder);
GO

CREATE NONCLUSTERED INDEX IX_QuestionOption_IsCorrect 
ON Exam.QuestionOption(QuestionID, IsCorrect) 
WHERE IsCorrect = 1;
GO

-- QuestionAnswer indexes
CREATE NONCLUSTERED INDEX IX_QuestionAnswer_QuestionID 
ON Exam.QuestionAnswer(QuestionID);
GO

-- =============================================
-- Section 5: Exam Management Indexes
-- =============================================

-- Exam indexes
CREATE NONCLUSTERED INDEX IX_Exam_CourseID 
ON Exam.Exam(CourseID) 
INCLUDE (ExamName, ExamType, StartDateTime, EndDateTime);
GO

CREATE NONCLUSTERED INDEX IX_Exam_InstructorID 
ON Exam.Exam(InstructorID) 
INCLUDE (CourseID, ExamName, StartDateTime);
GO

CREATE NONCLUSTERED INDEX IX_Exam_DateTime 
ON Exam.Exam(StartDateTime, EndDateTime) 
INCLUDE (ExamID, ExamName, CourseID);
GO

CREATE NONCLUSTERED INDEX IX_Exam_Intake_Branch_Track 
ON Exam.Exam(IntakeID, BranchID, TrackID) 
INCLUDE (CourseID, ExamName, StartDateTime);
GO

CREATE NONCLUSTERED INDEX IX_Exam_Year_Course 
ON Exam.Exam(ExamYear, CourseID) 
INCLUDE (ExamName, TotalMarks);
GO

-- ExamQuestion indexes
CREATE NONCLUSTERED INDEX IX_ExamQuestion_ExamID 
ON Exam.ExamQuestion(ExamID) 
INCLUDE (QuestionID, QuestionOrder, QuestionMarks);
GO

CREATE NONCLUSTERED INDEX IX_ExamQuestion_QuestionID 
ON Exam.ExamQuestion(QuestionID) 
INCLUDE (ExamID);
GO

-- StudentExam indexes
CREATE NONCLUSTERED INDEX IX_StudentExam_StudentID 
ON Exam.StudentExam(StudentID) 
INCLUDE (ExamID, TotalScore, IsPassed, IsGraded);
GO

CREATE NONCLUSTERED INDEX IX_StudentExam_ExamID 
ON Exam.StudentExam(ExamID) 
INCLUDE (StudentID, TotalScore, IsGraded);
GO

CREATE NONCLUSTERED INDEX IX_StudentExam_IsGraded 
ON Exam.StudentExam(IsGraded, ExamID) 
WHERE IsGraded = 0;
GO

CREATE NONCLUSTERED INDEX IX_StudentExam_Submission 
ON Exam.StudentExam(SubmissionTime) 
INCLUDE (StudentExamID, StudentID, ExamID)
WHERE SubmissionTime IS NOT NULL;
GO

-- =============================================
-- Section 6: Student Answer Indexes
-- =============================================

-- StudentAnswer indexes
CREATE NONCLUSTERED INDEX IX_StudentAnswer_StudentExamID 
ON Exam.StudentAnswer(StudentExamID) 
INCLUDE (QuestionID, IsCorrect, MarksObtained);
GO

CREATE NONCLUSTERED INDEX IX_StudentAnswer_QuestionID 
ON Exam.StudentAnswer(QuestionID) 
INCLUDE (StudentExamID, IsCorrect);
GO

CREATE NONCLUSTERED INDEX IX_StudentAnswer_ManualGrading 
ON Exam.StudentAnswer(NeedsManualGrading, StudentExamID) 
WHERE NeedsManualGrading = 1;
GO

CREATE NONCLUSTERED INDEX IX_StudentAnswer_AnsweredDate 
ON Exam.StudentAnswer(AnsweredDate) 
INCLUDE (StudentExamID, QuestionID);
GO

-- =============================================
-- Section 7: Audit Log Indexes
-- =============================================

-- AuditLog indexes
CREATE NONCLUSTERED INDEX IX_AuditLog_TableName 
ON Security.AuditLog(TableName, AuditDate DESC);
GO

CREATE NONCLUSTERED INDEX IX_AuditLog_UserID 
ON Security.AuditLog(UserID, AuditDate DESC);
GO

CREATE NONCLUSTERED INDEX IX_AuditLog_Date 
ON Security.AuditLog(AuditDate DESC);
GO

-- =============================================
-- Section 8: Full-Text Indexes (Optional - for text search)
-- =============================================

-- Enable full-text search on database if needed
-- Uncomment if full-text search is required

/*
-- Create full-text catalog
CREATE FULLTEXT CATALOG ExamSystemCatalog AS DEFAULT;
GO

-- Full-text index on Question text
CREATE FULLTEXT INDEX ON Exam.Question(QuestionText)
    KEY INDEX PK_Question
    WITH STOPLIST = SYSTEM;
GO

-- Full-text index on Student answers
CREATE FULLTEXT INDEX ON Exam.StudentAnswer(StudentAnswerText)
    KEY INDEX PK_StudentAnswer
    WITH STOPLIST = SYSTEM;
GO
*/

PRINT 'All indexes created successfully!';
GO

-- =============================================
-- Performance Statistics Update
-- =============================================

-- Update statistics for all tables
UPDATE STATISTICS Academic.Branch WITH FULLSCAN;
UPDATE STATISTICS Academic.Track WITH FULLSCAN;
UPDATE STATISTICS Academic.Intake WITH FULLSCAN;
UPDATE STATISTICS Security.[User] WITH FULLSCAN;
UPDATE STATISTICS Academic.Instructor WITH FULLSCAN;
UPDATE STATISTICS Academic.Student WITH FULLSCAN;
UPDATE STATISTICS Academic.Course WITH FULLSCAN;
UPDATE STATISTICS Academic.CourseInstructor WITH FULLSCAN;
UPDATE STATISTICS Academic.StudentCourse WITH FULLSCAN;
UPDATE STATISTICS Exam.Question WITH FULLSCAN;
UPDATE STATISTICS Exam.QuestionOption WITH FULLSCAN;
UPDATE STATISTICS Exam.QuestionAnswer WITH FULLSCAN;
UPDATE STATISTICS Exam.Exam WITH FULLSCAN;
UPDATE STATISTICS Exam.ExamQuestion WITH FULLSCAN;
UPDATE STATISTICS Exam.StudentExam WITH FULLSCAN;
UPDATE STATISTICS Exam.StudentAnswer WITH FULLSCAN;
GO

PRINT 'Statistics updated!';
GO

-- =============================================
-- Query to view all indexes
-- =============================================
/*
SELECT 
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName,
    ic.key_ordinal AS ColumnOrder
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id IN (
    SELECT object_id FROM sys.tables WHERE schema_id IN (
        SELECT schema_id FROM sys.schemas WHERE name IN ('Academic', 'Exam', 'Security')
    )
)
ORDER BY SchemaName, TableName, IndexName, ColumnOrder;
*/
GO
