-- Insert Exam Submission Test Data for QA Testing
USE ExaminationSystemDB;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- First, update StudentExam records with start times (simulate students taking exams)
UPDATE Exam.StudentExam 
SET StartTime = DATEADD(HOUR, -2, GETDATE()),
    EndTime = DATEADD(HOUR, -1, GETDATE()),
    SubmissionTime = DATEADD(HOUR, -1, GETDATE())
WHERE StudentExamID IN (1, 2);

-- Get questions for Exam 1
DECLARE @ExamID INT = 1;
DECLARE @StudentExamID1 INT = 1;  -- Student 5
DECLARE @StudentExamID2 INT = 2;  -- Student 17

-- Insert Student Answers for StudentExam 1 (Student 5 taking Exam 1)
-- Using questions that are in ExamQuestion for ExamID = 1
INSERT INTO Exam.StudentAnswer (StudentExamID, QuestionID, SelectedOptionID, IsCorrect, MarksObtained, NeedsManualGrading, AnsweredDate)
SELECT 
    @StudentExamID1,
    eq.QuestionID,
    (SELECT TOP 1 OptionID FROM Exam.QuestionOption WHERE QuestionID = eq.QuestionID ORDER BY NEWID()),  -- Random option
    NULL,  -- Will be calculated
    NULL,  -- Will be calculated
    0,     -- Auto-graded
    DATEADD(MINUTE, -90, GETDATE())
FROM Exam.ExamQuestion eq
WHERE eq.ExamID = @ExamID;

-- Insert Student Answers for StudentExam 2 (Student 17 taking Exam 1)
INSERT INTO Exam.StudentAnswer (StudentExamID, QuestionID, SelectedOptionID, IsCorrect, MarksObtained, NeedsManualGrading, AnsweredDate)
SELECT 
    @StudentExamID2,
    eq.QuestionID,
    (SELECT TOP 1 OptionID FROM Exam.QuestionOption WHERE QuestionID = eq.QuestionID ORDER BY NEWID()),  -- Random option
    NULL,
    NULL,
    0,
    DATEADD(MINUTE, -80, GETDATE())
FROM Exam.ExamQuestion eq
WHERE eq.ExamID = @ExamID;

-- Update IsCorrect and MarksObtained based on selected options
UPDATE sa
SET sa.IsCorrect = qo.IsCorrect,
    sa.MarksObtained = CASE WHEN qo.IsCorrect = 1 THEN eq.QuestionMarks ELSE 0 END
FROM Exam.StudentAnswer sa
JOIN Exam.QuestionOption qo ON sa.SelectedOptionID = qo.OptionID
JOIN Exam.ExamQuestion eq ON sa.QuestionID = eq.QuestionID AND eq.ExamID = @ExamID;

-- Calculate and update total scores in StudentExam
UPDATE se
SET se.TotalScore = (SELECT ISNULL(SUM(MarksObtained), 0) FROM Exam.StudentAnswer sa WHERE sa.StudentExamID = se.StudentExamID),
    se.IsGraded = 1,
    se.IsPassed = CASE 
        WHEN (SELECT ISNULL(SUM(MarksObtained), 0) FROM Exam.StudentAnswer sa WHERE sa.StudentExamID = se.StudentExamID) >= 
             (SELECT PassMarks FROM Exam.Exam WHERE ExamID = se.ExamID) THEN 1 
        ELSE 0 
    END
FROM Exam.StudentExam se
WHERE se.StudentExamID IN (@StudentExamID1, @StudentExamID2);

-- Also add a Text question with pending manual grading
-- First check if there's a text question
DECLARE @TextQuestionID INT;
SELECT TOP 1 @TextQuestionID = QuestionID FROM Exam.Question WHERE QuestionType = 'Text';

IF @TextQuestionID IS NOT NULL
BEGIN
    -- Add text answer that needs manual grading
    INSERT INTO Exam.StudentAnswer (StudentExamID, QuestionID, StudentAnswerText, IsCorrect, MarksObtained, NeedsManualGrading, AnsweredDate)
    VALUES 
        (1, @TextQuestionID, 'SQL stands for Structured Query Language. It is used to communicate with databases and perform operations like SELECT, INSERT, UPDATE, DELETE.', NULL, NULL, 1, DATEADD(MINUTE, -85, GETDATE())),
        (2, @TextQuestionID, 'SQL is a programming language for managing data in relational databases.', NULL, NULL, 1, DATEADD(MINUTE, -75, GETDATE()));
    
    -- Mark these exams as not fully graded
    UPDATE Exam.StudentExam SET IsGraded = 0 WHERE StudentExamID IN (1, 2);
END

-- Verify
SELECT 'StudentExam records updated:' AS Info;
SELECT StudentExamID, StudentID, ExamID, TotalScore, IsPassed, IsGraded FROM Exam.StudentExam WHERE StudentExamID IN (1,2);

SELECT 'StudentAnswers inserted:' AS Info;
SELECT COUNT(*) AS AnswerCount FROM Exam.StudentAnswer;

SELECT 'Pending Manual Grading:' AS Info;
SELECT COUNT(*) AS PendingGrading FROM Exam.StudentAnswer WHERE NeedsManualGrading = 1 AND IsCorrect IS NULL;
GO
