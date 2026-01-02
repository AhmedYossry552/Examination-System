using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IInstructorService
    {
        Task<IEnumerable<CourseDto>> GetMyCoursesAsync(int userId);
        Task<IEnumerable<CourseStudentDto>> GetCourseStudentsAsync(int userId, int courseId);

        // Exams
        Task<IEnumerable<ExamLiteDto>> GetMyExamsAsync(int userId);
        Task<ExamDetailDto?> GetExamByIdAsync(int userId, int examId);
        Task<int> CreateExamAsync(int userId, CreateExamDto dto);
        Task UpdateExamAsync(int userId, int examId, CreateExamDto dto);
        Task DeleteExamAsync(int userId, int examId);
        Task AddQuestionAsync(int userId, int examId, int questionId, int order, int marks);
        Task GenerateRandomAsync(int userId, int examId, GenerateRandomDto dto);
        Task AssignToStudentsAsync(int userId, int examId, IEnumerable<int> studentIds);
        Task AssignToAllCourseStudentsAsync(int userId, int examId);

        Task<IEnumerable<ExamToGradeDto>> GetExamsToGradeAsync(int userId);
        Task GradeTextAnswerAsync(int userId, int studentAnswerId, decimal marksObtained, string? comments);
        Task<ExamStatisticsDto> GetExamStatisticsAsync(int userId, int examId);
        Task<InstructorExamReportDto> GetInstructorExamReportAsync(int userId, int examId);

        // Dashboard
        Task<InstructorDashboardDto> GetDashboardAsync(int userId);

        // Question Pool Methods
        Task<IEnumerable<QuestionDto>> GetAllQuestionsAsync(int userId);
        Task<int> AddQuestionAsync(int userId, CreateQuestionDto dto);
        Task UpdateQuestionAsync(int userId, int questionId, UpdateQuestionDto dto);
        Task DeleteQuestionAsync(int userId, int questionId);
        Task<IEnumerable<QuestionDto>> GetQuestionsByCourseAsync(int userId, int courseId, string? questionType = null, string? difficultyLevel = null);
        Task<QuestionWithOptionsDto?> GetQuestionWithOptionsAsync(int userId, int questionId);
        Task<int> AddQuestionOptionAsync(int userId, int questionId, CreateQuestionOptionDto dto);
        Task<int> AddQuestionAnswerAsync(int userId, int questionId, CreateQuestionAnswerDto dto);
        Task<QuestionPoolStatisticsDto> GetQuestionPoolStatisticsAsync(int userId, int courseId);

        // Text Answers Analysis
        Task<IEnumerable<TextAnswerAnalysisDto>> GetTextAnswersAnalysisAsync(int userId, int? examId = null);
    }
}
