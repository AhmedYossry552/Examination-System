using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IStudentService
    {
        Task<IEnumerable<AvailableExamDto>> GetAvailableExamsAsync(int userId);
        Task StartExamAsync(int userId, int examId);
        Task<StudentExamWithQuestionsDto> GetExamWithQuestionsAsync(int userId, int examId);
        Task SubmitAnswerAsync(int userId, int examId, int questionId, string? answerText, int? selectedOptionId);
        Task SubmitExamAsync(int userId, int examId);
        Task<StudentExamResultsDto> GetExamResultsAsync(int userId, int examId);
        Task<StudentProgressDto> GetStudentProgressAsync(int userId);
    }
}
