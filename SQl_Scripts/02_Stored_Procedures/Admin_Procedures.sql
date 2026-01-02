/*=============================================
  Examination System - Admin Stored Procedures
  Description: Procedures for system administration
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Procedure: SP_Admin_CreateUser
-- Description: Creates a new user account (any type)
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_Admin_CreateUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(256),
    @Email NVARCHAR(100),
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @PhoneNumber NVARCHAR(20) = NULL,
    @UserType NVARCHAR(20),
    @UserID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate user type
        IF @UserType NOT IN ('Admin', 'TrainingManager', 'Instructor', 'Student')
        BEGIN
            RAISERROR('Invalid user type. Must be Admin, TrainingManager, Instructor, or Student.', 16, 1);
            RETURN -1;
        END
        
        -- Hash password (in production, use proper hashing like HASHBYTES with salt)
        DECLARE @PasswordHash NVARCHAR(256);
        SET @PasswordHash = CONVERT(NVARCHAR(256), HASHBYTES('SHA2_256', @Password), 2);
        
        -- Insert user
        INSERT INTO Security.[User] (Username, PasswordHash, Email, FirstName, LastName, PhoneNumber, UserType, IsActive)
        VALUES (@Username, @PasswordHash, @Email, @FirstName, @LastName, @PhoneNumber, @UserType, 1);
        
        SET @UserID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'User created successfully with ID: ' + CAST(@UserID AS NVARCHAR(10));
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Admin_UpdateUser
-- Description: Updates user information
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_Admin_UpdateUser
    @UserID INT,
    @Email NVARCHAR(100) = NULL,
    @FirstName NVARCHAR(50) = NULL,
    @LastName NVARCHAR(50) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM Security.[User] WHERE UserID = @UserID)
        BEGIN
            RAISERROR('User not found.', 16, 1);
            RETURN -1;
        END
        
        -- Update user
        UPDATE Security.[User]
        SET 
            Email = COALESCE(@Email, Email),
            FirstName = COALESCE(@FirstName, FirstName),
            LastName = COALESCE(@LastName, LastName),
            PhoneNumber = COALESCE(@PhoneNumber, PhoneNumber),
            IsActive = COALESCE(@IsActive, IsActive),
            ModifiedDate = GETDATE()
        WHERE UserID = @UserID;
        
        COMMIT TRANSACTION;
        
        PRINT 'User updated successfully.';
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
-- Procedure: SP_Admin_ChangePassword
-- Description: Changes user password
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_Admin_ChangePassword
    @UserID INT,
    @OldPassword NVARCHAR(256),
    @NewPassword NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Hash old password
        DECLARE @OldPasswordHash NVARCHAR(256);
        SET @OldPasswordHash = CONVERT(NVARCHAR(256), HASHBYTES('SHA2_256', @OldPassword), 2);
        
        -- Verify old password
        IF NOT EXISTS (
            SELECT 1 FROM Security.[User] 
            WHERE UserID = @UserID AND PasswordHash = @OldPasswordHash
        )
        BEGIN
            RAISERROR('Invalid old password.', 16, 1);
            RETURN -1;
        END
        
        -- Hash new password
        DECLARE @NewPasswordHash NVARCHAR(256);
        SET @NewPasswordHash = CONVERT(NVARCHAR(256), HASHBYTES('SHA2_256', @NewPassword), 2);
        
        -- Update password
        UPDATE Security.[User]
        SET PasswordHash = @NewPasswordHash,
            ModifiedDate = GETDATE()
        WHERE UserID = @UserID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Password changed successfully.';
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
-- Procedure: SP_Admin_ResetPassword
-- Description: Admin resets user password
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_Admin_ResetPassword
    @AdminUserID INT,
    @TargetUserID INT,
    @NewPassword NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify admin privileges
        IF NOT EXISTS (
            SELECT 1 FROM Security.[User] 
            WHERE UserID = @AdminUserID AND UserType = 'Admin'
        )
        BEGIN
            RAISERROR('Only administrators can reset passwords.', 16, 1);
            RETURN -1;
        END
        
        -- Hash new password
        DECLARE @NewPasswordHash NVARCHAR(256);
        SET @NewPasswordHash = CONVERT(NVARCHAR(256), HASHBYTES('SHA2_256', @NewPassword), 2);
        
        -- Update password
        UPDATE Security.[User]
        SET PasswordHash = @NewPasswordHash,
            ModifiedDate = GETDATE()
        WHERE UserID = @TargetUserID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Password reset successfully.';
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
-- Procedure: SP_Admin_DeleteUser
-- Description: Soft deletes a user (sets IsActive = 0)
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_Admin_DeleteUser
    @UserID INT,
    @AdminUserID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify admin privileges
        IF NOT EXISTS (
            SELECT 1 FROM Security.[User] 
            WHERE UserID = @AdminUserID AND UserType IN ('Admin', 'TrainingManager')
        )
        BEGIN
            RAISERROR('Insufficient privileges.', 16, 1);
            RETURN -1;
        END
        
        -- Soft delete user
        UPDATE Security.[User]
        SET IsActive = 0,
            ModifiedDate = GETDATE()
        WHERE UserID = @UserID;
        
        COMMIT TRANSACTION;
        
        PRINT 'User deactivated successfully.';
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
-- Procedure: SP_Admin_AuthenticateUser
-- Description: Authenticates user login
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_Admin_AuthenticateUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(256),
    @UserID INT OUTPUT,
    @UserType NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Hash password
        DECLARE @PasswordHash NVARCHAR(256);
        SET @PasswordHash = CONVERT(NVARCHAR(256), HASHBYTES('SHA2_256', @Password), 2);
        
        -- Authenticate
        SELECT @UserID = UserID, @UserType = UserType
        FROM Security.[User]
        WHERE Username = @Username 
            AND PasswordHash = @PasswordHash 
            AND IsActive = 1;
        
        IF @UserID IS NULL
        BEGIN
            RAISERROR('Invalid username or password.', 16, 1);
            RETURN -1;
        END
        
        -- Update last login
        UPDATE Security.[User]
        SET LastLoginDate = GETDATE()
        WHERE UserID = @UserID;
        
        PRINT 'Authentication successful.';
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
-- Procedure: SP_Admin_GetSystemStatistics
-- Description: Returns system-wide statistics
-- =============================================
CREATE OR ALTER PROCEDURE Security.SP_Admin_GetSystemStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        (SELECT COUNT(*) FROM Security.[User] WHERE IsActive = 1) AS TotalActiveUsers,
        (SELECT COUNT(*) FROM Security.[User] WHERE UserType = 'Student' AND IsActive = 1) AS TotalStudents,
        (SELECT COUNT(*) FROM Academic.Instructor WHERE IsActive = 1) AS TotalInstructors,
        (SELECT COUNT(*) FROM Academic.Course WHERE IsActive = 1) AS TotalCourses,
        (SELECT COUNT(*) FROM Exam.Exam WHERE IsActive = 1) AS TotalExams,
        (SELECT COUNT(*) FROM Exam.Question WHERE IsActive = 1) AS TotalQuestions,
        (SELECT COUNT(*) FROM Exam.StudentExam WHERE SubmissionTime IS NOT NULL) AS TotalExamsCompleted,
        (SELECT COUNT(*) FROM Academic.Branch WHERE IsActive = 1) AS TotalBranches,
        (SELECT COUNT(*) FROM Academic.Track WHERE IsActive = 1) AS TotalTracks,
        (SELECT COUNT(*) FROM Academic.Intake WHERE IsActive = 1) AS TotalIntakes;
END
GO

PRINT 'Admin procedures created successfully!';
GO
