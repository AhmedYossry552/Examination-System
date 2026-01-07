/*=============================================
  Examination System - Additional Constraints Script
  Description: Creates additional business logic constraints
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

PRINT 'Creating Additional Constraints...';
GO

-- =============================================
-- Section 1: Default Constraints
-- =============================================

-- User defaults
ALTER TABLE Security.[User]
ADD CONSTRAINT DF_User_IsActive DEFAULT 1 FOR IsActive;
GO

ALTER TABLE Security.[User]
ADD CONSTRAINT DF_User_CreatedDate DEFAULT GETDATE() FOR CreatedDate;
GO

-- =============================================
-- Section 2: Business Rule Constraints
-- =============================================

-- Ensure at least one Training Manager exists (will be enforced by trigger)
-- Constraint: Course Max Degree must be reasonable (between 50 and 500)
ALTER TABLE Academic.Course
ADD CONSTRAINT CHK_Course_MaxDegree_Range 
CHECK (MaxDegree >= 50 AND MaxDegree <= 500);
GO

-- Constraint: Pass marks should be at least 50% of total marks
ALTER TABLE Exam.Exam
ADD CONSTRAINT CHK_Exam_PassPercentage 
CHECK (PassMarks >= (TotalMarks * 0.5));
GO

-- Constraint: Exam duration should be reasonable (15 min to 4 hours)
ALTER TABLE Exam.Exam
ADD CONSTRAINT CHK_Exam_Duration_Range 
CHECK (DurationMinutes >= 15 AND DurationMinutes <= 240);
GO

-- Constraint: Question points should be reasonable (1 to 50)
ALTER TABLE Exam.Question
ADD CONSTRAINT CHK_Question_Points_Range 
CHECK (Points >= 1 AND Points <= 50);
GO

-- Constraint: Multiple choice should have at least 2 options
-- (Will be enforced by trigger after insert)

-- Constraint: Exactly one correct answer for multiple choice
-- (Will be enforced by trigger)

-- Constraint: Student answer marks cannot exceed question marks
-- (Will be enforced by trigger and stored procedure)

-- =============================================
-- Section 3: Computed Columns (if needed)
-- =============================================

-- Add computed column for full name in User table
ALTER TABLE Security.[User]
ADD FullName AS (FirstName + ' ' + LastName) PERSISTED;
GO

-- Add computed column for exam window in Exam table
ALTER TABLE Exam.Exam
ADD ExamWindow AS (
    CAST(DATEDIFF(MINUTE, StartDateTime, EndDateTime) AS NVARCHAR(10)) + ' minutes'
) PERSISTED;
GO

PRINT 'Additional constraints created successfully!';
GO

-- =============================================
-- Section 4: Constraint Verification Queries
-- =============================================

/*
-- View all constraints
SELECT 
    OBJECT_SCHEMA_NAME(parent_object_id) AS SchemaName,
    OBJECT_NAME(parent_object_id) AS TableName,
    name AS ConstraintName,
    type_desc AS ConstraintType
FROM sys.objects
WHERE type_desc LIKE '%CONSTRAINT%'
    AND OBJECT_SCHEMA_NAME(parent_object_id) IN ('Academic', 'Exam', 'Security')
ORDER BY SchemaName, TableName, ConstraintType;
*/
GO
