/*=============================================
  Examination System - Session Management Procedures
  Description: JWT-like session management for API authentication
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

PRINT 'Creating Session Management Procedures...';
GO

-- =============================================
-- Procedure: SP_CreateUserSession
-- Description: Creates a new user session (after login)
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_CreateUserSession
    @UserID INT,
    @SessionToken NVARCHAR(500),
    @IPAddress NVARCHAR(50) = NULL,
    @UserAgent NVARCHAR(500) = NULL,
    @ExpiryHours INT = 8,
    @SessionID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get max concurrent sessions setting
        DECLARE @MaxSessions INT;
        SELECT @MaxSessions = CAST(SettingValue AS INT)
        FROM Security.SystemSettings
        WHERE SettingKey = 'Session.MaxConcurrentSessions';
        
        -- Check active sessions count
        DECLARE @ActiveSessionCount INT;
        SELECT @ActiveSessionCount = COUNT(*)
        FROM Security.UserSessions
        WHERE UserID = @UserID 
            AND IsActive = 1 
            AND ExpiresAt > GETDATE();
        
        -- If max sessions reached, end oldest session
        IF @ActiveSessionCount >= @MaxSessions
        BEGIN
            UPDATE Security.UserSessions
            SET IsActive = 0
            WHERE SessionID = (
                SELECT TOP 1 SessionID
                FROM Security.UserSessions
                WHERE UserID = @UserID 
                    AND IsActive = 1 
                    AND ExpiresAt > GETDATE()
                ORDER BY CreatedDate ASC
            );
        END
        
        -- Create new session
        INSERT INTO Security.UserSessions (
            UserID, SessionToken, IPAddress, UserAgent,
            ExpiresAt, LastActivityDate
        )
        VALUES (
            @UserID, @SessionToken, @IPAddress, @UserAgent,
            DATEADD(HOUR, @ExpiryHours, GETDATE()), GETDATE()
        );
        
        SET @SessionID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
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
-- Procedure: SP_ValidateSession
-- Description: Validates and refreshes active session
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_ValidateSession
    @SessionToken NVARCHAR(500),
    @UserID INT OUTPUT,
    @IsValid BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    SET @IsValid = 0;
    SET @UserID = NULL;
    
    -- Check if session exists and is valid
    SELECT 
        @UserID = UserID,
        @IsValid = CASE 
            WHEN IsActive = 1 AND ExpiresAt > GETDATE() THEN 1 
            ELSE 0 
        END
    FROM Security.UserSessions
    WHERE SessionToken = @SessionToken;
    
    -- If valid, update last activity
    IF @IsValid = 1
    BEGIN
        UPDATE Security.UserSessions
        SET LastActivityDate = GETDATE()
        WHERE SessionToken = @SessionToken;
        
        -- Check for inactivity timeout
        DECLARE @InactivityTimeout INT;
        SELECT @InactivityTimeout = CAST(SettingValue AS INT)
        FROM Security.SystemSettings
        WHERE SettingKey = 'Session.InactivityTimeoutMinutes';
        
        -- If last activity too old, invalidate session
        IF EXISTS (
            SELECT 1 FROM Security.UserSessions
            WHERE SessionToken = @SessionToken
                AND DATEDIFF(MINUTE, LastActivityDate, GETDATE()) > @InactivityTimeout
        )
        BEGIN
            UPDATE Security.UserSessions
            SET IsActive = 0
            WHERE SessionToken = @SessionToken;
            
            SET @IsValid = 0;
            SET @UserID = NULL;
        END
    END
    
    RETURN 0;
END
GO

-- =============================================
-- Procedure: SP_RefreshSession
-- Description: Extends session expiry time
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_RefreshSession
    @SessionToken NVARCHAR(500),
    @ExtendHours INT = 8
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Security.UserSessions
        SET 
            ExpiresAt = DATEADD(HOUR, @ExtendHours, GETDATE()),
            LastActivityDate = GETDATE()
        WHERE SessionToken = @SessionToken
            AND IsActive = 1
            AND ExpiresAt > GETDATE();
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Session not found or expired.', 16, 1);
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
-- Procedure: SP_GetActiveSessions
-- Description: Gets all active sessions for a user
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetActiveSessions
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        SessionID,
        SessionToken,
        IPAddress,
        UserAgent,
        CreatedDate,
        ExpiresAt,
        LastActivityDate,
        DATEDIFF(MINUTE, LastActivityDate, GETDATE()) AS MinutesSinceActivity,
        DATEDIFF(MINUTE, GETDATE(), ExpiresAt) AS MinutesUntilExpiry
    FROM Security.UserSessions
    WHERE UserID = @UserID
        AND IsActive = 1
        AND ExpiresAt > GETDATE()
    ORDER BY LastActivityDate DESC;
END
GO

-- =============================================
-- Procedure: SP_EndSession
-- Description: Ends a specific session (logout)
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_EndSession
    @SessionToken NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Security.UserSessions
        SET IsActive = 0
        WHERE SessionToken = @SessionToken;
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Session not found.', 16, 1);
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
-- Procedure: SP_EndAllUserSessions
-- Description: Ends all sessions for a user
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_EndAllUserSessions
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Security.UserSessions
        SET IsActive = 0
        WHERE UserID = @UserID
            AND IsActive = 1;
        
        PRINT 'All sessions ended for UserID: ' + CAST(@UserID AS VARCHAR);
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
-- Procedure: SP_CleanupExpiredSessions
-- Description: Cleans up expired and inactive sessions
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_CleanupExpiredSessions
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @DeletedCount INT;
        
        -- Mark expired sessions as inactive
        UPDATE Security.UserSessions
        SET IsActive = 0
        WHERE IsActive = 1
            AND ExpiresAt < GETDATE();
        
        SET @DeletedCount = @@ROWCOUNT;
        
        -- Delete very old sessions (older than 90 days)
        DELETE FROM Security.UserSessions
        WHERE CreatedDate < DATEADD(DAY, -90, GETDATE());
        
        SET @DeletedCount = @DeletedCount + @@ROWCOUNT;
        
        PRINT 'Cleaned up ' + CAST(@DeletedCount AS VARCHAR) + ' sessions.';
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
-- Procedure: SP_GetSessionHistory
-- Description: Gets session history for audit
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetSessionHistory
    @UserID INT = NULL,
    @DaysBack INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        us.SessionID,
        us.UserID,
        u.Username,
        u.Email,
        u.UserType,
        us.IPAddress,
        us.UserAgent,
        us.CreatedDate,
        us.ExpiresAt,
        us.LastActivityDate,
        us.IsActive,
        DATEDIFF(MINUTE, us.CreatedDate, 
            ISNULL(CASE WHEN us.IsActive = 0 THEN us.LastActivityDate 
                   ELSE GETDATE() END, us.LastActivityDate)
        ) AS SessionDurationMinutes
    FROM Security.UserSessions us
    INNER JOIN Security.[User] u ON us.UserID = u.UserID
    WHERE (@UserID IS NULL OR us.UserID = @UserID)
        AND us.CreatedDate >= DATEADD(DAY, -@DaysBack, GETDATE())
    ORDER BY us.CreatedDate DESC;
END
GO

PRINT 'Session Management procedures created successfully!';
GO

/*
Summary:
✅ SP_CreateUserSession - Creates new session
✅ SP_ValidateSession - Validates token
✅ SP_RefreshSession - Extends session
✅ SP_GetActiveSessions - Lists active sessions
✅ SP_EndSession - Logout single session
✅ SP_EndAllUserSessions - Logout all sessions
✅ SP_CleanupExpiredSessions - Maintenance
✅ SP_GetSessionHistory - Audit trail

Total: 8 procedures for complete session management
*/
