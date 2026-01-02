using System;
using System.Collections.Generic;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class StudentExamResultsDto
    {
        public ExamResultsHeaderDto Exam { get; set; } = new ExamResultsHeaderDto();
        public List<QuestionResultDto> Questions { get; set; } = new List<QuestionResultDto>();
    }

    public class ExamResultsHeaderDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public int TotalMarks { get; set; }
        public int PassMarks { get; set; }
        public decimal? TotalScore { get; set; }
        public bool? IsPassed { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? SubmissionTime { get; set; }
        public int? TimeTakenMinutes { get; set; }
        public decimal? Percentage { get; set; }
        public int TotalQuestions { get; set; }
        public int CorrectAnswers { get; set; }
        public int IncorrectAnswers { get; set; }
        public int PendingGrading { get; set; }
    }

    public class QuestionResultDto
    {
        public int QuestionID { get; set; }
        public int QuestionOrder { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public int QuestionMarks { get; set; }
        public string? StudentAnswerText { get; set; }
        public bool? IsCorrect { get; set; }
        public decimal? MarksObtained { get; set; }
        public bool? NeedsManualGrading { get; set; }
        public string? InstructorComments { get; set; }
        public string? SelectedOption { get; set; }
        public string? CorrectAnswer { get; set; }
    }
}
