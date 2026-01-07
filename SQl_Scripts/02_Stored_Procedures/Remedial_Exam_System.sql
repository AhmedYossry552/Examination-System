/*
============================================================================
Remedial Exam System - Auto-Assign Failed Students
============================================================================
Description: Automatically assign remedial exams to failed students
Author: Examination System Team
Created: 2025-11-13
============================================================================
*/

USE ExaminationSystemDB;
GO

-- =============================================
-- 1. Check and Auto-Assign Remedial Exams
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_AutoAssignRemedialExams
    @ExamID INT,
    @InstructorID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get exam details
        DECLARE @ExamName NVARCHAR(200), @CourseID INT, @IntakeID INT, @BranchID INT, @TrackID INT;
        DECLARE @PassMarks DECIMAL(5,2), @TotalMarks DECIMAL(5,2), @DurationMinutes INT;
        
        SELECT 
            @ExamName = ExamName,
            @CourseID = CourseID,
            @IntakeID = IntakeID,
            @BranchID = BranchID,
            @TrackID = TrackID,
            @PassMarks = PassMarks,
            @TotalMarks = TotalMarks,
            @DurationMinutes = DurationMinutes,
            @InstructorID = ISNULL(@InstructorID, InstructorID)
        FROM Exam.Exam
        WHERE ExamID = @ExamID;
        
        -- Find failed students
        DECLARE @FailedStudents TABLE (
            StudentID INT,
            TotalScore DECIMAL(5,2),
            SubmissionTime DATETIME2(3)
        );
        
        INSERT INTO @FailedStudents (StudentID, TotalScore, SubmissionTime)
        SELECT 
            se.StudentID,
            se.TotalScore,
            se.SubmissionTime
        FROM Exam.StudentExam se
        WHERE se.ExamID = @ExamID
          AND se.SubmissionTime IS NOT NULL
          AND se.TotalScore < @PassMarks
          AND NOT EXISTS (
              -- Check if already assigned remedial exam
              SELECT 1 FROM Exam.StudentExam se2
              INNER JOIN Exam.Exam e2 ON se2.ExamID = e2.ExamID
              WHERE se2.StudentID = se.StudentID
                AND e2.CourseID = @CourseID
                AND e2.ExamType = 'Remedial'
                AND se2.SubmissionTime IS NULL  -- Not yet taken
          );
        
        IF NOT EXISTS (SELECT 1 FROM @FailedStudents)
        BEGIN
            SELECT 
                0 AS RemedialExamID,
                0 AS AssignedStudentsCount,
                'No failed students require remedial exam' AS Message;
            COMMIT TRANSACTION;
            RETURN 0;
        END
        
        -- Check if remedial exam already exists
        DECLARE @RemedialExamID INT;
        
        SELECT @RemedialExamID = ExamID
        FROM Exam.Exam
        WHERE CourseID = @CourseID
          AND IntakeID = @IntakeID
          AND ExamType = 'Remedial'
          AND StartDateTime > GETDATE();  -- Future exam
        
        -- If no remedial exam exists, create one
        IF @RemedialExamID IS NULL
        BEGIN
            INSERT INTO Exam.Exam (
                InstructorID, CourseID, IntakeID, BranchID, TrackID,
                ExamName, ExamYear, ExamType, TotalMarks, PassMarks,
                DurationMinutes, StartDateTime, EndDateTime,
                AllowanceOptions, CreatedDate
            )
            VALUES (
                @InstructorID,
                @CourseID,
                @IntakeID,
                @BranchID,
                @TrackID,
                @ExamName + ' - Remedial',
                YEAR(GETDATE()),
                'Remedial',
                @TotalMarks,
                @PassMarks,
                @DurationMinutes,
                DATEADD(DAY, 7, GETDATE()),  -- Schedule 1 week from now
                DATEADD(DAY, 7, DATEADD(MINUTE, @DurationMinutes, GETDATE())),
                'No Allowance',
                GETDATE()
            );
            
            SET @RemedialExamID = SCOPE_IDENTITY();
            
            -- Copy questions from original exam
            INSERT INTO Exam.ExamQuestion (ExamID, QuestionID, QuestionOrder, QuestionMarks)
            SELECT 
                @RemedialExamID,
                QuestionID,
                QuestionOrder,
                QuestionMarks
            FROM Exam.ExamQuestion
            WHERE ExamID = @ExamID;
        END
        
        -- Assign remedial exam to failed students
        DECLARE @StudentID INT, @AssignedCount INT = 0;
        DECLARE student_cursor CURSOR FOR 
        SELECT StudentID FROM @FailedStudents;
        
        OPEN student_cursor;
        FETCH NEXT FROM student_cursor INTO @StudentID;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Check if already assigned
            IF NOT EXISTS (
                SELECT 1 FROM Exam.StudentExam 
                WHERE StudentID = @StudentID AND ExamID = @RemedialExamID
            )
            BEGIN
                -- Assign exam
                INSERT INTO Exam.StudentExam (
                    StudentID, ExamID, StartTime, SubmissionTime, TotalScore
                )
                VALUES (
                    @StudentID, @RemedialExamID, NULL, NULL, NULL
                );
                
                -- Send notification
                DECLARE @NotificationID INT, @StudentUserID INT;
                DECLARE @NotificationMessage NVARCHAR(MAX);
                SELECT @StudentUserID = UserID FROM Academic.Student WHERE StudentID = @StudentID;
                SET @NotificationMessage = 'You have been assigned a remedial exam for ' + @ExamName;
                
                EXEC Security.SP_CreateNotification
                    @UserID = @StudentUserID,
                    @NotificationType = 'ExamAssigned',
                    @Title = 'Remedial Exam Assigned',
                    @Message = @NotificationMessage,
                    @RelatedEntityType = 'Exam',
                    @RelatedEntityID = @RemedialExamID,
                    @Priority = 'High',
                    @NotificationID = @NotificationID OUTPUT;
                
                -- Send email
                DECLARE @EmailID INT, @StudentEmail NVARCHAR(100), @StudentName NVARCHAR(200);
                SELECT 
                    @StudentEmail = u.Email,
                    @StudentName = u.FirstName + ' ' + u.LastName
                FROM Academic.Student s
                INNER JOIN Security.[User] u ON s.UserID = u.UserID
                WHERE s.StudentID = @StudentID;
                
                DECLARE @EmailBody NVARCHAR(MAX);
                SET @EmailBody = '<html><body><h2>Remedial Exam Assignment</h2>' +
                    '<p>Dear ' + @StudentName + ',</p>' +
                    '<p>You have been assigned a remedial exam:</p><ul>' +
                    '<li><strong>Exam:</strong> ' + @ExamName + ' - Remedial</li>' +
                    '<li><strong>Start Date:</strong> ' + CONVERT(NVARCHAR(50), DATEADD(DAY, 7, GETDATE()), 120) + '</li>' +
                    '<li><strong>Duration:</strong> ' + CAST(@DurationMinutes AS NVARCHAR(10)) + ' minutes</li>' +
                    '<li><strong>Passing Marks:</strong> ' + CAST(@PassMarks AS NVARCHAR(10)) + ' / ' + CAST(@TotalMarks AS NVARCHAR(10)) + '</li>' +
                    '</ul><p>Please prepare well. Good luck!</p></body></html>';
                
                DECLARE @EmailSubject NVARCHAR(500);
                SET @EmailSubject = 'Remedial Exam Assignment - ' + @ExamName;
                
                EXEC Security.SP_AddToEmailQueue
                    @ToEmail = @StudentEmail,
                    @Subject = @EmailSubject,
                    @Body = @EmailBody,
                    @EmailType = 'ExamAssignment',
                    @Priority = 'High',
                    @RelatedEntityType = 'Exam',
                    @RelatedEntityID = @RemedialExamID,
                    @EmailID = @EmailID OUTPUT;
                
                SET @AssignedCount = @AssignedCount + 1;
            END
            
            FETCH NEXT FROM student_cursor INTO @StudentID;
        END
        
        CLOSE student_cursor;
        DEALLOCATE student_cursor;
        
        COMMIT TRANSACTION;
        
        -- Return results
        SELECT 
            @RemedialExamID AS RemedialExamID,
            @AssignedCount AS AssignedStudentsCount,
            'Remedial exam successfully assigned to ' + CAST(@AssignedCount AS NVARCHAR(10)) + ' student(s)' AS Message;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- 2. Get Remedial Exam Candidates
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_GetRemedialExamCandidates
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.StudentID,
        u.FirstName + ' ' + u.LastName AS StudentName,
        u.Email,
        se.TotalScore,
        e.PassMarks,
        e.TotalMarks,
        se.SubmissionTime,
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM Exam.StudentExam se2
                INNER JOIN Exam.Exam e2 ON se2.ExamID = e2.ExamID
                WHERE se2.StudentID = s.StudentID
                  AND e2.CourseID = e.CourseID
                  AND e2.ExamType = 'Remedial'
            )
            THEN 'Already Assigned'
            ELSE 'Ready to Assign'
        END AS Status
    FROM Exam.StudentExam se
    INNER JOIN Academic.Student s ON se.StudentID = s.StudentID
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    WHERE se.ExamID = @ExamID
      AND se.SubmissionTime IS NOT NULL
      AND se.TotalScore < e.PassMarks
    ORDER BY se.TotalScore ASC;
END
GO

-- =============================================
-- 3. Track Remedial Exam Progress
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_GetRemedialExamProgress
    @CourseID INT,
    @IntakeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExamID,
        e.ExamName,
        e.StartDateTime,
        COUNT(DISTINCT se.StudentID) AS AssignedStudents,
        COUNT(DISTINCT CASE WHEN se.SubmissionTime IS NOT NULL THEN se.StudentID END) AS CompletedStudents,
        COUNT(DISTINCT CASE WHEN se.TotalScore >= e.PassMarks THEN se.StudentID END) AS PassedStudents,
        COUNT(DISTINCT CASE WHEN se.TotalScore < e.PassMarks THEN se.StudentID END) AS FailedAgain,
        CAST(AVG(se.TotalScore) AS DECIMAL(5,2)) AS AverageMarks
    FROM Exam.Exam e
    LEFT JOIN Exam.StudentExam se ON e.ExamID = se.ExamID
    WHERE e.CourseID = @CourseID
      AND e.IntakeID = @IntakeID
      AND e.ExamType = 'Remedial'
    GROUP BY e.ExamID, e.ExamName, e.StartDateTime
    ORDER BY e.StartDateTime DESC;
END
GO

-- =============================================
-- 4. Student Remedial History
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_GetStudentRemedialHistory
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExamID,
        e.ExamName,
        c.CourseName,
        -- Original exam
        e_orig.ExamName AS OriginalExamName,
        se_orig.TotalScore AS OriginalMarks,
        se_orig.SubmissionTime AS OriginalSubmissionTime,
        -- Remedial exam
        se.TotalScore AS RemedialMarks,
        se.SubmissionTime AS RemedialSubmissionTime,
        e.PassMarks,
        -- Improvement
        CASE 
            WHEN se.SubmissionTime IS NULL THEN 'Not Yet Taken'
            WHEN se.TotalScore >= e.PassMarks THEN 'PASSED'
            ELSE 'FAILED AGAIN'
        END AS Result,
        CASE 
            WHEN se.TotalScore IS NOT NULL 
            THEN se.TotalScore - se_orig.TotalScore
            ELSE NULL
        END AS Improvement
    FROM Exam.StudentExam se
    INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
    INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
    INNER JOIN Exam.StudentExam se_orig ON se_orig.StudentID = se.StudentID AND se_orig.ExamID != se.ExamID
    INNER JOIN Exam.Exam e_orig ON se_orig.ExamID = e_orig.ExamID AND e_orig.CourseID = e.CourseID AND e_orig.ExamType != 'Remedial'
    WHERE se.StudentID = @StudentID
      AND e.ExamType = 'Remedial'
    ORDER BY e.StartDateTime DESC;
END
GO

PRINT '✓ Remedial Exam System procedures created successfully';
GO
