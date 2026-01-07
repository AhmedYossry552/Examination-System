/*=============================================
  Examination System - Email Queue System Procedures
  Description: Automated email queue for sending emails asynchronously
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

PRINT 'Creating Email Queue System Procedures...';
GO

-- =============================================
-- Procedure: SP_AddToEmailQueue
-- Description: Adds an email to the queue
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_AddToEmailQueue
    @ToEmail NVARCHAR(200),
    @ToName NVARCHAR(200) = NULL,
    @Subject NVARCHAR(500),
    @Body NVARCHAR(MAX),
    @EmailType NVARCHAR(50),
    @Priority NVARCHAR(20) = 'Normal',
    @ScheduledDate DATETIME2(3) = NULL,
    @RelatedEntityType NVARCHAR(50) = NULL,
    @RelatedEntityID INT = NULL,
    @EmailID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @ScheduledDate IS NULL
            SET @ScheduledDate = GETDATE();
        
        INSERT INTO Security.EmailQueue (
            ToEmail, ToName, Subject, Body, EmailType,
            Priority, ScheduledDate, RelatedEntityType, RelatedEntityID
        )
        VALUES (
            @ToEmail, @ToName, @Subject, @Body, @EmailType,
            @Priority, @ScheduledDate, @RelatedEntityType, @RelatedEntityID
        );
        
        SET @EmailID = SCOPE_IDENTITY();
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_ProcessEmailQueue
-- Description: Gets pending emails for processing (called by background service)
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_ProcessEmailQueue
    @BatchSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get pending emails ordered by priority and schedule
    SELECT TOP (@BatchSize)
        EmailID,
        ToEmail,
        ToName,
        FromEmail,
        FromName,
        Subject,
        Body,
        EmailType,
        Priority,
        RetryCount
    FROM Security.EmailQueue
    WHERE Status = 'Pending'
        AND ScheduledDate <= GETDATE()
    ORDER BY 
        CASE Priority
            WHEN 'Urgent' THEN 1
            WHEN 'High' THEN 2
            WHEN 'Normal' THEN 3
            ELSE 4
        END,
        ScheduledDate ASC;
END
GO

-- =============================================
-- Procedure: SP_GetPendingEmails
-- Description: Gets all pending emails for display/monitoring
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetPendingEmails
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        EmailID,
        ToEmail AS RecipientEmail,
        ToName AS RecipientName,
        Subject,
        Body,
        EmailType,
        Status,
        Priority,
        ScheduledDate,
        CreatedDate,
        RetryCount
    FROM Security.EmailQueue
    WHERE Status = 'Pending'
      AND (ScheduledDate IS NULL OR ScheduledDate <= GETDATE())
    ORDER BY 
        CASE Priority 
            WHEN 'Urgent' THEN 1
            WHEN 'High' THEN 2 
            WHEN 'Normal' THEN 3 
            ELSE 4 
        END,
        CreatedDate ASC;
END
GO

-- =============================================
-- Procedure: SP_MarkEmailAsSent
-- Description: Marks email as successfully sent
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_MarkEmailAsSent
    @EmailID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Security.EmailQueue
        SET 
            Status = 'Sent',
            SentDate = GETDATE(),
            ModifiedDate = GETDATE()
        WHERE EmailID = @EmailID;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_MarkEmailAsFailed
-- Description: Marks email as failed with retry logic
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_MarkEmailAsFailed
    @EmailID INT,
    @FailureReason NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @RetryCount INT, @MaxRetries INT;
        
        SELECT 
            @RetryCount = RetryCount,
            @MaxRetries = MaxRetries
        FROM Security.EmailQueue
        WHERE EmailID = @EmailID;
        
        -- Increment retry count
        SET @RetryCount = @RetryCount + 1;
        
        -- Update status
        UPDATE Security.EmailQueue
        SET 
            Status = CASE 
                WHEN @RetryCount >= @MaxRetries THEN 'Failed'
                ELSE 'Pending'
            END,
            RetryCount = @RetryCount,
            FailureReason = @FailureReason,
            ModifiedDate = GETDATE(),
            -- Schedule retry with exponential backoff
            ScheduledDate = CASE 
                WHEN @RetryCount < @MaxRetries 
                THEN DATEADD(MINUTE, POWER(2, @RetryCount) * 5, GETDATE())
                ELSE ScheduledDate
            END
        WHERE EmailID = @EmailID;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_SendWelcomeEmail
-- Description: Sends welcome email to new user
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_SendWelcomeEmail
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Email NVARCHAR(200), @FirstName NVARCHAR(100);
        DECLARE @Username NVARCHAR(100), @UserType NVARCHAR(20);
        DECLARE @EmailID INT;
        
        SELECT 
            @Email = Email,
            @FirstName = FirstName,
            @Username = Username,
            @UserType = UserType
        FROM Security.[User]
        WHERE UserID = @UserID;
        
        DECLARE @Subject NVARCHAR(500) = 'Welcome to Examination System';
        DECLARE @Body NVARCHAR(MAX) = 
            '<html><body>' +
            '<h2>Welcome to Examination System!</h2>' +
            '<p>Dear ' + @FirstName + ',</p>' +
            '<p>Your account has been successfully created.</p>' +
            '<p><strong>Account Details:</strong></p>' +
            '<ul>' +
            '<li>Username: ' + @Username + '</li>' +
            '<li>Role: ' + @UserType + '</li>' +
            '</ul>' +
            '<p>Please login to the system and change your password.</p>' +
            '<p>Best regards,<br>Examination System Team</p>' +
            '</body></html>';
        
        EXEC Security.SP_AddToEmailQueue
            @ToEmail = @Email,
            @ToName = @FirstName,
            @Subject = @Subject,
            @Body = @Body,
            @EmailType = 'Welcome',
            @Priority = 'Normal',
            @EmailID = @EmailID OUTPUT;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_SendExamAssignmentEmail
-- Description: Sends email when exam is assigned
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_SendExamAssignmentEmail
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Email NVARCHAR(200), @FirstName NVARCHAR(100);
        DECLARE @ExamName NVARCHAR(200), @CourseName NVARCHAR(200);
        DECLARE @StartDate DATETIME2(3), @DurationMinutes INT;
        DECLARE @EmailID INT;
        
        SELECT 
            @Email = u.Email,
            @FirstName = u.FirstName
        FROM Academic.Student s
        INNER JOIN Security.[User] u ON s.UserID = u.UserID
        WHERE s.StudentID = @StudentID;
        
        SELECT 
            @ExamName = e.ExamName,
            @CourseName = c.CourseName,
            @StartDate = e.StartDateTime,
            @DurationMinutes = e.DurationMinutes
        FROM Exam.Exam e
        INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
        WHERE e.ExamID = @ExamID;
        
        DECLARE @Subject NVARCHAR(500) = 'New Exam Assigned: ' + @ExamName;
        DECLARE @Body NVARCHAR(MAX) = 
            '<html><body>' +
            '<h2>New Exam Assigned</h2>' +
            '<p>Dear ' + @FirstName + ',</p>' +
            '<p>You have been assigned to a new exam.</p>' +
            '<p><strong>Exam Details:</strong></p>' +
            '<ul>' +
            '<li>Course: ' + @CourseName + '</li>' +
            '<li>Exam: ' + @ExamName + '</li>' +
            '<li>Start Date: ' + CONVERT(NVARCHAR, @StartDate, 120) + '</li>' +
            '<li>Duration: ' + CAST(@DurationMinutes AS NVARCHAR) + ' minutes</li>' +
            '</ul>' +
            '<p>Please login to the system to take the exam.</p>' +
            '<p>Good luck!</p>' +
            '<p>Best regards,<br>Examination System Team</p>' +
            '</body></html>';
        
        EXEC Security.SP_AddToEmailQueue
            @ToEmail = @Email,
            @ToName = @FirstName,
            @Subject = @Subject,
            @Body = @Body,
            @EmailType = 'ExamAssignment',
            @Priority = 'High',
            @RelatedEntityType = 'Exam',
            @RelatedEntityID = @ExamID,
            @EmailID = @EmailID OUTPUT;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_SendGradeEmail
-- Description: Sends email when grade is released
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_SendGradeEmail
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Email NVARCHAR(200), @FirstName NVARCHAR(100);
        DECLARE @ExamName NVARCHAR(200), @TotalScore DECIMAL(5,2);
        DECLARE @TotalMarks INT, @IsPassed BIT;
        DECLARE @EmailID INT;
        
        SELECT 
            @Email = u.Email,
            @FirstName = u.FirstName
        FROM Academic.Student s
        INNER JOIN Security.[User] u ON s.UserID = u.UserID
        WHERE s.StudentID = @StudentID;
        
        SELECT 
            @ExamName = e.ExamName,
            @TotalScore = se.TotalScore,
            @TotalMarks = e.TotalMarks,
            @IsPassed = se.IsPassed
        FROM Exam.StudentExam se
        INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
        WHERE se.StudentID = @StudentID AND se.ExamID = @ExamID;
        
        DECLARE @ResultText NVARCHAR(100) = CASE 
            WHEN @IsPassed = 1 THEN 'Congratulations, you passed!'
            ELSE 'Unfortunately, you did not pass.'
        END;
        
        DECLARE @Subject NVARCHAR(500) = 'Grade Released: ' + @ExamName;
        DECLARE @Body NVARCHAR(MAX) = 
            '<html><body>' +
            '<h2>Grade Released</h2>' +
            '<p>Dear ' + @FirstName + ',</p>' +
            '<p>Your grade for the exam "' + @ExamName + '" has been released.</p>' +
            '<p><strong>Results:</strong></p>' +
            '<ul>' +
            '<li>Score: ' + CAST(@TotalScore AS NVARCHAR) + '/' + CAST(@TotalMarks AS NVARCHAR) + '</li>' +
            '<li>Percentage: ' + CAST((@TotalScore * 100 / @TotalMarks) AS NVARCHAR) + '%</li>' +
            '<li>Status: ' + @ResultText + '</li>' +
            '</ul>' +
            '<p>Login to view detailed results.</p>' +
            '<p>Best regards,<br>Examination System Team</p>' +
            '</body></html>';
        
        EXEC Security.SP_AddToEmailQueue
            @ToEmail = @Email,
            @ToName = @FirstName,
            @Subject = @Subject,
            @Body = @Body,
            @EmailType = 'Grade',
            @Priority = 'Normal',
            @RelatedEntityType = 'Exam',
            @RelatedEntityID = @ExamID,
            @EmailID = @EmailID OUTPUT;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_SendPasswordResetEmail
-- Description: Sends password reset email with token
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_SendPasswordResetEmail
    @UserID INT,
    @ResetToken NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Email NVARCHAR(200), @FirstName NVARCHAR(100);
        DECLARE @EmailID INT;
        
        SELECT 
            @Email = Email,
            @FirstName = FirstName
        FROM Security.[User]
        WHERE UserID = @UserID;
        
        DECLARE @ResetLink NVARCHAR(500) = 'https://examsystem.com/reset-password?token=' + @ResetToken;
        
        DECLARE @Subject NVARCHAR(500) = 'Password Reset Request';
        DECLARE @Body NVARCHAR(MAX) = 
            '<html><body>' +
            '<h2>Password Reset Request</h2>' +
            '<p>Dear ' + @FirstName + ',</p>' +
            '<p>We received a request to reset your password.</p>' +
            '<p>Click the link below to reset your password:</p>' +
            '<p><a href="' + @ResetLink + '">Reset Password</a></p>' +
            '<p>This link will expire in 1 hour.</p>' +
            '<p>If you did not request this, please ignore this email.</p>' +
            '<p>Best regards,<br>Examination System Team</p>' +
            '</body></html>';
        
        EXEC Security.SP_AddToEmailQueue
            @ToEmail = @Email,
            @ToName = @FirstName,
            @Subject = @Subject,
            @Body = @Body,
            @EmailType = 'PasswordReset',
            @Priority = 'Urgent',
            @EmailID = @EmailID OUTPUT;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_SendExamReminderEmail
-- Description: Sends reminder email before exam
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_SendExamReminderEmail
    @StudentID INT,
    @ExamID INT,
    @HoursBeforeExam INT = 24
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Email NVARCHAR(200), @FirstName NVARCHAR(100);
        DECLARE @ExamName NVARCHAR(200), @StartDate DATETIME2(3);
        DECLARE @EmailID INT;
        
        SELECT 
            @Email = u.Email,
            @FirstName = u.FirstName
        FROM Academic.Student s
        INNER JOIN Security.[User] u ON s.UserID = u.UserID
        WHERE s.StudentID = @StudentID;
        
        SELECT 
            @ExamName = ExamName,
            @StartDate = StartDateTime
        FROM Exam.Exam
        WHERE ExamID = @ExamID;
        
        DECLARE @Subject NVARCHAR(500) = 'Reminder: Upcoming Exam - ' + @ExamName;
        DECLARE @Body NVARCHAR(MAX) = 
            '<html><body>' +
            '<h2>Exam Reminder</h2>' +
            '<p>Dear ' + @FirstName + ',</p>' +
            '<p>This is a reminder that your exam "' + @ExamName + '" is scheduled to start in ' + 
            CAST(@HoursBeforeExam AS NVARCHAR) + ' hours.</p>' +
            '<p><strong>Exam Start Time:</strong> ' + CONVERT(NVARCHAR, @StartDate, 120) + '</p>' +
            '<p>Please make sure you are ready and login on time.</p>' +
            '<p>Good luck!</p>' +
            '<p>Best regards,<br>Examination System Team</p>' +
            '</body></html>';
        
        -- Schedule email to be sent at the right time
        DECLARE @SendTime DATETIME2(3) = DATEADD(HOUR, -@HoursBeforeExam, @StartDate);
        
        EXEC Security.SP_AddToEmailQueue
            @ToEmail = @Email,
            @ToName = @FirstName,
            @Subject = @Subject,
            @Body = @Body,
            @EmailType = 'ExamReminder',
            @Priority = 'High',
            @ScheduledDate = @SendTime,
            @RelatedEntityType = 'Exam',
            @RelatedEntityID = @ExamID,
            @EmailID = @EmailID OUTPUT;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_ScheduleEmail
-- Description: Schedules an email for future sending
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_ScheduleEmail
    @ToEmail NVARCHAR(200),
    @Subject NVARCHAR(500),
    @Body NVARCHAR(MAX),
    @EmailType NVARCHAR(50),
    @ScheduledDate DATETIME2(3),
    @Priority NVARCHAR(20) = 'Normal'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @EmailID INT;
        
        EXEC Security.SP_AddToEmailQueue
            @ToEmail = @ToEmail,
            @Subject = @Subject,
            @Body = @Body,
            @EmailType = @EmailType,
            @Priority = @Priority,
            @ScheduledDate = @ScheduledDate,
            @EmailID = @EmailID OUTPUT;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_RetryFailedEmails
-- Description: Retries failed emails that haven't exceeded max retries
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_RetryFailedEmails
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Security.EmailQueue
        SET 
            Status = 'Pending',
            ModifiedDate = GETDATE()
        WHERE Status = 'Failed'
            AND RetryCount < MaxRetries;
        
        DECLARE @UpdatedCount INT = @@ROWCOUNT;
        PRINT 'Retrying ' + CAST(@UpdatedCount AS VARCHAR) + ' failed emails.';
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_GetEmailQueueStatus
-- Description: Gets email queue statistics
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetEmailQueueStatus
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Status,
        COUNT(*) AS EmailCount,
        MIN(CreatedDate) AS OldestEmail,
        MAX(CreatedDate) AS NewestEmail
    FROM Security.EmailQueue
    GROUP BY Status
    
    UNION ALL
    
    SELECT 
        'Total' AS Status,
        COUNT(*) AS EmailCount,
        MIN(CreatedDate) AS OldestEmail,
        MAX(CreatedDate) AS NewestEmail
    FROM Security.EmailQueue;
    
    -- Priority breakdown for pending
    SELECT 
        Priority,
        COUNT(*) AS PendingCount
    FROM Security.EmailQueue
    WHERE Status = 'Pending'
    GROUP BY Priority;
END
GO

-- =============================================
-- Procedure: SP_CleanupSentEmails
-- Description: Deletes old sent emails
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_CleanupSentEmails
    @DaysToKeep INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM Security.EmailQueue
        WHERE Status = 'Sent'
            AND SentDate < DATEADD(DAY, -@DaysToKeep, GETDATE());
        
        DECLARE @DeletedCount INT = @@ROWCOUNT;
        PRINT 'Deleted ' + CAST(@DeletedCount AS VARCHAR) + ' sent emails.';
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

PRINT 'Email Queue System procedures created successfully!';
GO

/*
Summary:
✅ SP_AddToEmailQueue - Add email to queue
✅ SP_ProcessEmailQueue - Get pending emails
✅ SP_MarkEmailAsSent - Mark as sent
✅ SP_MarkEmailAsFailed - Mark as failed with retry
✅ SP_SendWelcomeEmail - Welcome email
✅ SP_SendExamAssignmentEmail - Exam assignment email
✅ SP_SendGradeEmail - Grade released email
✅ SP_SendPasswordResetEmail - Password reset email
✅ SP_SendExamReminderEmail - Exam reminder email
✅ SP_ScheduleEmail - Schedule for future
✅ SP_RetryFailedEmails - Retry failed emails
✅ SP_GetEmailQueueStatus - Queue statistics
✅ SP_CleanupSentEmails - Cleanup old emails

Total: 13 procedures for complete email queue system
*/
