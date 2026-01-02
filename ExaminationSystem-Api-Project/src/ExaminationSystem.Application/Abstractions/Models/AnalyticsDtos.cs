using System;
using System.Collections.Generic;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class DashboardOverviewDto
    {
        public int TotalActiveUsers { get; set; }
        public int TotalStudents { get; set; }
        public int TotalInstructors { get; set; }
        public int TotalCourses { get; set; }
        public int TotalExams { get; set; }
        public int TotalQuestions { get; set; }
        public int TotalExamsCompleted { get; set; }
        public int TotalBranches { get; set; }
        public int TotalTracks { get; set; }
        public int TotalIntakes { get; set; }
        public int PendingGrading { get; set; }
    }

    public class QuestionDifficultyAnalysisDto
    {
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public int SampleSize { get; set; }
        public decimal SuccessRatePercentage { get; set; }
        public string DifficultyLevel { get; set; } = string.Empty;
        public double? DiscriminationIndex { get; set; }
        public string QuestionQuality { get; set; } = string.Empty;
        public string Recommendation { get; set; } = string.Empty;
    }

    public class StudentPerformancePredictionDto
    {
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public decimal PredictedGrade { get; set; }
        public decimal ConfidenceLevel { get; set; }
        public string RiskLevel { get; set; } = string.Empty;
        public string Recommendation { get; set; } = string.Empty;
    }

    public class AtRiskStudentDto
    {
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public int ExamsTaken { get; set; }
        public decimal? AvgScoreRatio { get; set; }
        public decimal AvgScorePercentage { get; set; }
        public decimal? RecentPerformance { get; set; }
        public string PerformanceTrend { get; set; } = string.Empty;
        public string RiskLevel { get; set; } = string.Empty;
        public string ActionRequired { get; set; } = string.Empty;
    }

    public class CoursePerformanceOverviewDto
    {
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public int TotalStudents { get; set; }
        public int TotalExams { get; set; }
        public decimal? AvgScorePercentage { get; set; }
        public decimal? ScoreStandardDeviation { get; set; }
        public int StudentsPassed { get; set; }
        public int StudentsFailed { get; set; }
        public decimal? PassRatePercentage { get; set; }
    }

    public class CourseQuestionPerformanceDto
    {
        public int QuestionID { get; set; }
        public string QuestionPreview { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public int TimesAsked { get; set; }
        public decimal SuccessRate { get; set; }
        public string Assessment { get; set; } = string.Empty;
    }

    public class CoursePerformanceDashboardDto
    {
        public CoursePerformanceOverviewDto Overview { get; set; } = new CoursePerformanceOverviewDto();
        public List<CourseQuestionPerformanceDto> Questions { get; set; } = new List<CourseQuestionPerformanceDto>();
    }
}
