using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class StudentService : IStudentService
    {
        private readonly IStudentRepository _repo;
        private readonly IExamMonitorNotifier? _notifier;
        public StudentService(IStudentRepository repo, IExamMonitorNotifier? notifier = null)
        {
            _repo = repo;
            _notifier = notifier;
        }

        public async Task<IEnumerable<AvailableExamDto>> GetAvailableExamsAsync(int userId)
        {
            var studentId = await _repo.GetStudentIdByUserIdAsync(userId);
            return await _repo.GetAvailableExamsAsync(studentId);
        }

        public async Task StartExamAsync(int userId, int examId)
        {
            var studentId = await _repo.GetStudentIdByUserIdAsync(userId);
            await _repo.StartExamAsync(studentId, examId);
            if (_notifier != null)
            {
                await _notifier.NotifyAsync("examStarted", new { userId, studentId, examId });
            }
        }

        public async Task<StudentExamWithQuestionsDto> GetExamWithQuestionsAsync(int userId, int examId)
        {
            var studentId = await _repo.GetStudentIdByUserIdAsync(userId);
            return await _repo.GetExamWithQuestionsAsync(studentId, examId);
        }

        public async Task SubmitAnswerAsync(int userId, int examId, int questionId, string? answerText, int? selectedOptionId)
        {
            var studentId = await _repo.GetStudentIdByUserIdAsync(userId);
            var studentExamId = await _repo.GetStudentExamIdAsync(studentId, examId);
            if (studentExamId == null)
                throw new InvalidOperationException("StudentExam not found.");
            await _repo.SubmitAnswerAsync(studentExamId.Value, questionId, answerText, selectedOptionId);
            if (_notifier != null)
            {
                await _notifier.NotifyAsync("answerSubmitted", new { userId, studentId, examId, questionId });
            }
        }

        public async Task SubmitExamAsync(int userId, int examId)
        {
            var studentId = await _repo.GetStudentIdByUserIdAsync(userId);
            var studentExamId = await _repo.GetStudentExamIdAsync(studentId, examId);
            if (studentExamId == null)
                throw new InvalidOperationException("StudentExam not found.");
            await _repo.SubmitExamAsync(studentExamId.Value);
            if (_notifier != null)
            {
                await _notifier.NotifyAsync("examSubmitted", new { userId, studentId, examId });
            }
        }

        public async Task<StudentExamResultsDto> GetExamResultsAsync(int userId, int examId)
        {
            var studentId = await _repo.GetStudentIdByUserIdAsync(userId);
            return await _repo.GetExamResultsAsync(studentId, examId);
        }

        public async Task<StudentProgressDto> GetStudentProgressAsync(int userId)
        {
            var studentId = await _repo.GetStudentIdByUserIdAsync(userId);
            return await _repo.GetStudentProgressAsync(studentId);
        }
    }
}
