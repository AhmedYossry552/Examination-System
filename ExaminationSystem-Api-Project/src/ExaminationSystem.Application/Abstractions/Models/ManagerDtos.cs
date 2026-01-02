using System;
using System.Collections.Generic;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class BranchDto
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; } = string.Empty;
        public string BranchLocation { get; set; } = string.Empty;
        public string? BranchManager { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Email { get; set; }
        public bool IsActive { get; set; }
        public int TrackCount { get; set; }
        public int StudentCount { get; set; }
    }

    public class TrackDto
    {
        public int TrackID { get; set; }
        public string TrackName { get; set; } = string.Empty;
        public string? TrackDescription { get; set; }
        public int DurationMonths { get; set; }
        public bool IsActive { get; set; }
        public int StudentCount { get; set; }
    }

    public class IntakeDto
    {
        public int IntakeID { get; set; }
        public string IntakeName { get; set; } = string.Empty;
        public int IntakeYear { get; set; }
        public int IntakeNumber { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsActive { get; set; }
        public int StudentCount { get; set; }
        public string IntakeStatus { get; set; } = string.Empty;
    }

    public class CreateCourseDto
    {
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public string? CourseDescription { get; set; }
        public int MaxDegree { get; set; }
        public int MinDegree { get; set; }
        public int TotalHours { get; set; }
    }

    public class UpdateCourseDto
    {
        public string? CourseName { get; set; }
        public string? CourseDescription { get; set; }
        public int? MaxDegree { get; set; }
        public int? MinDegree { get; set; }
        public int? TotalHours { get; set; }
        public bool? IsActive { get; set; }
    }

    public class CreateBranchDto
    {
        public string BranchName { get; set; } = string.Empty;
        public string BranchLocation { get; set; } = string.Empty;
        public string? BranchManager { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Email { get; set; }
    }

    public class UpdateBranchDto
    {
        public string? BranchName { get; set; }
        public string? BranchLocation { get; set; }
        public string? BranchManager { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Email { get; set; }
        public bool? IsActive { get; set; }
    }

    public class CreateTrackDto
    {
        public string TrackName { get; set; } = string.Empty;
        public int BranchID { get; set; }
        public string? TrackDescription { get; set; }
        public int DurationMonths { get; set; } = 3;
    }

    public class UpdateTrackDto
    {
        public string? TrackName { get; set; }
        public string? TrackDescription { get; set; }
        public int? DurationMonths { get; set; }
        public bool? IsActive { get; set; }
    }

    public class CreateIntakeDto
    {
        public string IntakeName { get; set; } = string.Empty;
        public int IntakeYear { get; set; }
        public int IntakeNumber { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
    }

    public class UpdateIntakeDto
    {
        public string? IntakeName { get; set; }
        public int? IntakeYear { get; set; }
        public int? IntakeNumber { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public bool? IsActive { get; set; }
    }

    public class InstructorLiteDto
    {
        public int InstructorID { get; set; }
        public string InstructorName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? Specialization { get; set; }
        public int IntakeID { get; set; }
        public string IntakeName { get; set; } = string.Empty;
        public int BranchID { get; set; }
        public string BranchName { get; set; } = string.Empty;
        public int TrackID { get; set; }
        public string TrackName { get; set; } = string.Empty;
        public DateTime? AssignedDate { get; set; }
    }

    public class StudentLiteDto
    {
        public int StudentID { get; set; }
        public string Username { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public DateTime? EnrollmentDate { get; set; }
        public decimal? GPA { get; set; }
        public string IntakeName { get; set; } = string.Empty;
        public string BranchName { get; set; } = string.Empty;
        public string TrackName { get; set; } = string.Empty;
        public int CoursesEnrolled { get; set; }
        public string StudentName { get; set; } = string.Empty;
    }

    // Dashboard & Enrollments DTOs
    public class ManagerDashboardDto
    {
        public int TotalStudents { get; set; }
        public int TotalInstructors { get; set; }
        public int TotalCourses { get; set; }
        public int TotalBranches { get; set; }
        public int TotalTracks { get; set; }
        public int ActiveIntakes { get; set; }
        public int TotalExams { get; set; }
        public int ActiveExams { get; set; }
        public decimal AveragePassRate { get; set; }
        public List<BranchStatsDto> BranchStats { get; set; } = new();
    }

    public class BranchStatsDto
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; } = string.Empty;
        public int StudentCount { get; set; }
        public int InstructorCount { get; set; }
        public int CourseCount { get; set; }
    }

    public class EnrollmentDto
    {
        public int EnrollmentID { get; set; }
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public DateTime EnrollmentDate { get; set; }
        public decimal? FinalGrade { get; set; }
        public bool? IsPassed { get; set; }
    }
}
