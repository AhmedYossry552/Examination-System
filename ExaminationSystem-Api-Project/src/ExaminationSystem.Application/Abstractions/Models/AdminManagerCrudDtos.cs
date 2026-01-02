using System;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class CreateUserDto
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string UserType { get; set; } = string.Empty; // Admin, TrainingManager, Instructor, Student
    }

    public class UpdateUserDto
    {
        public string? Email { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? PhoneNumber { get; set; }
        public bool? IsActive { get; set; }
    }

    public class ResetPasswordDto
    {
        public string NewPassword { get; set; } = string.Empty;
    }

    public class ProfileUpdateDto
    {
        public string? Email { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? PhoneNumber { get; set; }
    }

    public class ChangePasswordDto
    {
        public string OldPassword { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }

    public class CreateStudentAccountDto
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public int IntakeID { get; set; }
        public int BranchID { get; set; }
        public int TrackID { get; set; }
        public DateTime? EnrollmentDate { get; set; }
    }

    public class UpdateStudentDto
    {
        public int? IntakeID { get; set; }
        public int? BranchID { get; set; }
        public int? TrackID { get; set; }
        public decimal? GPA { get; set; }
        public DateTime? GraduationDate { get; set; }
    }

    public class CreateInstructorAccountDto
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? Specialization { get; set; }
        public DateTime? HireDate { get; set; }
        public decimal? Salary { get; set; }
        public bool IsTrainingManager { get; set; }
    }

    public class UpdateInstructorDto
    {
        public string? Specialization { get; set; }
        public DateTime? HireDate { get; set; }
        public decimal? Salary { get; set; }
        public bool? IsTrainingManager { get; set; }
        public bool? IsActive { get; set; }
    }

    public class UserLiteDto
    {
        public int UserID { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string UserType { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }
}
