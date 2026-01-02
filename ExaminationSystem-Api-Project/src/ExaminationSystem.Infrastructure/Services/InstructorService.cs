using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class InstructorService : IInstructorService
    {
        private readonly IInstructorRepository _repo;
        public InstructorService(IInstructorRepository repo)
        {
            _repo = repo;
        }

        public async Task<IEnumerable<CourseDto>> GetMyCoursesAsync(int userId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetMyCoursesAsync(instructorId);
        }

        public async Task<IEnumerable<CourseStudentDto>> GetCourseStudentsAsync(int userId, int courseId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetCourseStudentsAsync(instructorId, courseId);
        }

        public async Task<int> CreateExamAsync(int userId, CreateExamDto dto)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.CreateExamAsync(dto, instructorId);
        }

        public async Task AddQuestionAsync(int userId, int examId, int questionId, int order, int marks)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            // authorization enforced by DB when adding question via constraints/triggers
            await _repo.AddQuestionAsync(examId, questionId, order, marks);
        }

        public async Task GenerateRandomAsync(int userId, int examId, GenerateRandomDto dto)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            await _repo.GenerateRandomAsync(examId, dto);
        }

        public async Task AssignToStudentsAsync(int userId, int examId, IEnumerable<int> studentIds)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            await _repo.AssignToStudentsAsync(examId, studentIds);
        }

        public async Task AssignToAllCourseStudentsAsync(int userId, int examId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            await _repo.AssignToAllCourseStudentsAsync(examId);
        }

        public async Task<IEnumerable<ExamToGradeDto>> GetExamsToGradeAsync(int userId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetExamsToGradeAsync(instructorId);
        }

        public async Task GradeTextAnswerAsync(int userId, int studentAnswerId, decimal marksObtained, string? comments)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            await _repo.GradeTextAnswerAsync(instructorId, studentAnswerId, marksObtained, comments);
        }

        public async Task<ExamStatisticsDto> GetExamStatisticsAsync(int userId, int examId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetExamStatisticsAsync(instructorId, examId);
        }

        public async Task<InstructorExamReportDto> GetInstructorExamReportAsync(int userId, int examId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetInstructorExamReportAsync(instructorId, examId);
        }

        // Question Pool Methods
        public async Task<int> AddQuestionAsync(int userId, CreateQuestionDto dto)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.AddQuestionAsync(instructorId, dto);
        }

        public async Task UpdateQuestionAsync(int userId, int questionId, UpdateQuestionDto dto)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            await _repo.UpdateQuestionAsync(instructorId, questionId, dto);
        }

        public async Task DeleteQuestionAsync(int userId, int questionId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            await _repo.DeleteQuestionAsync(instructorId, questionId);
        }

        public async Task<IEnumerable<QuestionDto>> GetQuestionsByCourseAsync(int userId, int courseId, string? questionType = null, string? difficultyLevel = null)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetQuestionsByCourseAsync(instructorId, courseId, questionType, difficultyLevel);
        }

        public async Task<QuestionWithOptionsDto?> GetQuestionWithOptionsAsync(int userId, int questionId)
        {
            return await _repo.GetQuestionWithOptionsAsync(questionId);
        }

        public async Task<int> AddQuestionOptionAsync(int userId, int questionId, CreateQuestionOptionDto dto)
        {
            return await _repo.AddQuestionOptionAsync(questionId, dto);
        }

        public async Task<int> AddQuestionAnswerAsync(int userId, int questionId, CreateQuestionAnswerDto dto)
        {
            return await _repo.AddQuestionAnswerAsync(questionId, dto);
        }

        public async Task<QuestionPoolStatisticsDto> GetQuestionPoolStatisticsAsync(int userId, int courseId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetQuestionPoolStatisticsAsync(instructorId, courseId);
        }

        public async Task<IEnumerable<TextAnswerAnalysisDto>> GetTextAnswersAnalysisAsync(int userId, int? examId = null)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetTextAnswersAnalysisAsync(instructorId, examId);
        }

        // New methods for missing endpoints
        public async Task<IEnumerable<ExamLiteDto>> GetMyExamsAsync(int userId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetMyExamsAsync(instructorId);
        }

        public async Task<ExamDetailDto?> GetExamByIdAsync(int userId, int examId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetExamByIdAsync(instructorId, examId);
        }

        public async Task UpdateExamAsync(int userId, int examId, CreateExamDto dto)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            await _repo.UpdateExamAsync(instructorId, examId, dto);
        }

        public async Task DeleteExamAsync(int userId, int examId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            await _repo.DeleteExamAsync(instructorId, examId);
        }

        public async Task<InstructorDashboardDto> GetDashboardAsync(int userId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetDashboardAsync(instructorId);
        }

        public async Task<IEnumerable<QuestionDto>> GetAllQuestionsAsync(int userId)
        {
            var instructorId = await _repo.GetInstructorIdByUserIdAsync(userId);
            return await _repo.GetAllQuestionsAsync(instructorId);
        }
    }
}
