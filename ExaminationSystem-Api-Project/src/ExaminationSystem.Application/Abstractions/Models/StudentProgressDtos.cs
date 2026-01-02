using System;
using System.Collections.Generic;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class StudentProgressDto
    {
        public StudentProgressOverviewDto Overview { get; set; } = new StudentProgressOverviewDto();
        public List<StudentCourseProgressDto> Courses { get; set; } = new List<StudentCourseProgressDto>();
        public List<RecentExamResultDto> RecentExams { get; set; } = new List<RecentExamResultDto>();
    }

    public class StudentProgressOverviewDto
    {
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public decimal? GPA { get; set; }
        public string BranchName { get; set; } = string.Empty;
        public string TrackName { get; set; } = string.Empty;
        public string IntakeName { get; set; } = string.Empty;
        public int TotalCourses { get; set; }
        public int PassedCourses { get; set; }
        public int CompletedExams { get; set; }
        public decimal? OverallExamAverage { get; set; }
    }

    public class StudentCourseProgressDto
    {
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public decimal? FinalGrade { get; set; }
        public int MaxDegree { get; set; }
        public int MinDegree { get; set; }
        public bool? IsPassed { get; set; }
        public decimal? Percentage { get; set; }
        public int TotalExams { get; set; }
        public int CompletedExams { get; set; }
    }

    public class RecentExamResultDto
    {
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public decimal? TotalScore { get; set; }
        public int TotalMarks { get; set; }
        public bool? IsPassed { get; set; }
        public DateTime? SubmissionTime { get; set; }
        public decimal? Percentage { get; set; }
    }
}
