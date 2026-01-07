# Examination System - Entity Relationship Diagram (ERD)

## Core Entities

### 1. User Management
- **User** (Base table for all system users)
  - UserID (PK)
  - Username
  - PasswordHash
  - Email
  - FirstName
  - LastName
  - PhoneNumber
  - UserType (Admin/TrainingManager/Instructor/Student)
  - IsActive
  - CreatedDate
  - LastLoginDate

### 2. Academic Structure
- **Branch**
  - BranchID (PK)
  - BranchName
  - BranchLocation
  - IsActive

- **Track**
  - TrackID (PK)
  - TrackName
  - BranchID (FK)
  - Description
  - IsActive

- **Intake**
  - IntakeID (PK)
  - IntakeName
  - IntakeYear
  - StartDate
  - EndDate
  - IsActive

### 3. Course Management
- **Course**
  - CourseID (PK)
  - CourseName
  - CourseDescription
  - MaxDegree
  - MinDegree
  - TotalHours
  - IsActive

- **CourseInstructor** (Bridge table)
  - CourseInstructorID (PK)
  - CourseID (FK)
  - InstructorID (FK)
  - IntakeID (FK)
  - BranchID (FK)
  - TrackID (FK)
  - AssignedDate
  - IsActive

### 4. Student Information
- **Student**
  - StudentID (PK)
  - UserID (FK)
  - IntakeID (FK)
  - BranchID (FK)
  - TrackID (FK)
  - EnrollmentDate
  - GraduationDate
  - IsActive

- **StudentCourse** (Enrollment)
  - StudentCourseID (PK)
  - StudentID (FK)
  - CourseID (FK)
  - EnrollmentDate
  - FinalGrade
  - IsPassed

### 5. Instructor Information
- **Instructor**
  - InstructorID (PK)
  - UserID (FK)
  - Specialization
  - HireDate
  - IsTrainingManager
  - IsActive

### 6. Question Pool
- **Question**
  - QuestionID (PK)
  - CourseID (FK)
  - InstructorID (FK - creator)
  - QuestionText
  - QuestionType (MultipleChoice/TrueFalse/Text)
  - DifficultyLevel (Easy/Medium/Hard)
  - Points
  - CreatedDate
  - ModifiedDate
  - IsActive

- **QuestionOption** (For multiple choice)
  - OptionID (PK)
  - QuestionID (FK)
  - OptionText
  - IsCorrect
  - OptionOrder

- **QuestionAnswer** (Correct answers)
  - AnswerID (PK)
  - QuestionID (FK)
  - CorrectAnswer (For True/False and Text)
  - AnswerPattern (Regex for text validation - Bonus)

### 7. Exam Management
- **Exam**
  - ExamID (PK)
  - CourseID (FK)
  - InstructorID (FK)
  - IntakeID (FK)
  - BranchID (FK)
  - TrackID (FK)
  - ExamName
  - ExamType (Regular/Corrective)
  - TotalMarks
  - PassMarks
  - DurationMinutes
  - StartDateTime
  - EndDateTime
  - AllowanceOptions (LateSubmission/Calculator/etc.)
  - CreatedDate
  - IsActive

- **ExamQuestion** (Questions in specific exam)
  - ExamQuestionID (PK)
  - ExamID (FK)
  - QuestionID (FK)
  - QuestionOrder
  - QuestionMarks

- **StudentExam** (Student access to exam)
  - StudentExamID (PK)
  - StudentID (FK)
  - ExamID (FK)
  - IsAllowed
  - StartTime
  - EndTime
  - SubmissionTime
  - TotalScore
  - IsPassed
  - IsGraded

### 8. Student Answers
- **StudentAnswer**
  - StudentAnswerID (PK)
  - StudentExamID (FK)
  - QuestionID (FK)
  - StudentAnswerText
  - SelectedOptionID (FK - for multiple choice)
  - IsCorrect
  - MarksObtained
  - AnsweredDate
  - NeedsManualGrading

## Relationships

### One-to-Many Relationships
1. User → Student (1:1)
2. User → Instructor (1:1)
3. Branch → Track (1:N)
4. Course → Question (1:N)
5. Course → Exam (1:N)
6. Exam → ExamQuestion (1:N)
7. Exam → StudentExam (1:N)
8. Question → QuestionOption (1:N)
9. Student → StudentExam (1:N)
10. StudentExam → StudentAnswer (1:N)
11. Instructor → Question (1:N)
12. Instructor → Exam (1:N)

### Many-to-Many Relationships
1. Course ↔ Instructor (via CourseInstructor)
2. Student ↔ Course (via StudentCourse)
3. Exam ↔ Question (via ExamQuestion)

## Business Rules

### Constraints
1. Each course must have MaxDegree > MinDegree
2. Each exam TotalMarks must not exceed Course MaxDegree
3. Instructor can only modify questions in courses they teach
4. Student can only access exams during specified time window
5. Training Manager must be an Instructor (IsTrainingManager = 1)
6. Exam duration must be positive
7. Question points must be positive
8. Student final grade in course = sum of all exam scores

### Triggers Required
1. **After Exam Submission**: Calculate total score automatically
2. **Before Question Delete**: Check if question is used in any active exam
3. **After Student Answer Insert**: Auto-grade objective questions
4. **Before Exam Create**: Validate total marks don't exceed course max
5. **After All Answers Graded**: Update StudentExam.IsGraded flag
6. **Audit Triggers**: Log all critical data changes

## Indexes Strategy

### Clustered Indexes
- All PKs will have clustered indexes by default

### Non-Clustered Indexes
1. User.Username (Unique)
2. User.Email (Unique)
3. User.UserType
4. Student.UserID
5. Instructor.UserID
6. Course.CourseName
7. Question.CourseID + QuestionType
8. Exam.CourseID + StartDateTime
9. StudentExam.StudentID + ExamID
10. StudentAnswer.StudentExamID + QuestionID
11. CourseInstructor.InstructorID + CourseID

## File Groups Strategy

### PRIMARY File Group
- System tables and small lookup tables
- Branch, Track, Intake

### FG_Users
- User, Student, Instructor tables

### FG_Courses
- Course, CourseInstructor, StudentCourse

### FG_Questions
- Question, QuestionOption, QuestionAnswer

### FG_Exams
- Exam, ExamQuestion, StudentExam

### FG_Answers
- StudentAnswer (Largest table, separate for performance)

## Security Model

### Database Roles
1. **db_admin**: Full control (System administrators)
2. **db_training_manager**: Manage courses, instructors, students
3. **db_instructor**: Manage questions and exams for assigned courses
4. **db_student**: View and submit exams

### Row-Level Security
- Instructors: Only see/modify their courses and exams
- Students: Only see their own exams and grades
- Training Manager: Access all data except other users' passwords

## Notes for API Development
- All business logic will be in stored procedures
- Views will provide clean data access layer
- API will only call stored procedures (no direct table access)
- Authentication tokens will be validated against User table
- Audit logging built into database triggers
