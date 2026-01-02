using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IStudentRepository
    {
        Task<int> GetStudentIdByUserIdAsync(int userId);
        Task<IEnumerable<AvailableExamDto>> GetAvailableExamsAsync(int studentId);
        Task StartExamAsync(int studentId, int examId);
        Task<int?> GetStudentExamIdAsync(int studentId, int examId);
        Task SubmitAnswerAsync(int studentExamId, int questionId, string? answerText, int? selectedOptionId);
        Task SubmitExamAsync(int studentExamId);
        Task<StudentExamWithQuestionsDto> GetExamWithQuestionsAsync(int studentId, int examId);
        Task<StudentExamResultsDto> GetExamResultsAsync(int studentId, int examId);
        Task<StudentProgressDto> GetStudentProgressAsync(int studentId);
    }
}
