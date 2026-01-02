using System;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class AvailableExamDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public string ExamType { get; set; } = string.Empty;
        public int TotalMarks { get; set; }
        public int DurationMinutes { get; set; }
        public DateTime? StartDateTime { get; set; }
        public DateTime? EndDateTime { get; set; }
        public bool IsAllowed { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? SubmissionTime { get; set; }
        public decimal? TotalScore { get; set; }
        public bool? IsPassed { get; set; }
        public string ExamStatus { get; set; } = string.Empty;
    }
}
