using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IInstructorRepository
    {
        Task<int> GetInstructorIdByUserIdAsync(int userId);

        // Exams
        Task<IEnumerable<ExamLiteDto>> GetMyExamsAsync(int instructorId);
        Task<ExamDetailDto?> GetExamByIdAsync(int instructorId, int examId);
        Task<int> CreateExamAsync(CreateExamDto dto, int instructorId);
        Task UpdateExamAsync(int instructorId, int examId, CreateExamDto dto);
        Task DeleteExamAsync(int instructorId, int examId);
        Task AddQuestionAsync(int examId, int questionId, int order, int marks);
        Task GenerateRandomAsync(int examId, GenerateRandomDto dto);
        Task AssignToStudentsAsync(int examId, IEnumerable<int> studentIds);
        Task AssignToAllCourseStudentsAsync(int examId);

        Task<IEnumerable<CourseDto>> GetMyCoursesAsync(int instructorId);
        Task<IEnumerable<CourseStudentDto>> GetCourseStudentsAsync(int instructorId, int courseId);
        Task<IEnumerable<ExamToGradeDto>> GetExamsToGradeAsync(int instructorId);
        Task GradeTextAnswerAsync(int instructorId, int studentAnswerId, decimal marksObtained, string? comments);
        Task<ExamStatisticsDto> GetExamStatisticsAsync(int instructorId, int examId);
        Task<InstructorExamReportDto> GetInstructorExamReportAsync(int instructorId, int examId);

        // Dashboard
        Task<InstructorDashboardDto> GetDashboardAsync(int instructorId);

        // Question Pool Methods
        Task<IEnumerable<QuestionDto>> GetAllQuestionsAsync(int instructorId);
        Task<int> AddQuestionAsync(int instructorId, CreateQuestionDto dto);
        Task UpdateQuestionAsync(int instructorId, int questionId, UpdateQuestionDto dto);
        Task DeleteQuestionAsync(int instructorId, int questionId);
        Task<IEnumerable<QuestionDto>> GetQuestionsByCourseAsync(int instructorId, int courseId, string? questionType = null, string? difficultyLevel = null);
        Task<QuestionWithOptionsDto?> GetQuestionWithOptionsAsync(int questionId);
        Task<int> AddQuestionOptionAsync(int questionId, CreateQuestionOptionDto dto);
        Task<int> AddQuestionAnswerAsync(int questionId, CreateQuestionAnswerDto dto);
        Task<QuestionPoolStatisticsDto> GetQuestionPoolStatisticsAsync(int instructorId, int courseId);

        // Text Answers Analysis
        Task<IEnumerable<TextAnswerAnalysisDto>> GetTextAnswersAnalysisAsync(int instructorId, int? examId = null);
    }
}
