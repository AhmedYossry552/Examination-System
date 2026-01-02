/*=============================================
  Examination System - Course Management Procedures
  Description: Procedures for course and training manager operations
  Author: ITI Team
  Date: 2024
  Version: 1.0
===============================================*/

USE ExaminationSystemDB;
GO

-- =============================================
-- Procedure: SP_Course_Add
-- Description: Adds a new course (Training Manager only)
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Course_Add
    @ManagerUserID INT,
    @CourseName NVARCHAR(100),
    @CourseCode NVARCHAR(20),
    @CourseDescription NVARCHAR(1000) = NULL,
    @MaxDegree INT,
    @MinDegree INT,
    @TotalHours INT,
    @CourseID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify user is training manager
        IF NOT EXISTS (
            SELECT 1 FROM Academic.Instructor i
            INNER JOIN Security.[User] u ON i.UserID = u.UserID
            WHERE u.UserID = @ManagerUserID 
                AND i.IsTrainingManager = 1
                AND i.IsActive = 1
        )
        BEGIN
            RAISERROR('Only Training Managers can add courses.', 16, 1);
            RETURN -1;
        END
        
        -- Insert course
        INSERT INTO Academic.Course (
            CourseName, CourseCode, CourseDescription, MaxDegree, 
            MinDegree, TotalHours, IsActive
        )
        VALUES (
            @CourseName, @CourseCode, @CourseDescription, @MaxDegree,
            @MinDegree, @TotalHours, 1
        );
        
        SET @CourseID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Course added successfully with ID: ' + CAST(@CourseID AS NVARCHAR(10));
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
-- Procedure: SP_Branch_Update
-- Description: Updates a branch
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Branch_Update
    @ManagerUserID INT,
    @BranchID INT,
    @BranchName NVARCHAR(100) = NULL,
    @BranchLocation NVARCHAR(200) = NULL,
    @BranchManager NVARCHAR(100) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM Academic.Instructor i
            INNER JOIN Security.[User] u ON i.UserID = u.UserID
            WHERE u.UserID = @ManagerUserID AND i.IsTrainingManager = 1 AND i.IsActive = 1)
        BEGIN
            RAISERROR('Only Training Managers can update branches.', 16, 1);
            RETURN -1;
        END

        UPDATE Academic.Branch
        SET 
            BranchName = COALESCE(@BranchName, BranchName),
            BranchLocation = COALESCE(@BranchLocation, BranchLocation),
            BranchManager = COALESCE(@BranchManager, BranchManager),
            PhoneNumber = COALESCE(@PhoneNumber, PhoneNumber),
            Email = COALESCE(@Email, Email),
            IsActive = COALESCE(@IsActive, IsActive),
            ModifiedDate = GETDATE()
        WHERE BranchID = @BranchID;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Track_Update
-- Description: Updates a track
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Track_Update
    @ManagerUserID INT,
    @TrackID INT,
    @TrackName NVARCHAR(100) = NULL,
    @TrackDescription NVARCHAR(500) = NULL,
    @DurationMonths INT = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM Academic.Instructor i
            INNER JOIN Security.[User] u ON i.UserID = u.UserID
            WHERE u.UserID = @ManagerUserID AND i.IsTrainingManager = 1 AND i.IsActive = 1)
        BEGIN
            RAISERROR('Only Training Managers can update tracks.', 16, 1);
            RETURN -1;
        END

        UPDATE Academic.Track
        SET 
            TrackName = COALESCE(@TrackName, TrackName),
            TrackDescription = COALESCE(@TrackDescription, TrackDescription),
            DurationMonths = COALESCE(@DurationMonths, DurationMonths),
            IsActive = COALESCE(@IsActive, IsActive),
            ModifiedDate = GETDATE()
        WHERE TrackID = @TrackID;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Intake_Update
-- Description: Updates an intake
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Intake_Update
    @ManagerUserID INT,
    @IntakeID INT,
    @IntakeName NVARCHAR(50) = NULL,
    @IntakeYear INT = NULL,
    @IntakeNumber INT = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM Academic.Instructor i
            INNER JOIN Security.[User] u ON i.UserID = u.UserID
            WHERE u.UserID = @ManagerUserID AND i.IsTrainingManager = 1 AND i.IsActive = 1)
        BEGIN
            RAISERROR('Only Training Managers can update intakes.', 16, 1);
            RETURN -1;
        END

        UPDATE Academic.Intake
        SET 
            IntakeName = COALESCE(@IntakeName, IntakeName),
            IntakeYear = COALESCE(@IntakeYear, IntakeYear),
            IntakeNumber = COALESCE(@IntakeNumber, IntakeNumber),
            StartDate = COALESCE(@StartDate, StartDate),
            EndDate = COALESCE(@EndDate, EndDate),
            IsActive = COALESCE(@IsActive, IsActive),
            ModifiedDate = GETDATE()
        WHERE IntakeID = @IntakeID;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END
GO

-- =============================================
-- Procedure: SP_Course_Update
-- Description: Updates course information
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Course_Update
    @ManagerUserID INT,
    @CourseID INT,
    @CourseName NVARCHAR(100) = NULL,
    @CourseDescription NVARCHAR(1000) = NULL,
    @MaxDegree INT = NULL,
    @MinDegree INT = NULL,
    @TotalHours INT = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify user is training manager
        IF NOT EXISTS (
            SELECT 1 FROM Academic.Instructor i
            INNER JOIN Security.[User] u ON i.UserID = u.UserID
            WHERE u.UserID = @ManagerUserID 
                AND i.IsTrainingManager = 1
                AND i.IsActive = 1
        )
        BEGIN
            RAISERROR('Only Training Managers can update courses.', 16, 1);
            RETURN -1;
        END
        
        -- Update course
        UPDATE Academic.Course
        SET 
            CourseName = COALESCE(@CourseName, CourseName),
            CourseDescription = COALESCE(@CourseDescription, CourseDescription),
            MaxDegree = COALESCE(@MaxDegree, MaxDegree),
            MinDegree = COALESCE(@MinDegree, MinDegree),
            TotalHours = COALESCE(@TotalHours, TotalHours),
            IsActive = COALESCE(@IsActive, IsActive),
            ModifiedDate = GETDATE()
        WHERE CourseID = @CourseID;
        
        COMMIT TRANSACTION;
        
        PRINT 'Course updated successfully.';
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
-- Procedure: SP_Branch_Add
-- Description: Adds a new branch
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Branch_Add
    @ManagerUserID INT,
    @BranchName NVARCHAR(100),
    @BranchLocation NVARCHAR(200),
    @BranchManager NVARCHAR(100) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @BranchID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify user is training manager
        IF NOT EXISTS (
            SELECT 1 FROM Academic.Instructor i
            INNER JOIN Security.[User] u ON i.UserID = u.UserID
            WHERE u.UserID = @ManagerUserID 
                AND i.IsTrainingManager = 1
                AND i.IsActive = 1
        )
        BEGIN
            RAISERROR('Only Training Managers can add branches.', 16, 1);
            RETURN -1;
        END
        
        -- Insert branch
        INSERT INTO Academic.Branch (BranchName, BranchLocation, BranchManager, PhoneNumber, Email, IsActive)
        VALUES (@BranchName, @BranchLocation, @BranchManager, @PhoneNumber, @Email, 1);
        
        SET @BranchID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Branch added successfully with ID: ' + CAST(@BranchID AS NVARCHAR(10));
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
-- Procedure: SP_Track_Add
-- Description: Adds a new track
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Track_Add
    @ManagerUserID INT,
    @TrackName NVARCHAR(100),
    @BranchID INT,
    @TrackDescription NVARCHAR(500) = NULL,
    @DurationMonths INT = 3,
    @TrackID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify user is training manager
        IF NOT EXISTS (
            SELECT 1 FROM Academic.Instructor i
            INNER JOIN Security.[User] u ON i.UserID = u.UserID
            WHERE u.UserID = @ManagerUserID 
                AND i.IsTrainingManager = 1
                AND i.IsActive = 1
        )
        BEGIN
            RAISERROR('Only Training Managers can add tracks.', 16, 1);
            RETURN -1;
        END
        
        -- Insert track
        INSERT INTO Academic.Track (TrackName, BranchID, TrackDescription, DurationMonths, IsActive)
        VALUES (@TrackName, @BranchID, @TrackDescription, @DurationMonths, 1);
        
        SET @TrackID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Track added successfully with ID: ' + CAST(@TrackID AS NVARCHAR(10));
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
-- Procedure: SP_Intake_Add
-- Description: Adds a new intake
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Intake_Add
    @ManagerUserID INT,
    @IntakeName NVARCHAR(50),
    @IntakeYear INT,
    @IntakeNumber INT,
    @StartDate DATE,
    @EndDate DATE,
    @IntakeID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verify user is training manager
        IF NOT EXISTS (
            SELECT 1 FROM Academic.Instructor i
            INNER JOIN Security.[User] u ON i.UserID = u.UserID
            WHERE u.UserID = @ManagerUserID 
                AND i.IsTrainingManager = 1
                AND i.IsActive = 1
        )
        BEGIN
            RAISERROR('Only Training Managers can add intakes.', 16, 1);
            RETURN -1;
        END
        
        -- Insert intake
        INSERT INTO Academic.Intake (IntakeName, IntakeYear, IntakeNumber, StartDate, EndDate, IsActive)
        VALUES (@IntakeName, @IntakeYear, @IntakeNumber, @StartDate, @EndDate, 1);
        
        SET @IntakeID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        PRINT 'Intake added successfully with ID: ' + CAST(@IntakeID AS NVARCHAR(10));
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
-- Procedure: SP_Course_GetAll
-- Description: Gets all courses
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Course_GetAll
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        CourseID,
        CourseName,
        CourseCode,
        CourseDescription,
        MaxDegree,
        MinDegree,
        TotalHours,
        IsActive,
        CreatedDate,
        ModifiedDate
    FROM Academic.Course
    WHERE IsActive = 1 OR @IncludeInactive = 1
    ORDER BY CourseName;
END
GO

-- =============================================
-- Procedure: SP_Branch_GetAll
-- Description: Gets all branches with track count
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Branch_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        b.BranchID,
        b.BranchName,
        b.BranchLocation,
        b.BranchManager,
        b.PhoneNumber,
        b.Email,
        b.IsActive,
        COUNT(t.TrackID) AS TrackCount,
        (SELECT COUNT(*) FROM Academic.Student WHERE BranchID = b.BranchID AND IsActive = 1) AS StudentCount
    FROM Academic.Branch b
    LEFT JOIN Academic.Track t ON b.BranchID = t.BranchID AND t.IsActive = 1
    WHERE b.IsActive = 1
    GROUP BY 
        b.BranchID, b.BranchName, b.BranchLocation, b.BranchManager, 
        b.PhoneNumber, b.Email, b.IsActive
    ORDER BY b.BranchName;
END
GO

-- =============================================
-- Procedure: SP_Track_GetByBranch
-- Description: Gets all tracks for a branch
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Track_GetByBranch
    @BranchID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        t.TrackID,
        t.TrackName,
        t.TrackDescription,
        t.DurationMonths,
        t.IsActive,
        COUNT(s.StudentID) AS StudentCount
    FROM Academic.Track t
    LEFT JOIN Academic.Student s ON t.TrackID = s.TrackID AND s.IsActive = 1
    WHERE t.BranchID = @BranchID AND t.IsActive = 1
    GROUP BY t.TrackID, t.TrackName, t.TrackDescription, t.DurationMonths, t.IsActive
    ORDER BY t.TrackName;
END
GO

-- =============================================
-- Procedure: SP_Intake_GetAll
-- Description: Gets all intakes
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Intake_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        i.IntakeID,
        i.IntakeName,
        i.IntakeYear,
        i.IntakeNumber,
        i.StartDate,
        i.EndDate,
        i.IsActive,
        COUNT(s.StudentID) AS StudentCount,
        CASE 
            WHEN GETDATE() < i.StartDate THEN 'Upcoming'
            WHEN GETDATE() > i.EndDate THEN 'Completed'
            ELSE 'Active'
        END AS IntakeStatus
    FROM Academic.Intake i
    LEFT JOIN Academic.Student s ON i.IntakeID = s.IntakeID AND s.IsActive = 1
    WHERE i.IsActive = 1
    GROUP BY 
        i.IntakeID, i.IntakeName, i.IntakeYear, i.IntakeNumber,
        i.StartDate, i.EndDate, i.IsActive
    ORDER BY i.IntakeYear DESC, i.IntakeNumber DESC;
END
GO

-- =============================================
-- Procedure: SP_Course_GetInstructors
-- Description: Gets all instructors for a course
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Course_GetInstructors
    @CourseID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT DISTINCT
        i.InstructorID,
        u.FirstName + ' ' + u.LastName AS InstructorName,
        u.Email,
        i.Specialization,
        ci.IntakeID,
        ik.IntakeName,
        ci.BranchID,
        b.BranchName,
        ci.TrackID,
        t.TrackName,
        ci.AssignedDate
    FROM Academic.CourseInstructor ci
    INNER JOIN Academic.Instructor i ON ci.InstructorID = i.InstructorID
    INNER JOIN Security.[User] u ON i.UserID = u.UserID
    INNER JOIN Academic.Intake ik ON ci.IntakeID = ik.IntakeID
    INNER JOIN Academic.Branch b ON ci.BranchID = b.BranchID
    INNER JOIN Academic.Track t ON ci.TrackID = t.TrackID
    WHERE ci.CourseID = @CourseID
        AND ci.IsActive = 1
    ORDER BY ik.IntakeName, b.BranchName, t.TrackName;
END
GO

-- =============================================
-- Procedure: SP_Student_GetByIntakeBranchTrack
-- Description: Gets students by intake, branch, and track
-- =============================================
CREATE OR ALTER PROCEDURE Academic.SP_Student_GetByIntakeBranchTrack
    @IntakeID INT = NULL,
    @BranchID INT = NULL,
    @TrackID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.StudentID,
        u.Username,
        u.FirstName,
        u.LastName,
        u.Email,
        u.PhoneNumber,
        s.EnrollmentDate,
        s.GPA,
        i.IntakeName,
        b.BranchName,
        t.TrackName,
        (SELECT COUNT(*) FROM Academic.StudentCourse WHERE StudentID = s.StudentID) AS CoursesEnrolled
    FROM Academic.Student s
    INNER JOIN Security.[User] u ON s.UserID = u.UserID
    INNER JOIN Academic.Intake i ON s.IntakeID = i.IntakeID
    INNER JOIN Academic.Branch b ON s.BranchID = b.BranchID
    INNER JOIN Academic.Track t ON s.TrackID = t.TrackID
    WHERE s.IsActive = 1
        AND (@IntakeID IS NULL OR s.IntakeID = @IntakeID)
        AND (@BranchID IS NULL OR s.BranchID = @BranchID)
        AND (@TrackID IS NULL OR s.TrackID = @TrackID)
    ORDER BY u.LastName, u.FirstName;
END
GO

PRINT 'Course and Training Manager procedures created successfully!';
GO
