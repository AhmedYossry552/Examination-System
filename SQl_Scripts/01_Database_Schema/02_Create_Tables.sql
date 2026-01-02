/*=============================================
  Examination System - Table Creation Script
  Description: Creates all tables with proper datatypes and constraints
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Section 1: Academic Structure Tables (PRIMARY File Group)
-- =============================================

-- Branch Table
CREATE TABLE Academic.Branch (
    BranchID INT IDENTITY(1,1) NOT NULL,
    BranchName NVARCHAR(100) NOT NULL,
    BranchLocation NVARCHAR(200) NOT NULL,
    BranchManager NVARCHAR(100) NULL,
    PhoneNumber NVARCHAR(20) NULL,
    Email NVARCHAR(100) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_Branch PRIMARY KEY CLUSTERED (BranchID)
) ON [PRIMARY];
GO

-- Track Table
CREATE TABLE Academic.Track (
    TrackID INT IDENTITY(1,1) NOT NULL,
    TrackName NVARCHAR(100) NOT NULL,
    BranchID INT NOT NULL,
    TrackDescription NVARCHAR(500) NULL,
    DurationMonths INT NOT NULL DEFAULT 3,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_Track PRIMARY KEY CLUSTERED (TrackID),
    CONSTRAINT FK_Track_Branch FOREIGN KEY (BranchID) 
        REFERENCES Academic.Branch(BranchID)
) ON [PRIMARY];
GO

-- Intake Table
CREATE TABLE Academic.Intake (
    IntakeID INT IDENTITY(1,1) NOT NULL,
    IntakeName NVARCHAR(50) NOT NULL,
    IntakeYear INT NOT NULL,
    IntakeNumber INT NOT NULL, -- Q1, Q2, Q3, Q4
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_Intake PRIMARY KEY CLUSTERED (IntakeID),
    CONSTRAINT CHK_Intake_Year CHECK (IntakeYear >= 2020 AND IntakeYear <= 2100),
    CONSTRAINT CHK_Intake_Number CHECK (IntakeNumber BETWEEN 1 AND 4),
    CONSTRAINT CHK_Intake_Dates CHECK (EndDate > StartDate)
) ON [PRIMARY];
GO

-- =============================================
-- Section 2: User Management Tables (FG_Users)
-- =============================================

-- User Base Table
CREATE TABLE Security.[User] (
    UserID INT IDENTITY(1,1) NOT NULL,
    Username NVARCHAR(50) NOT NULL,
    PasswordHash NVARCHAR(256) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    PhoneNumber NVARCHAR(20) NULL,
    UserType NVARCHAR(20) NOT NULL, -- Admin, TrainingManager, Instructor, Student
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    LastLoginDate DATETIME2(3) NULL,
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_User PRIMARY KEY CLUSTERED (UserID),
    CONSTRAINT UQ_User_Username UNIQUE (Username),
    CONSTRAINT UQ_User_Email UNIQUE (Email),
    CONSTRAINT CHK_User_Type CHECK (UserType IN ('Admin', 'TrainingManager', 'Instructor', 'Student'))
) ON FG_Users;
GO

-- Instructor Table
CREATE TABLE Academic.Instructor (
    InstructorID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL,
    Specialization NVARCHAR(100) NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(10,2) NULL,
    IsTrainingManager BIT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_Instructor PRIMARY KEY CLUSTERED (InstructorID),
    CONSTRAINT FK_Instructor_User FOREIGN KEY (UserID) 
        REFERENCES Security.[User](UserID),
    CONSTRAINT UQ_Instructor_User UNIQUE (UserID)
) ON FG_Users;
GO

-- Student Table
CREATE TABLE Academic.Student (
    StudentID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL,
    IntakeID INT NOT NULL,
    BranchID INT NOT NULL,
    TrackID INT NOT NULL,
    EnrollmentDate DATE NOT NULL,
    GraduationDate DATE NULL,
    GPA DECIMAL(3,2) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_Student PRIMARY KEY CLUSTERED (StudentID),
    CONSTRAINT FK_Student_User FOREIGN KEY (UserID) 
        REFERENCES Security.[User](UserID),
    CONSTRAINT FK_Student_Intake FOREIGN KEY (IntakeID) 
        REFERENCES Academic.Intake(IntakeID),
    CONSTRAINT FK_Student_Branch FOREIGN KEY (BranchID) 
        REFERENCES Academic.Branch(BranchID),
    CONSTRAINT FK_Student_Track FOREIGN KEY (TrackID) 
        REFERENCES Academic.Track(TrackID),
    CONSTRAINT UQ_Student_User UNIQUE (UserID),
    CONSTRAINT CHK_Student_GPA CHECK (GPA IS NULL OR (GPA >= 0 AND GPA <= 4.0))
) ON FG_Users;
GO

-- =============================================
-- Section 3: Course Management Tables (FG_Courses)
-- =============================================

-- Course Table
CREATE TABLE Academic.Course (
    CourseID INT IDENTITY(1,1) NOT NULL,
    CourseName NVARCHAR(100) NOT NULL,
    CourseCode NVARCHAR(20) NOT NULL,
    CourseDescription NVARCHAR(1000) NULL,
    MaxDegree INT NOT NULL,
    MinDegree INT NOT NULL,
    TotalHours INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_Course PRIMARY KEY CLUSTERED (CourseID),
    CONSTRAINT UQ_Course_Code UNIQUE (CourseCode),
    CONSTRAINT CHK_Course_Degrees CHECK (MaxDegree > MinDegree AND MinDegree >= 0),
    CONSTRAINT CHK_Course_Hours CHECK (TotalHours > 0)
) ON FG_Courses;
GO

-- CourseInstructor Bridge Table
CREATE TABLE Academic.CourseInstructor (
    CourseInstructorID INT IDENTITY(1,1) NOT NULL,
    CourseID INT NOT NULL,
    InstructorID INT NOT NULL,
    IntakeID INT NOT NULL,
    BranchID INT NOT NULL,
    TrackID INT NOT NULL,
    AssignedDate DATE NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_CourseInstructor PRIMARY KEY CLUSTERED (CourseInstructorID),
    CONSTRAINT FK_CourseInstructor_Course FOREIGN KEY (CourseID) 
        REFERENCES Academic.Course(CourseID),
    CONSTRAINT FK_CourseInstructor_Instructor FOREIGN KEY (InstructorID) 
        REFERENCES Academic.Instructor(InstructorID),
    CONSTRAINT FK_CourseInstructor_Intake FOREIGN KEY (IntakeID) 
        REFERENCES Academic.Intake(IntakeID),
    CONSTRAINT FK_CourseInstructor_Branch FOREIGN KEY (BranchID) 
        REFERENCES Academic.Branch(BranchID),
    CONSTRAINT FK_CourseInstructor_Track FOREIGN KEY (TrackID) 
        REFERENCES Academic.Track(TrackID)
) ON FG_Courses;
GO

-- Student Course Enrollment
CREATE TABLE Academic.StudentCourse (
    StudentCourseID INT IDENTITY(1,1) NOT NULL,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollmentDate DATE NOT NULL DEFAULT GETDATE(),
    CompletionDate DATE NULL,
    FinalGrade DECIMAL(5,2) NULL,
    IsPassed BIT NULL,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_StudentCourse PRIMARY KEY CLUSTERED (StudentCourseID),
    CONSTRAINT FK_StudentCourse_Student FOREIGN KEY (StudentID) 
        REFERENCES Academic.Student(StudentID),
    CONSTRAINT FK_StudentCourse_Course FOREIGN KEY (CourseID) 
        REFERENCES Academic.Course(CourseID),
    CONSTRAINT UQ_StudentCourse UNIQUE (StudentID, CourseID)
) ON FG_Courses;
GO

-- =============================================
-- Section 4: Question Pool Tables (FG_Questions)
-- =============================================

-- Question Table
CREATE TABLE Exam.Question (
    QuestionID INT IDENTITY(1,1) NOT NULL,
    CourseID INT NOT NULL,
    InstructorID INT NOT NULL, -- Creator
    QuestionText NVARCHAR(MAX) NOT NULL,
    QuestionType NVARCHAR(20) NOT NULL, -- MultipleChoice, TrueFalse, Text
    DifficultyLevel NVARCHAR(20) NOT NULL DEFAULT 'Medium', -- Easy, Medium, Hard
    Points INT NOT NULL DEFAULT 1,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_Question PRIMARY KEY CLUSTERED (QuestionID),
    CONSTRAINT FK_Question_Course FOREIGN KEY (CourseID) 
        REFERENCES Academic.Course(CourseID),
    CONSTRAINT FK_Question_Instructor FOREIGN KEY (InstructorID) 
        REFERENCES Academic.Instructor(InstructorID),
    CONSTRAINT CHK_Question_Type CHECK (QuestionType IN ('MultipleChoice', 'TrueFalse', 'Text')),
    CONSTRAINT CHK_Question_Difficulty CHECK (DifficultyLevel IN ('Easy', 'Medium', 'Hard')),
    CONSTRAINT CHK_Question_Points CHECK (Points > 0)
) ON FG_Questions;
GO

-- Question Options (for Multiple Choice)
CREATE TABLE Exam.QuestionOption (
    OptionID INT IDENTITY(1,1) NOT NULL,
    QuestionID INT NOT NULL,
    OptionText NVARCHAR(500) NOT NULL,
    IsCorrect BIT NOT NULL DEFAULT 0,
    OptionOrder INT NOT NULL,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_QuestionOption PRIMARY KEY CLUSTERED (OptionID),
    CONSTRAINT FK_QuestionOption_Question FOREIGN KEY (QuestionID) 
        REFERENCES Exam.Question(QuestionID) ON DELETE CASCADE,
    CONSTRAINT CHK_Option_Order CHECK (OptionOrder > 0)
) ON FG_Questions;
GO

-- Question Correct Answers (for TrueFalse and Text)
CREATE TABLE Exam.QuestionAnswer (
    AnswerID INT IDENTITY(1,1) NOT NULL,
    QuestionID INT NOT NULL,
    CorrectAnswer NVARCHAR(MAX) NOT NULL,
    AnswerPattern NVARCHAR(500) NULL, -- Regex pattern for text questions (Bonus)
    CaseSensitive BIT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_QuestionAnswer PRIMARY KEY CLUSTERED (AnswerID),
    CONSTRAINT FK_QuestionAnswer_Question FOREIGN KEY (QuestionID) 
        REFERENCES Exam.Question(QuestionID) ON DELETE CASCADE
) ON FG_Questions;
GO

-- =============================================
-- Section 5: Exam Management Tables (FG_Exams)
-- =============================================

-- Exam Table
CREATE TABLE Exam.Exam (
    ExamID INT IDENTITY(1,1) NOT NULL,
    CourseID INT NOT NULL,
    InstructorID INT NOT NULL,
    IntakeID INT NOT NULL,
    BranchID INT NOT NULL,
    TrackID INT NOT NULL,
    ExamName NVARCHAR(200) NOT NULL,
    ExamYear INT NOT NULL,
    ExamType NVARCHAR(20) NOT NULL, -- Regular, Corrective
    TotalMarks INT NOT NULL,
    PassMarks INT NOT NULL,
    DurationMinutes INT NOT NULL,
    StartDateTime DATETIME2(3) NOT NULL,
    EndDateTime DATETIME2(3) NOT NULL,
    AllowanceOptions NVARCHAR(500) NULL, -- JSON format for flexibility
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_Exam PRIMARY KEY CLUSTERED (ExamID),
    CONSTRAINT FK_Exam_Course FOREIGN KEY (CourseID) 
        REFERENCES Academic.Course(CourseID),
    CONSTRAINT FK_Exam_Instructor FOREIGN KEY (InstructorID) 
        REFERENCES Academic.Instructor(InstructorID),
    CONSTRAINT FK_Exam_Intake FOREIGN KEY (IntakeID) 
        REFERENCES Academic.Intake(IntakeID),
    CONSTRAINT FK_Exam_Branch FOREIGN KEY (BranchID) 
        REFERENCES Academic.Branch(BranchID),
    CONSTRAINT FK_Exam_Track FOREIGN KEY (TrackID) 
        REFERENCES Academic.Track(TrackID),
    CONSTRAINT CHK_Exam_Type CHECK (ExamType IN ('Regular', 'Corrective', 'Remedial')),
    CONSTRAINT CHK_Exam_Marks CHECK (TotalMarks > 0 AND PassMarks >= 0 AND PassMarks <= TotalMarks),
    CONSTRAINT CHK_Exam_Duration CHECK (DurationMinutes > 0),
    CONSTRAINT CHK_Exam_DateTime CHECK (EndDateTime > StartDateTime)
) ON FG_Exams;
GO

-- Exam Questions Bridge Table
CREATE TABLE Exam.ExamQuestion (
    ExamQuestionID INT IDENTITY(1,1) NOT NULL,
    ExamID INT NOT NULL,
    QuestionID INT NOT NULL,
    QuestionOrder INT NOT NULL,
    QuestionMarks INT NOT NULL,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_ExamQuestion PRIMARY KEY CLUSTERED (ExamQuestionID),
    CONSTRAINT FK_ExamQuestion_Exam FOREIGN KEY (ExamID) 
        REFERENCES Exam.Exam(ExamID),
    CONSTRAINT FK_ExamQuestion_Question FOREIGN KEY (QuestionID) 
        REFERENCES Exam.Question(QuestionID),
    CONSTRAINT UQ_ExamQuestion UNIQUE (ExamID, QuestionID),
    CONSTRAINT CHK_ExamQuestion_Order CHECK (QuestionOrder > 0),
    CONSTRAINT CHK_ExamQuestion_Marks CHECK (QuestionMarks > 0)
) ON FG_Exams;
GO

-- Student Exam Assignment
CREATE TABLE Exam.StudentExam (
    StudentExamID INT IDENTITY(1,1) NOT NULL,
    StudentID INT NOT NULL,
    ExamID INT NOT NULL,
    IsAllowed BIT NOT NULL DEFAULT 1,
    StartTime DATETIME2(3) NULL,
    EndTime DATETIME2(3) NULL,
    SubmissionTime DATETIME2(3) NULL,
    TotalScore DECIMAL(5,2) NULL,
    IsPassed BIT NULL,
    IsGraded BIT NOT NULL DEFAULT 0,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2(3) NULL,
    CONSTRAINT PK_StudentExam PRIMARY KEY CLUSTERED (StudentExamID),
    CONSTRAINT FK_StudentExam_Student FOREIGN KEY (StudentID) 
        REFERENCES Academic.Student(StudentID),
    CONSTRAINT FK_StudentExam_Exam FOREIGN KEY (ExamID) 
        REFERENCES Exam.Exam(ExamID),
    CONSTRAINT UQ_StudentExam UNIQUE (StudentID, ExamID)
) ON FG_Exams;
GO

-- =============================================
-- Section 6: Student Answers Tables (FG_Answers)
-- =============================================

-- Student Answer Table
CREATE TABLE Exam.StudentAnswer (
    StudentAnswerID INT IDENTITY(1,1) NOT NULL,
    StudentExamID INT NOT NULL,
    QuestionID INT NOT NULL,
    StudentAnswerText NVARCHAR(MAX) NULL,
    SelectedOptionID INT NULL, -- For multiple choice
    IsCorrect BIT NULL,
    MarksObtained DECIMAL(5,2) NULL,
    NeedsManualGrading BIT NOT NULL DEFAULT 0,
    AnsweredDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    GradedDate DATETIME2(3) NULL,
    InstructorComments NVARCHAR(500) NULL,
    CONSTRAINT PK_StudentAnswer PRIMARY KEY CLUSTERED (StudentAnswerID),
    CONSTRAINT FK_StudentAnswer_StudentExam FOREIGN KEY (StudentExamID) 
        REFERENCES Exam.StudentExam(StudentExamID),
    CONSTRAINT FK_StudentAnswer_Question FOREIGN KEY (QuestionID) 
        REFERENCES Exam.Question(QuestionID),
    CONSTRAINT FK_StudentAnswer_Option FOREIGN KEY (SelectedOptionID) 
        REFERENCES Exam.QuestionOption(OptionID),
    CONSTRAINT UQ_StudentAnswer UNIQUE (StudentExamID, QuestionID)
) ON FG_Answers;
GO

-- =============================================
-- Section 7: Audit Tables (PRIMARY)
-- =============================================

-- Audit Log Table
CREATE TABLE Security.AuditLog (
    AuditID INT IDENTITY(1,1) NOT NULL,
    TableName NVARCHAR(128) NOT NULL,
    OperationType NVARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    RecordID INT NOT NULL,
    UserID INT NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    AuditDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_AuditLog PRIMARY KEY CLUSTERED (AuditID),
    CONSTRAINT CHK_AuditLog_Operation CHECK (OperationType IN ('INSERT', 'UPDATE', 'DELETE'))
) ON [PRIMARY];
GO

PRINT 'All tables created successfully!';
GO
