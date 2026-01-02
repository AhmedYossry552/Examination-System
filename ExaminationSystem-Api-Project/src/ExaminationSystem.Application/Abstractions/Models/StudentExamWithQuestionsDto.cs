using System;
using System.Collections.Generic;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class StudentExamWithQuestionsDto
    {
        public ExamHeaderDto Exam { get; set; } = new ExamHeaderDto();
        public List<ExamQuestionDto> Questions { get; set; } = new List<ExamQuestionDto>();
    }

    public class ExamHeaderDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string ExamType { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public int TotalMarks { get; set; }
        public int DurationMinutes { get; set; }
        public DateTime? StartDateTime { get; set; }
        public DateTime? EndDateTime { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? SubmissionTime { get; set; }
        public decimal? TotalScore { get; set; }
        public string ExamStatus { get; set; } = string.Empty;
        public int RemainingMinutes { get; set; }
        public bool IsAllowed { get; set; }
        public int TotalQuestions { get; set; }
    }

    public class ExamQuestionDto
    {
        public int QuestionOrder { get; set; }
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public int QuestionMarks { get; set; }
        public int? StudentAnswerID { get; set; }
        public string? StudentAnswerText { get; set; }
        public int? SelectedOptionID { get; set; }
        public bool IsAnswered { get; set; }
        public List<OptionDto> Options { get; set; } = new List<OptionDto>();
    }

    public class OptionDto
    {
        public int OptionID { get; set; }
        public int QuestionID { get; set; }
        public string OptionText { get; set; } = string.Empty;
        public int OptionOrder { get; set; }
    }
}
