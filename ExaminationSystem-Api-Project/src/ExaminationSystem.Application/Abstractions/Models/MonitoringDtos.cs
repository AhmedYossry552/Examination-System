using System;
using System.Collections.Generic;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class LiveExamMonitoringDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public int DurationMinutes { get; set; }
        public int TotalMarks { get; set; }

        public int StudentExamID { get; set; }
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string StudentEmail { get; set; } = string.Empty;

        public DateTime? StartTime { get; set; }
        public int? MinutesElapsed { get; set; }
        public int? MinutesRemaining { get; set; }
        public decimal? ProgressPercentage { get; set; }

        public int TotalQuestions { get; set; }
        public int QuestionsAnswered { get; set; }
        public decimal? CompletionPercentage { get; set; }

        public DateTime? LastActivity { get; set; }
        public int? MinutesSinceLastActivity { get; set; }
        public string ActivityStatus { get; set; } = string.Empty;
        public int AlertLevel { get; set; }
        public string? CurrentIPAddress { get; set; }
    }

    public class ExamSessionStatisticsDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public string InstructorName { get; set; } = string.Empty;
        public DateTime StartDateTime { get; set; }
        public DateTime EndDateTime { get; set; }
        public int DurationMinutes { get; set; }

        public int TotalStudents { get; set; }
        public int StudentsStarted { get; set; }
        public int StudentsCompleted { get; set; }
        public int StudentsInProgress { get; set; }

        public decimal? StartRatePercentage { get; set; }
        public decimal? CompletionRatePercentage { get; set; }
        public decimal? AvgCompletionTimeMinutes { get; set; }
        public string ExamStatus { get; set; } = string.Empty;
    }

    public class SuspiciousActivityDto
    {
        public int StudentExamID { get; set; }
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string ExamName { get; set; } = string.Empty;

        public int TooFastAnswering { get; set; }
        public int PatternBias { get; set; }
        public int TooQuickSubmission { get; set; }

        public int RapidAnswerCount { get; set; }
        public int TotalTimeMinutes { get; set; }
        public string RiskLevel { get; set; } = string.Empty;
    }
}
