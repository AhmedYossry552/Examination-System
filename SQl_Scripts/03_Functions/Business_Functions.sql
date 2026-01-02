/*=============================================
  Examination System - Business Functions
  Description: Scalar and table-valued functions for business logic
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Function: FN_CalculateExamGrade
-- Description: Calculates percentage grade for an exam
-- =============================================
CREATE OR ALTER FUNCTION Exam.FN_CalculateExamGrade
(
    @TotalScore DECIMAL(5,2),
    @TotalMarks INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Percentage DECIMAL(5,2);
    
    IF @TotalMarks = 0
        SET @Percentage = 0;
    ELSE
        SET @Percentage = (@TotalScore / @TotalMarks) * 100;
    
    RETURN @Percentage;
END
GO

-- =============================================
-- Function: FN_GetStudentCourseGrade
-- Description: Gets student's total grade for a course
-- =============================================
CREATE OR ALTER FUNCTION Academic.FN_GetStudentCourseGrade
(
    @StudentID INT,
    @CourseID INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @TotalGrade DECIMAL(5,2);
    
    SELECT @TotalGrade = ISNULL(SUM(se.TotalScore), 0)
    FROM Exam.StudentExam se
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    WHERE se.StudentID = @StudentID
        AND e.CourseID = @CourseID
        AND se.IsGraded = 1;
    
    RETURN @TotalGrade;
END
GO

-- =============================================
-- Function: FN_IsInstructorTeachingCourse
-- Description: Checks if instructor teaches a specific course
-- =============================================
CREATE OR ALTER FUNCTION Academic.FN_IsInstructorTeachingCourse
(
    @InstructorID INT,
    @CourseID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsTeaching BIT = 0;
    
    IF EXISTS (
        SELECT 1 FROM Academic.CourseInstructor
        WHERE InstructorID = @InstructorID 
            AND CourseID = @CourseID 
            AND IsActive = 1
    )
        SET @IsTeaching = 1;
    
    RETURN @IsTeaching;
END
GO

-- =============================================
-- Function: FN_IsExamAvailable
-- Description: Checks if exam is available for student to take
-- =============================================
CREATE OR ALTER FUNCTION Exam.FN_IsExamAvailable
(
    @ExamID INT,
    @CurrentDateTime DATETIME2(3)
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsAvailable BIT = 0;
    DECLARE @StartDateTime DATETIME2(3);
    DECLARE @EndDateTime DATETIME2(3);
    
    SELECT @StartDateTime = StartDateTime, @EndDateTime = EndDateTime
    FROM Exam.Exam
    WHERE ExamID = @ExamID;
    
    IF @CurrentDateTime >= @StartDateTime AND @CurrentDateTime <= @EndDateTime
        SET @IsAvailable = 1;
    
    RETURN @IsAvailable;
END
GO

-- =============================================
-- Function: FN_GetExamDurationRemaining
-- Description: Calculates remaining minutes for an exam
-- =============================================
CREATE OR ALTER FUNCTION Exam.FN_GetExamDurationRemaining
(
    @StudentExamID INT,
    @CurrentDateTime DATETIME2(3)
)
RETURNS INT
AS
BEGIN
    DECLARE @RemainingMinutes INT;
    DECLARE @StartTime DATETIME2(3);
    DECLARE @DurationMinutes INT;
    DECLARE @ElapsedMinutes INT;
    
    SELECT 
        @StartTime = se.StartTime,
        @DurationMinutes = e.DurationMinutes
    FROM Exam.StudentExam se
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    WHERE se.StudentExamID = @StudentExamID;
    
    IF @StartTime IS NULL
        RETURN @DurationMinutes;
    
    SET @ElapsedMinutes = DATEDIFF(MINUTE, @StartTime, @CurrentDateTime);
    SET @RemainingMinutes = @DurationMinutes - @ElapsedMinutes;
    
    IF @RemainingMinutes < 0
        SET @RemainingMinutes = 0;
    
    RETURN @RemainingMinutes;
END
GO

-- =============================================
-- Function: FN_GetStudentGPA
-- Description: Calculates student's GPA
-- =============================================
CREATE OR ALTER FUNCTION Academic.FN_GetStudentGPA
(
    @StudentID INT
)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @GPA DECIMAL(3,2);
    
    SELECT @GPA = AVG(
        CASE 
            WHEN FinalGrade >= 90 THEN 4.0
            WHEN FinalGrade >= 85 THEN 3.7
            WHEN FinalGrade >= 80 THEN 3.3
            WHEN FinalGrade >= 75 THEN 3.0
            WHEN FinalGrade >= 70 THEN 2.7
            WHEN FinalGrade >= 65 THEN 2.3
            WHEN FinalGrade >= 60 THEN 2.0
            WHEN FinalGrade >= 50 THEN 1.0
            ELSE 0.0
        END
    )
    FROM Academic.StudentCourse
    WHERE StudentID = @StudentID
        AND FinalGrade IS NOT NULL;
    
    RETURN ISNULL(@GPA, 0);
END
GO

-- =============================================
-- Table-Valued Function: FN_GetCourseStatistics
-- Description: Returns statistics for a course
-- =============================================
CREATE OR ALTER FUNCTION Academic.FN_GetCourseStatistics
(
    @CourseID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        @CourseID AS CourseID,
        COUNT(DISTINCT sc.StudentID) AS EnrolledStudents,
        COUNT(DISTINCT e.ExamID) AS TotalExams,
        COUNT(DISTINCT q.QuestionID) AS TotalQuestions,
        AVG(sc.FinalGrade) AS AverageFinalGrade,
        SUM(CASE WHEN sc.IsPassed = 1 THEN 1 ELSE 0 END) AS PassedStudents,
        SUM(CASE WHEN sc.IsPassed = 0 THEN 1 ELSE 0 END) AS FailedStudents
    FROM Academic.Course c
    LEFT JOIN Academic.StudentCourse sc ON c.CourseID = sc.CourseID
    LEFT JOIN Exam.Exam e ON c.CourseID = e.CourseID AND e.IsActive = 1
    LEFT JOIN Exam.Question q ON c.CourseID = q.CourseID AND q.IsActive = 1
    WHERE c.CourseID = @CourseID
    GROUP BY c.CourseID
);
GO

-- =============================================
-- Table-Valued Function: FN_GetStudentExamHistory
-- Description: Returns student's exam history
-- =============================================
CREATE OR ALTER FUNCTION Exam.FN_GetStudentExamHistory
(
    @StudentID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        e.ExamID,
        e.ExamName,
        c.CourseName,
        c.CourseCode,
        e.ExamType,
        e.TotalMarks,
        e.PassMarks,
        se.TotalScore,
        se.IsPassed,
        se.StartTime,
        se.SubmissionTime,
        DATEDIFF(MINUTE, se.StartTime, se.SubmissionTime) AS TimeTakenMinutes,
        Exam.FN_CalculateExamGrade(se.TotalScore, e.TotalMarks) AS Percentage
    FROM Exam.StudentExam se
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    WHERE se.StudentID = @StudentID
        AND se.SubmissionTime IS NOT NULL
);
GO

-- =============================================
-- Table-Valued Function: FN_GetInstructorWorkload
-- Description: Returns instructor's workload statistics
-- =============================================
CREATE OR ALTER FUNCTION Academic.FN_GetInstructorWorkload
(
    @InstructorID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        i.InstructorID,
        u.FirstName + ' ' + u.LastName AS InstructorName,
        COUNT(DISTINCT ci.CourseID) AS CoursesTeaching,
        COUNT(DISTINCT e.ExamID) AS ExamsCreated,
        COUNT(DISTINCT q.QuestionID) AS QuestionsCreated,
        COUNT(DISTINCT CASE WHEN sa.NeedsManualGrading = 1 THEN sa.StudentAnswerID END) AS AnswersPendingGrading
    FROM Academic.Instructor i
    INNER JOIN Security.[User] u ON i.UserID = u.UserID
    LEFT JOIN Academic.CourseInstructor ci ON i.InstructorID = ci.InstructorID AND ci.IsActive = 1
    LEFT JOIN Exam.Exam e ON i.InstructorID = e.InstructorID AND e.IsActive = 1
    LEFT JOIN Exam.Question q ON i.InstructorID = q.InstructorID AND q.IsActive = 1
    LEFT JOIN Exam.StudentAnswer sa ON e.ExamID IN (
        SELECT ExamID FROM Exam.StudentExam WHERE StudentExamID = sa.StudentExamID
    )
    WHERE i.InstructorID = @InstructorID
    GROUP BY i.InstructorID, u.FirstName, u.LastName
);
GO

-- =============================================
-- Table-Valued Function: FN_GetExamQuestions
-- Description: Returns all questions for an exam with details
-- =============================================
CREATE OR ALTER FUNCTION Exam.FN_GetExamQuestions
(
    @ExamID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        eq.ExamQuestionID,
        eq.QuestionOrder,
        eq.QuestionMarks,
        q.QuestionID,
        q.QuestionText,
        q.QuestionType,
        q.DifficultyLevel
    FROM Exam.ExamQuestion eq
    INNER JOIN Exam.Question q ON eq.QuestionID = q.QuestionID
    WHERE eq.ExamID = @ExamID
);
GO

-- =============================================
-- Function: FN_TextAnswerSimilarity (BONUS FEATURE - ADVANCED)
-- Description: Advanced similarity calculation with keyword matching
-- Uses multiple algorithms: Exact match, Contains, Keyword analysis
-- =============================================
CREATE OR ALTER FUNCTION Exam.FN_TextAnswerSimilarity
(
    @StudentAnswer NVARCHAR(MAX),
    @CorrectAnswer NVARCHAR(MAX)
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Similarity DECIMAL(5,2) = 0.0;
    DECLARE @StudentLower NVARCHAR(MAX) = LOWER(LTRIM(RTRIM(@StudentAnswer)));
    DECLARE @CorrectLower NVARCHAR(MAX) = LOWER(LTRIM(RTRIM(@CorrectAnswer)));
    
    -- Handle empty answers
    IF @StudentLower = '' OR @CorrectLower = ''
    BEGIN
        RETURN 0.0;
    END
    
    -- 1. Exact Match (100% score)
    IF @StudentLower = @CorrectLower
    BEGIN
        RETURN 100.0;
    END
    
    -- 2. Contains full answer (85% score)
    IF @StudentLower LIKE '%' + @CorrectLower + '%'
    BEGIN
        RETURN 85.0;
    END
    
    -- 3. Keyword Matching (Advanced Algorithm)
    DECLARE @Keywords TABLE (Keyword NVARCHAR(100));
    DECLARE @TotalKeywords INT = 0;
    DECLARE @MatchedKeywords INT = 0;
    DECLARE @Keyword NVARCHAR(100);
    
    -- Extract keywords from correct answer (words longer than 3 chars)
    INSERT INTO @Keywords (Keyword)
    SELECT DISTINCT LOWER(LTRIM(RTRIM(value)))
    FROM STRING_SPLIT(@CorrectAnswer, ' ')
    WHERE LEN(LTRIM(RTRIM(value))) > 3 
        AND LTRIM(RTRIM(value)) NOT IN ('the', 'and', 'with', 'that', 'this', 'from', 'have', 'has');
    
    SELECT @TotalKeywords = COUNT(*) FROM @Keywords;
    
    -- Count matched keywords
    SELECT @MatchedKeywords = COUNT(*)
    FROM @Keywords k
    WHERE @StudentLower LIKE '%' + k.Keyword + '%';
    
    -- 4. Calculate keyword-based similarity
    IF @TotalKeywords > 0
    BEGIN
        DECLARE @KeywordScore DECIMAL(5,2);
        SET @KeywordScore = (@MatchedKeywords * 100.0) / @TotalKeywords;
        
        -- If high keyword match, return good score
        IF @KeywordScore >= 80.0
            RETURN 75.0;
        ELSE IF @KeywordScore >= 60.0
            RETURN 60.0;
        ELSE IF @KeywordScore >= 40.0
            RETURN 40.0;
        ELSE IF @KeywordScore >= 20.0
            RETURN 20.0;
    END
    
    -- 5. Partial match (if student answer is contained in correct answer)
    IF @CorrectLower LIKE '%' + @StudentLower + '%'
    BEGIN
        RETURN 30.0;
    END
    
    -- 6. Length similarity as last resort
    DECLARE @LengthDiff INT = ABS(LEN(@StudentLower) - LEN(@CorrectLower));
    DECLARE @MaxLength INT = CASE WHEN LEN(@StudentLower) > LEN(@CorrectLower) 
                                  THEN LEN(@StudentLower) ELSE LEN(@CorrectLower) END;
    
    IF @MaxLength > 0 AND @LengthDiff < (@MaxLength * 0.3) -- Within 30% length difference
    BEGIN
        RETURN 15.0;
    END
    
    RETURN 0.0;
END
GO

-- =============================================
-- Function: FN_GetAcademicYear
-- Description: Determines academic year from date
-- =============================================
CREATE OR ALTER FUNCTION Academic.FN_GetAcademicYear
(
    @Date DATE
)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Year INT = YEAR(@Date);
    DECLARE @Month INT = MONTH(@Date);
    DECLARE @AcademicYear NVARCHAR(20);
    
    IF @Month >= 9 -- Academic year starts in September
        SET @AcademicYear = CAST(@Year AS NVARCHAR(4)) + '-' + CAST(@Year + 1 AS NVARCHAR(4));
    ELSE
        SET @AcademicYear = CAST(@Year - 1 AS NVARCHAR(4)) + '-' + CAST(@Year AS NVARCHAR(4));
    
    RETURN @AcademicYear;
END
GO

PRINT 'Business functions created successfully!';
GO
