/*
============================================================================
Authentication Enhancement Stored Procedures
============================================================================
Description: Procedures for RefreshTokens and API Keys management
Author: Examination System Team
Created: 2025-11-13
============================================================================
*/

USE ExaminationSystemDB;
GO

-- =============================================
-- REFRESH TOKENS PROCEDURES
-- =============================================

-- =============================================
-- 1. Create Refresh Token
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_CreateRefreshToken
    @UserID INT,
    @Token NVARCHAR(500),
    @ExpiryDays INT = 30,
    @IPAddress NVARCHAR(50) = NULL,
    @DeviceInfo NVARCHAR(500) = NULL,
    @RefreshTokenID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Calculate expiry date
        DECLARE @ExpiryDate DATETIME2(3) = DATEADD(DAY, @ExpiryDays, GETDATE());
        
        -- Hash the token for security
        DECLARE @TokenHash VARBINARY(64) = HASHBYTES('SHA2_256', @Token);
        
        -- Insert refresh token
        INSERT INTO Security.RefreshTokens (
            UserID, Token, TokenHash, ExpiryDate,
            CreatedByIP, DeviceInfo
        )
        VALUES (
            @UserID, @Token, @TokenHash, @ExpiryDate,
            @IPAddress, @DeviceInfo
        );
        
        SET @RefreshTokenID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- 2. Validate Refresh Token
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_ValidateRefreshToken
    @Token NVARCHAR(500),
    @UserID INT OUTPUT,
    @IsValid BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    SET @IsValid = 0;
    SET @UserID = NULL;
    
    SELECT 
        @UserID = UserID,
        @IsValid = CASE 
            WHEN IsRevoked = 0 
             AND ExpiryDate > GETDATE()
            THEN 1
            ELSE 0
        END
    FROM Security.RefreshTokens
    WHERE Token = @Token;
    
    RETURN 0;
END
GO

-- =============================================
-- 3. Revoke Refresh Token
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_RevokeRefreshToken
    @Token NVARCHAR(500),
    @Reason NVARCHAR(255) = NULL,
    @IPAddress NVARCHAR(50) = NULL,
    @ReplacedByToken NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Security.RefreshTokens
        SET 
            IsRevoked = 1,
            RevokedDate = GETDATE(),
            RevokedByIP = @IPAddress,
            RevokedReason = @Reason,
            ReplacedByToken = @ReplacedByToken
        WHERE Token = @Token
          AND IsRevoked = 0;
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Refresh token not found or already revoked', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -1;
        END
        
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- 4. Revoke All User Refresh Tokens
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_RevokeAllUserRefreshTokens
    @UserID INT,
    @Reason NVARCHAR(255) = 'User logout - all devices'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Security.RefreshTokens
        SET 
            IsRevoked = 1,
            RevokedDate = GETDATE(),
            RevokedReason = @Reason
        WHERE UserID = @UserID
          AND IsRevoked = 0;
        
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- 5. Cleanup Expired Refresh Tokens
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_CleanupExpiredRefreshTokens
    @DaysToKeep INT = 7
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @CutoffDate DATETIME2(3) = DATEADD(DAY, -@DaysToKeep, GETDATE());
        
        DELETE FROM Security.RefreshTokens
        WHERE ExpiryDate < @CutoffDate
          OR (IsRevoked = 1 AND RevokedDate < @CutoffDate);
        
        DECLARE @DeletedCount INT = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        SELECT @DeletedCount AS DeletedTokensCount;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- 6. Get User Refresh Tokens
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetUserRefreshTokens
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        RefreshTokenID,
        Token,
        ExpiryDate,
        CreatedDate,
        CreatedByIP,
        DeviceInfo,
        IsRevoked,
        RevokedDate,
        RevokedReason,
        CASE 
            WHEN IsRevoked = 1 THEN 'Revoked'
            WHEN ExpiryDate < GETDATE() THEN 'Expired'
            ELSE 'Active'
        END AS TokenStatus
    FROM Security.RefreshTokens
    WHERE UserID = @UserID
    ORDER BY CreatedDate DESC;
END
GO

-- =============================================
-- API KEYS PROCEDURES
-- =============================================

-- =============================================
-- 7. Create API Key
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_CreateAPIKey
    @KeyName NVARCHAR(100),
    @KeyValue NVARCHAR(255),
    @CreatedBy INT,
    @UserID INT = NULL,
    @Scope NVARCHAR(MAX) = NULL,
    @AllowedIPs NVARCHAR(MAX) = NULL,
    @ExpiryDays INT = NULL,
    @RateLimitPerHour INT = 1000,
    @Description NVARCHAR(500) = NULL,
    @APIKeyID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Hash the key
        DECLARE @KeyHash VARBINARY(64) = HASHBYTES('SHA2_256', @KeyValue);
        
        -- Calculate expiry date if provided
        DECLARE @ExpiryDate DATETIME2(3) = NULL;
        IF @ExpiryDays IS NOT NULL
            SET @ExpiryDate = DATEADD(DAY, @ExpiryDays, GETDATE());
        
        -- Insert API key
        INSERT INTO Security.APIKeys (
            KeyName, KeyValue, KeyHash, UserID, Scope, AllowedIPs,
            ExpiryDate, CreatedBy, RateLimitPerHour, Description
        )
        VALUES (
            @KeyName, @KeyValue, @KeyHash, @UserID, @Scope, @AllowedIPs,
            @ExpiryDate, @CreatedBy, @RateLimitPerHour, @Description
        );
        
        SET @APIKeyID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- 8. Validate API Key
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_ValidateAPIKey
    @KeyValue NVARCHAR(255),
    @IPAddress NVARCHAR(50) = NULL,
    @IsValid BIT OUTPUT,
    @APIKeyID INT OUTPUT,
    @UserID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    SET @IsValid = 0;
    SET @APIKeyID = NULL;
    SET @UserID = NULL;
    
    -- Get API key details
    SELECT 
        @APIKeyID = APIKeyID,
        @UserID = UserID,
        @IsValid = CASE 
            WHEN IsActive = 1 
             AND (ExpiryDate IS NULL OR ExpiryDate > GETDATE())
             AND (AllowedIPs IS NULL OR @IPAddress IS NULL 
                  OR AllowedIPs LIKE '%' + @IPAddress + '%')
            THEN 1
            ELSE 0
        END
    FROM Security.APIKeys
    WHERE KeyValue = @KeyValue;
    
    -- Update last used date if valid
    IF @IsValid = 1
    BEGIN
        UPDATE Security.APIKeys
        SET LastUsedDate = GETDATE(),
            RequestCount = RequestCount + 1
        WHERE APIKeyID = @APIKeyID;
    END
    
    RETURN 0;
END
GO

-- =============================================
-- 9. Revoke API Key
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_RevokeAPIKey
    @APIKeyID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Security.APIKeys
        SET IsActive = 0
        WHERE APIKeyID = @APIKeyID;
        
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('API Key not found', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -1;
        END
        
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- 10. Get All API Keys
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetAllAPIKeys
    @UserID INT = NULL,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        k.APIKeyID,
        k.KeyName,
        k.KeyValue,
        k.UserID,
        u.Username,
        k.Scope,
        k.AllowedIPs,
        k.IsActive,
        k.ExpiryDate,
        k.CreatedDate,
        k.LastUsedDate,
        k.RateLimitPerHour,
        k.RequestCount,
        k.Description,
        CASE 
            WHEN k.IsActive = 0 THEN 'Revoked'
            WHEN k.ExpiryDate IS NOT NULL AND k.ExpiryDate < GETDATE() THEN 'Expired'
            ELSE 'Active'
        END AS Status
    FROM Security.APIKeys k
    LEFT JOIN Security.[User] u ON k.UserID = u.UserID
    WHERE (@UserID IS NULL OR k.UserID = @UserID)
      AND (k.IsActive = 1 OR @IncludeInactive = 1)
    ORDER BY k.CreatedDate DESC;
END
GO

-- =============================================
-- 11. Log API Request
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_LogAPIRequest
    @APIKeyID INT = NULL,
    @Endpoint NVARCHAR(255),
    @HTTPMethod NVARCHAR(10),
    @StatusCode INT,
    @ResponseTime INT = NULL,
    @IPAddress NVARCHAR(50),
    @UserAgent NVARCHAR(500) = NULL,
    @ErrorMessage NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Security.APIRequestLog (
        APIKeyID, Endpoint, HTTPMethod, StatusCode,
        ResponseTime, IPAddress, UserAgent, ErrorMessage
    )
    VALUES (
        @APIKeyID, @Endpoint, @HTTPMethod, @StatusCode,
        @ResponseTime, @IPAddress, @UserAgent, @ErrorMessage
    );
    
    RETURN 0;
END
GO

-- =============================================
-- 12. Get API Usage Statistics
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_GetAPIUsageStatistics
    @APIKeyID INT = NULL,
    @StartDate DATETIME2(3) = NULL,
    @EndDate DATETIME2(3) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @StartDate IS NULL SET @StartDate = DATEADD(DAY, -7, GETDATE());
    IF @EndDate IS NULL SET @EndDate = GETDATE();
    
    -- Overall statistics
    SELECT 
        COUNT(*) AS TotalRequests,
        COUNT(DISTINCT APIKeyID) AS UniqueAPIKeys,
        AVG(ResponseTime) AS AvgResponseTime,
        COUNT(CASE WHEN StatusCode >= 200 AND StatusCode < 300 THEN 1 END) AS SuccessfulRequests,
        COUNT(CASE WHEN StatusCode >= 400 THEN 1 END) AS ErrorRequests
    FROM Security.APIRequestLog
    WHERE RequestDate BETWEEN @StartDate AND @EndDate
      AND (@APIKeyID IS NULL OR APIKeyID = @APIKeyID);
    
    -- Requests by endpoint
    SELECT TOP 10
        Endpoint,
        COUNT(*) AS RequestCount,
        AVG(ResponseTime) AS AvgResponseTime
    FROM Security.APIRequestLog
    WHERE RequestDate BETWEEN @StartDate AND @EndDate
      AND (@APIKeyID IS NULL OR APIKeyID = @APIKeyID)
    GROUP BY Endpoint
    ORDER BY RequestCount DESC;
    
    -- Requests by status code
    SELECT 
        StatusCode,
        COUNT(*) AS RequestCount
    FROM Security.APIRequestLog
    WHERE RequestDate BETWEEN @StartDate AND @EndDate
      AND (@APIKeyID IS NULL OR APIKeyID = @APIKeyID)
    GROUP BY StatusCode
    ORDER BY StatusCode;
END
GO

-- =============================================
-- 13. Reset API Key Rate Limit
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_ResetAPIKeyRateLimit
    @APIKeyID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @APIKeyID IS NULL
        BEGIN
            -- Reset all keys that need it (hourly reset)
            UPDATE Security.APIKeys
            SET RequestCount = 0,
                LastResetDate = GETDATE()
            WHERE DATEDIFF(HOUR, LastResetDate, GETDATE()) >= 1;
        END
        ELSE
        BEGIN
            -- Reset specific key
            UPDATE Security.APIKeys
            SET RequestCount = 0,
                LastResetDate = GETDATE()
            WHERE APIKeyID = @APIKeyID;
        END
        
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT '✓ Authentication enhancement procedures created successfully';
GO
