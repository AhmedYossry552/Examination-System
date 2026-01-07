/*
============================================================================
Authentication Enhancement Tables
============================================================================
Description: RefreshTokens and API Keys for modern authentication
Author: Examination System Team
Created: 2025-11-13
============================================================================
*/

USE ExaminationSystemDB;
GO

PRINT 'Creating authentication enhancement tables...';
GO

-- =============================================
-- Refresh Tokens Table (JWT Authentication)
-- =============================================
CREATE TABLE Security.RefreshTokens (
    RefreshTokenID INT IDENTITY(1,1) PRIMARY KEY,
    
    -- User Information
    UserID INT NOT NULL,
    
    -- Token Information
    Token NVARCHAR(500) NOT NULL UNIQUE,
    TokenHash VARBINARY(64) NOT NULL,  -- SHA-256 hash for security
    
    -- Expiry & Status
    ExpiryDate DATETIME2(3) NOT NULL,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    CreatedByIP NVARCHAR(50) NULL,
    
    -- Token Lifecycle
    IsRevoked BIT NOT NULL DEFAULT 0,
    RevokedDate DATETIME2(3) NULL,
    RevokedByIP NVARCHAR(50) NULL,
    RevokedReason NVARCHAR(255) NULL,
    ReplacedByToken NVARCHAR(500) NULL,
    
    -- Device Information
    DeviceInfo NVARCHAR(500) NULL,
    
    CONSTRAINT FK_RefreshTokens_User FOREIGN KEY (UserID) 
        REFERENCES Security.[User](UserID)
        ON DELETE CASCADE
) ON [FG_Users];
GO

-- =============================================
-- API Keys Table (External Integrations)
-- =============================================
CREATE TABLE Security.APIKeys (
    APIKeyID INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Key Information
    KeyName NVARCHAR(100) NOT NULL,
    KeyValue NVARCHAR(255) NOT NULL UNIQUE,
    KeyHash VARBINARY(64) NOT NULL,  -- SHA-256 hash
    
    -- Associated User (optional - for user-specific keys)
    UserID INT NULL,
    
    -- Scope & Permissions
    Scope NVARCHAR(MAX) NULL,  -- JSON: ["read:exams", "write:students"]
    AllowedIPs NVARCHAR(MAX) NULL,  -- JSON: ["192.168.1.100", "10.0.0.0/24"]
    
    -- Status & Lifecycle
    IsActive BIT NOT NULL DEFAULT 1,
    ExpiryDate DATETIME2(3) NULL,
    CreatedDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    CreatedBy INT NOT NULL,
    LastUsedDate DATETIME2(3) NULL,
    
    -- Rate Limiting
    RateLimitPerHour INT DEFAULT 1000,
    RequestCount INT DEFAULT 0,
    LastResetDate DATETIME2(3) DEFAULT GETDATE(),
    
    -- Metadata
    Description NVARCHAR(500) NULL,
    
    CONSTRAINT FK_APIKeys_User FOREIGN KEY (UserID) 
        REFERENCES Security.[User](UserID)
        ON DELETE SET NULL,
    CONSTRAINT FK_APIKeys_CreatedBy FOREIGN KEY (CreatedBy) 
        REFERENCES Security.[User](UserID)
) ON [FG_Users];
GO

-- =============================================
-- API Request Log (For monitoring & analytics)
-- =============================================
CREATE TABLE Security.APIRequestLog (
    RequestLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- Request Information
    APIKeyID INT NULL,
    Endpoint NVARCHAR(255) NOT NULL,
    HTTPMethod NVARCHAR(10) NOT NULL,
    
    -- Response Information
    StatusCode INT NOT NULL,
    ResponseTime INT NULL,  -- Milliseconds
    
    -- Client Information
    IPAddress NVARCHAR(50) NOT NULL,
    UserAgent NVARCHAR(500) NULL,
    
    -- Timestamp
    RequestDate DATETIME2(3) NOT NULL DEFAULT GETDATE(),
    
    -- Error Information
    ErrorMessage NVARCHAR(MAX) NULL,
    
    CONSTRAINT FK_APIRequestLog_APIKey FOREIGN KEY (APIKeyID) 
        REFERENCES Security.APIKeys(APIKeyID)
        ON DELETE SET NULL
) ON [FG_Users];
GO

-- =============================================
-- Indexes for Performance
-- =============================================

-- RefreshTokens indexes
CREATE NONCLUSTERED INDEX IX_RefreshTokens_UserID 
    ON Security.RefreshTokens(UserID)
    INCLUDE (Token, ExpiryDate, IsRevoked);

CREATE NONCLUSTERED INDEX IX_RefreshTokens_Token 
    ON Security.RefreshTokens(Token)
    WHERE IsRevoked = 0;

CREATE NONCLUSTERED INDEX IX_RefreshTokens_Expiry 
    ON Security.RefreshTokens(ExpiryDate)
    WHERE IsRevoked = 0;

-- API Keys indexes
CREATE NONCLUSTERED INDEX IX_APIKeys_KeyValue 
    ON Security.APIKeys(KeyValue)
    WHERE IsActive = 1;

CREATE NONCLUSTERED INDEX IX_APIKeys_UserID 
    ON Security.APIKeys(UserID)
    WHERE IsActive = 1;

CREATE NONCLUSTERED INDEX IX_APIKeys_LastUsed 
    ON Security.APIKeys(LastUsedDate)
    WHERE IsActive = 1;

-- API Request Log indexes
CREATE NONCLUSTERED INDEX IX_APIRequestLog_APIKeyID 
    ON Security.APIRequestLog(APIKeyID, RequestDate);

CREATE NONCLUSTERED INDEX IX_APIRequestLog_Date 
    ON Security.APIRequestLog(RequestDate)
    INCLUDE (APIKeyID, StatusCode, ResponseTime);

CREATE NONCLUSTERED INDEX IX_APIRequestLog_IPAddress 
    ON Security.APIRequestLog(IPAddress, RequestDate);

GO

PRINT '✓ Authentication enhancement tables created successfully';
GO
