/*=============================================
  Examination System - Notification System Procedures
  Description: In-app notification system for real-time alerts
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

PRINT 'Creating Notification System Procedures...';
GO

-- =============================================
-- Procedure: SP_CreateNotification
-- Description: Creates a new notification
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_CreateNotification
    @UserID INT,
    @NotificationType NVARCHAR(50),
    @Title NVARCHAR(200),
    @Message NVARCHAR(MAX),
    @RelatedEntityType NVARCHAR(50) = NULL,
    @RelatedEntityID INT = NULL,
    @Priority NVARCHAR(20) = 'Normal',
    @ExpiryDays INT = 30,
    @NotificationID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO Security.Notifications (
            UserID, NotificationType, Title, Message,
            RelatedEntityType, RelatedEntityID, Priority,
            ExpiresAt
        )
        VALUES (
            @UserID, @NotificationType, @Title, @Message,
            @RelatedEntityType, @RelatedEntityID, @Priority,
            DATEADD(DAY, @ExpiryDays, GETDATE())
        );
        
        SET @NotificationID = SCOPE_IDENTITY();
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
-- Procedure: SP_GetUserNotifications
-- Description: Gets user's notifications with filters
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetUserNotifications
    @UserID INT,
    @UnreadOnly BIT = 0,
    @NotificationType NVARCHAR(50) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        NotificationID,
        NotificationType,
        Title,
        Message,
        RelatedEntityType,
        RelatedEntityID,
        IsRead,
        ReadDate,
        Priority,
        CreatedDate,
        ExpiresAt,
        CASE 
            WHEN Priority = 'Urgent' THEN 1
            WHEN Priority = 'High' THEN 2
            WHEN Priority = 'Normal' THEN 3
            ELSE 4
        END AS PriorityOrder
    FROM Security.Notifications
    WHERE UserID = @UserID
        AND (@UnreadOnly = 0 OR IsRead = 0)
        AND (@NotificationType IS NULL OR NotificationType = @NotificationType)
        AND (ExpiresAt IS NULL OR ExpiresAt > GETDATE())
    ORDER BY 
        IsRead ASC,
        PriorityOrder ASC,
        CreatedDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
    
    -- Return total count
    SELECT COUNT(*) AS TotalCount
    FROM Security.Notifications
    WHERE UserID = @UserID
        AND (@UnreadOnly = 0 OR IsRead = 0)
        AND (@NotificationType IS NULL OR NotificationType = @NotificationType)
        AND (ExpiresAt IS NULL OR ExpiresAt > GETDATE());
END
GO

-- =============================================
-- Procedure: SP_GetUnreadCount
-- Description: Gets count of unread notifications
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetUnreadCount
    @UserID INT,
    @UnreadCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT @UnreadCount = COUNT(*)
    FROM Security.Notifications
    WHERE UserID = @UserID
        AND IsRead = 0
        AND (ExpiresAt IS NULL OR ExpiresAt > GETDATE());
    
    RETURN 0;
END
GO

-- =============================================
-- Procedure: SP_MarkAsRead
-- Description: Marks notification(s) as read
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_MarkAsRead
    @NotificationID INT = NULL,
    @UserID INT = NULL,
    @MarkAll BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @NotificationID IS NOT NULL
        BEGIN
            -- Mark single notification
            UPDATE Security.Notifications
            SET 
                IsRead = 1,
                ReadDate = GETDATE()
            WHERE NotificationID = @NotificationID
                AND IsRead = 0;
        END
        ELSE IF @MarkAll = 1 AND @UserID IS NOT NULL
        BEGIN
            -- Mark all user's notifications
            UPDATE Security.Notifications
            SET 
                IsRead = 1,
                ReadDate = GETDATE()
            WHERE UserID = @UserID
                AND IsRead = 0
                AND (ExpiresAt IS NULL OR ExpiresAt > GETDATE());
        END
        
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
-- Procedure: SP_DeleteNotification
-- Description: Deletes a notification
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_DeleteNotification
    @NotificationID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM Security.Notifications
        WHERE NotificationID = @NotificationID
            AND UserID = @UserID;
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Notification not found or access denied.', 16, 1);
            RETURN -1;
        END
        
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
-- Procedure: SP_NotifyExamAssigned
-- Description: Notifies student when exam is assigned
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_NotifyExamAssigned
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @UserID INT, @ExamName NVARCHAR(200), @CourseName NVARCHAR(200);
        DECLARE @StartDate DATETIME2(3), @NotificationID INT;
        DECLARE @Message NVARCHAR(MAX);  -- ✅ تعريف المتغير

        -- Get student user ID and exam details
        SELECT @UserID = UserID FROM Academic.Student WHERE StudentID = @StudentID;

        SELECT 
            @ExamName = e.ExamName,
            @CourseName = c.CourseName,
            @StartDate = e.StartDateTime
        FROM Exam.Exam e
        INNER JOIN Academic.Course c ON e.CourseID = c.CourseID
        WHERE e.ExamID = @ExamID;

        -- Build message
        SET @Message = 
            'You have been assigned to the exam "' + ISNULL(CONVERT(NVARCHAR(100), @ExamName), '') +
            '" in course "' + ISNULL(CONVERT(NVARCHAR(100), @CourseName), '') +
            '". Exam starts on ' + ISNULL(CONVERT(NVARCHAR(100), @StartDate, 120), '');

        -- Create notification
        EXEC Security.SP_CreateNotification
            @UserID = @UserID,
            @NotificationType = 'ExamAssigned',
            @Title = 'New Exam Assigned',
            @Message = @Message,
            @RelatedEntityType = 'Exam',
            @RelatedEntityID = @ExamID,
            @Priority = 'High',
            @NotificationID = @NotificationID OUTPUT;

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
-- Procedure: SP_NotifyGradeReleased
-- Description: Notifies student when grade is released
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_NotifyGradeReleased
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @UserID INT, @ExamName NVARCHAR(200);
        DECLARE @TotalScore DECIMAL(5,2), @TotalMarks INT, @IsPassed BIT;
        DECLARE @NotificationID INT;
        
        -- Get details
        SELECT @UserID = UserID FROM Academic.Student WHERE StudentID = @StudentID;
        
        SELECT 
            @ExamName = e.ExamName,
            @TotalScore = se.TotalScore,
            @TotalMarks = e.TotalMarks,
            @IsPassed = se.IsPassed
        FROM Exam.StudentExam se
        INNER JOIN Exam.Exam e ON se.ExamID = e.ExamID
        WHERE se.StudentID = @StudentID AND se.ExamID = @ExamID;
        
        DECLARE @Message NVARCHAR(MAX);
        SET @Message = 'Your grade for "' + @ExamName + '" has been released. Score: ' + 
                       CAST(@TotalScore AS NVARCHAR) + '/' + CAST(@TotalMarks AS NVARCHAR);
        
        IF @IsPassed = 1
            SET @Message = @Message + '. Congratulations, you passed!';
        ELSE
            SET @Message = @Message + '. You did not pass this exam.';
        
        -- Create notification
        EXEC Security.SP_CreateNotification
            @UserID = @UserID,
            @NotificationType = 'GradeReleased',
            @Title = 'Grade Released',
            @Message = @Message,
            @RelatedEntityType = 'Exam',
            @RelatedEntityID = @ExamID,
            @Priority = 'High',
            @NotificationID = @NotificationID OUTPUT;
        
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
-- Procedure: SP_NotifyExamReminder
-- Description: Sends reminder before exam starts
-- =============================================
CREATE OR ALTER PROCEDURE Exam.SP_NotifyExamReminder
    @StudentID INT,
    @ExamID INT,
    @HoursBeforeExam INT = 24
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @UserID INT, @ExamName NVARCHAR(200), @StartDate DATETIME2(3);
        DECLARE @NotificationID INT;
        
        SELECT @UserID = UserID FROM Academic.Student WHERE StudentID = @StudentID;
        
        SELECT 
            @ExamName = e.ExamName,
            @StartDate = e.StartDateTime
        FROM Exam.Exam e
        WHERE e.ExamID = @ExamID;
        
        DECLARE @Message NVARCHAR(MAX);
        SET @Message = 'Reminder: Your exam "' + @ExamName + '" is scheduled to start in ' + 
                       CAST(@HoursBeforeExam AS NVARCHAR) + ' hours at ' + 
                       CONVERT(NVARCHAR, @StartDate, 120) + '. Please be prepared.';
        
        EXEC Security.SP_CreateNotification
            @UserID = @UserID,
            @NotificationType = 'ExamReminder',
            @Title = 'Exam Reminder',
            @Message = @Message,
            @RelatedEntityType = 'Exam',
            @RelatedEntityID = @ExamID,
            @Priority = 'Urgent',
            @NotificationID = @NotificationID OUTPUT;
        
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
-- Procedure: SP_NotifyPasswordReset
-- Description: Notifies user about password reset
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_NotifyPasswordReset
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @NotificationID INT, @Username NVARCHAR(100);
        
        SELECT @Username = Username FROM Security.[User] WHERE UserID = @UserID;
        
        EXEC Security.SP_CreateNotification
            @UserID = @UserID,
            @NotificationType = 'PasswordReset',
            @Title = 'Password Reset Successful',
            @Message = 'Your password has been successfully reset. If you did not make this change, please contact support immediately.',
            @Priority = 'Urgent',
            @ExpiryDays = 7,
            @NotificationID = @NotificationID OUTPUT;
        
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
-- Procedure: SP_SendBulkNotifications
-- Description: Sends notification to multiple users
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_SendBulkNotifications
    @UserIDs NVARCHAR(MAX), -- Comma-separated list or JSON array
    @NotificationType NVARCHAR(50),
    @Title NVARCHAR(200),
    @Message NVARCHAR(MAX),
    @Priority NVARCHAR(20) = 'Normal'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Parse UserIDs and insert notifications
        INSERT INTO Security.Notifications (
            UserID, NotificationType, Title, Message, Priority, ExpiresAt
        )
        SELECT 
            CAST(value AS INT),
            @NotificationType,
            @Title,
            @Message,
            @Priority,
            DATEADD(DAY, 30, GETDATE())
        FROM STRING_SPLIT(@UserIDs, ',')
        WHERE ISNUMERIC(value) = 1;
        
        DECLARE @NotificationCount INT = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        PRINT 'Sent ' + CAST(@NotificationCount AS VARCHAR) + ' notifications.';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_CleanupOldNotifications
-- Description: Deletes expired and old read notifications
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_CleanupOldNotifications
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @RetentionDays INT;
        DECLARE @DeletedCount INT;
        
        SELECT @RetentionDays = CAST(SettingValue AS INT)
        FROM Security.SystemSettings
        WHERE SettingKey = 'Notification.RetentionDays';
        
        -- Delete expired notifications
        DELETE FROM Security.Notifications
        WHERE ExpiresAt IS NOT NULL 
            AND ExpiresAt < GETDATE();
        
        SET @DeletedCount = @@ROWCOUNT;
        
        -- Delete old read notifications
        DELETE FROM Security.Notifications
        WHERE IsRead = 1
            AND ReadDate < DATEADD(DAY, -@RetentionDays, GETDATE());
        
        SET @DeletedCount = @DeletedCount + @@ROWCOUNT;
        
        PRINT 'Cleaned up ' + CAST(@DeletedCount AS VARCHAR) + ' notifications.';
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

PRINT 'Notification System procedures created successfully!';
GO

/*
Summary:
✅ SP_CreateNotification - Create notification
✅ SP_GetUserNotifications - Get user's notifications
✅ SP_GetUnreadCount - Get unread count
✅ SP_MarkAsRead - Mark as read
✅ SP_DeleteNotification - Delete notification
✅ SP_NotifyExamAssigned - Notify exam assignment
✅ SP_NotifyGradeReleased - Notify grade release
✅ SP_NotifyExamReminder - Send exam reminder
✅ SP_NotifyPasswordReset - Notify password reset
✅ SP_SendBulkNotifications - Bulk notifications
✅ SP_CleanupOldNotifications - Cleanup old notifications

Total: 11 procedures for complete notification system
*/
