using System;
using System.Collections.Generic;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class CreateExamDto
    {
        public int CourseID { get; set; }
        public int IntakeID { get; set; }
        public int BranchID { get; set; }
        public int TrackID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public int ExamYear { get; set; }
        public string ExamType { get; set; } = string.Empty; // Regular/Corrective/Remedial
        public int TotalMarks { get; set; }
        public int PassMarks { get; set; }
        public int DurationMinutes { get; set; }
        public DateTime StartDateTime { get; set; }
        public DateTime EndDateTime { get; set; }
        public string? AllowanceOptions { get; set; }
    }

    public class GenerateRandomDto
    {
        public int MultipleChoiceCount { get; set; }
        public int TrueFalseCount { get; set; }
        public int TextCount { get; set; }
        public int MarksPerMC { get; set; } = 2;
        public int MarksPerTF { get; set; } = 1;
        public int MarksPerText { get; set; } = 10;
    }

    public class CourseDto
    {
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public string? CourseDescription { get; set; }
        public int MaxDegree { get; set; }
        public int MinDegree { get; set; }
        public int TotalHours { get; set; }
        public int IntakeID { get; set; }
        public string IntakeName { get; set; } = string.Empty;
        public int BranchID { get; set; }
        public string BranchName { get; set; } = string.Empty;
        public int TrackID { get; set; }
        public string TrackName { get; set; } = string.Empty;
    }

    public class CourseStudentDto
    {
        public int StudentID { get; set; }
        public string Username { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public DateTime? EnrollmentDate { get; set; }
        public decimal? FinalGrade { get; set; }
        public bool? IsPassed { get; set; }
        public string BranchName { get; set; } = string.Empty;
        public string TrackName { get; set; } = string.Empty;
        public string IntakeName { get; set; } = string.Empty;
    }

    public class ExamToGradeDto
    {
        public int StudentExamID { get; set; }
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public DateTime? SubmissionTime { get; set; }
        public decimal? TotalScore { get; set; }
        public int QuestionsNeedingGrading { get; set; }
    }

    public class ExamStatisticsDto
    {
        public int TotalStudents { get; set; }
        public int StudentsCompleted { get; set; }
        public int StudentsPassed { get; set; }
        public int StudentsFailed { get; set; }
        public decimal? AverageScore { get; set; }
        public decimal? HighestScore { get; set; }
        public decimal? LowestScore { get; set; }
        public int PendingGrading { get; set; }
    }

    public class InstructorExamReportDto
    {
        public InstructorExamOverviewDto Overview { get; set; } = new InstructorExamOverviewDto();
        public List<InstructorStudentExamResultDto> Students { get; set; } = new List<InstructorStudentExamResultDto>();
        public List<InstructorQuestionStatDto> Questions { get; set; } = new List<InstructorQuestionStatDto>();
    }

    public class InstructorExamOverviewDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public int TotalMarks { get; set; }
        public int PassMarks { get; set; }
        public DateTime StartDateTime { get; set; }
        public DateTime EndDateTime { get; set; }
        public int TotalStudents { get; set; }
        public int CompletedCount { get; set; }
        public int PassedCount { get; set; }
        public int FailedCount { get; set; }
        public decimal? AverageScore { get; set; }
        public decimal? HighestScore { get; set; }
        public decimal? LowestScore { get; set; }
        public int PendingGrading { get; set; }
    }

    public class InstructorStudentExamResultDto
    {
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public DateTime? StartTime { get; set; }
        public DateTime? SubmissionTime { get; set; }
        public int? TimeTaken { get; set; }
        public decimal? TotalScore { get; set; }
        public bool? IsPassed { get; set; }
        public bool? IsGraded { get; set; }
        public decimal? Percentage { get; set; }
    }

    public class InstructorQuestionStatDto
    {
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public int QuestionMarks { get; set; }
        public int TotalAttempts { get; set; }
        public int CorrectCount { get; set; }
        public int IncorrectCount { get; set; }
        public decimal? SuccessRate { get; set; }
    }

    // Question Pool DTOs
    public class CreateQuestionDto
    {
        public int CourseID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty; // MultipleChoice, TrueFalse, Text
        public string DifficultyLevel { get; set; } = "Medium"; // Easy, Medium, Hard
        public int Points { get; set; }
    }

    public class UpdateQuestionDto
    {
        public string? QuestionText { get; set; }
        public string? DifficultyLevel { get; set; }
        public int? Points { get; set; }
    }

    public class CreateQuestionOptionDto
    {
        public string OptionText { get; set; } = string.Empty;
        public bool IsCorrect { get; set; }
        public int OptionOrder { get; set; }
    }

    public class CreateQuestionAnswerDto
    {
        public string CorrectAnswer { get; set; } = string.Empty;
        public string? AnswerPattern { get; set; }
        public bool CaseSensitive { get; set; } = false;
    }

    public class QuestionDto
    {
        public int QuestionID { get; set; }
        public int CourseID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public string DifficultyLevel { get; set; } = string.Empty;
        public int Points { get; set; }
        public DateTime CreatedDate { get; set; }
        public bool IsActive { get; set; }
    }

    public class QuestionOptionDto
    {
        public int OptionID { get; set; }
        public int QuestionID { get; set; }
        public string OptionText { get; set; } = string.Empty;
        public bool IsCorrect { get; set; }
        public int OptionOrder { get; set; }
    }

    public class QuestionAnswerDto
    {
        public int AnswerID { get; set; }
        public int QuestionID { get; set; }
        public string CorrectAnswer { get; set; } = string.Empty;
        public string? AnswerPattern { get; set; }
        public bool CaseSensitive { get; set; }
    }

    public class QuestionWithOptionsDto : QuestionDto
    {
        public List<QuestionOptionDto> Options { get; set; } = new();
        public QuestionAnswerDto? Answer { get; set; }
    }

    public class QuestionPoolStatisticsDto
    {
        public int TotalQuestions { get; set; }
        public int MultipleChoiceCount { get; set; }
        public int TrueFalseCount { get; set; }
        public int TextCount { get; set; }
        public int EasyCount { get; set; }
        public int MediumCount { get; set; }
        public int HardCount { get; set; }
        public decimal AveragePoints { get; set; }
    }

    public class TextAnswerAnalysisDto
    {
        public int StudentAnswerID { get; set; }
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public int MaxMarks { get; set; }
        public string StudentAnswerText { get; set; } = string.Empty;
        public string ModelAnswer { get; set; } = string.Empty;
        public string? RegexPattern { get; set; }
        public decimal SimilarityScore { get; set; }
        public string Recommendation { get; set; } = string.Empty;
        public decimal SuggestedMarks { get; set; }
        public int MatchingKeywords { get; set; }
        public int TotalKeywords { get; set; }
        public int HoursPendingGrading { get; set; }
        public DateTime? AnsweredDate { get; set; }
    }

    public class TextAnswerAnalysisSummaryDto
    {
        public int TotalAnswers { get; set; }
        public int HighSimilarityCount { get; set; }
        public int MediumSimilarityCount { get; set; }
        public int LowSimilarityCount { get; set; }
        public decimal AverageSimilarity { get; set; }
        public decimal AverageSuggestedMarks { get; set; }
        public int UrgentGradingCount { get; set; }
    }

    // New DTOs for missing endpoints
    public class ExamLiteDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public string ExamType { get; set; } = string.Empty;
        public int TotalMarks { get; set; }
        public int PassMarks { get; set; }
        public int DurationMinutes { get; set; }
        public DateTime StartDateTime { get; set; }
        public DateTime EndDateTime { get; set; }
        public int TotalStudents { get; set; }
        public int CompletedCount { get; set; }
        public string Status { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class ExamDetailDto : ExamLiteDto
    {
        public int CourseID { get; set; }
        public int IntakeID { get; set; }
        public int BranchID { get; set; }
        public int TrackID { get; set; }
        public string IntakeName { get; set; } = string.Empty;
        public string BranchName { get; set; } = string.Empty;
        public string TrackName { get; set; } = string.Empty;
        public string? AllowanceOptions { get; set; }
        public List<ExamQuestionSummaryDto> Questions { get; set; } = new();
    }

    public class ExamQuestionSummaryDto
    {
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public int Order { get; set; }
        public int Marks { get; set; }
    }

    public class InstructorDashboardDto
    {
        public int TotalCourses { get; set; }
        public int TotalStudents { get; set; }
        public int ActiveExams { get; set; }
        public int PendingGrading { get; set; }
        public int TotalQuestions { get; set; }
        public int ExamsCreatedThisMonth { get; set; }
        public decimal AveragePassRate { get; set; }
        public List<RecentExamDto> RecentExams { get; set; } = new();
        public List<UpcomingExamDto> UpcomingExams { get; set; } = new();
    }

    public class RecentExamDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public DateTime EndDateTime { get; set; }
        public int CompletedCount { get; set; }
        public decimal? AverageScore { get; set; }
        public decimal? PassRate { get; set; }
    }

    public class UpcomingExamDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public DateTime StartDateTime { get; set; }
        public int AssignedStudents { get; set; }
    }
}
