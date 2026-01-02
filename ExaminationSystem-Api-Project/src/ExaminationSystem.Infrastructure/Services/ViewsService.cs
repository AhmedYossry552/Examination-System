using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    /// <summary>
    /// Service implementation for database views
    /// </summary>
    public class ViewsService : IViewsService
    {
        private readonly IViewsRepository _repository;

        public ViewsService(IViewsRepository repository)
        {
            _repository = repository;
        }

        #region Security Views

        public async Task<IEnumerable<UserDetailsViewDto>> GetUserDetailsAsync(int? userId = null, string? userType = null, bool? isActive = null)
        {
            return await _repository.GetUserDetailsAsync(userId, userType, isActive);
        }

        #endregion

        #region Academic Views

        public async Task<IEnumerable<StudentDetailsViewDto>> GetStudentDetailsAsync(int? studentId = null, int? branchId = null, int? trackId = null, int? intakeId = null, bool? isActive = null)
        {
            return await _repository.GetStudentDetailsAsync(studentId, branchId, trackId, intakeId, isActive);
        }

        public async Task<IEnumerable<InstructorDetailsViewDto>> GetInstructorDetailsAsync(int? instructorId = null, bool? isTrainingManager = null, bool? isActive = null)
        {
            return await _repository.GetInstructorDetailsAsync(instructorId, isTrainingManager, isActive);
        }

        public async Task<IEnumerable<CourseDetailsViewDto>> GetCourseDetailsAsync(int? courseId = null, bool? isActive = null)
        {
            return await _repository.GetCourseDetailsAsync(courseId, isActive);
        }

        public async Task<IEnumerable<CourseEnrollmentViewDto>> GetCourseEnrollmentAsync(int? studentId = null, int? courseId = null, bool? isPassed = null)
        {
            return await _repository.GetCourseEnrollmentAsync(studentId, courseId, isPassed);
        }

        public async Task<IEnumerable<InstructorCourseAssignmentViewDto>> GetInstructorCourseAssignmentAsync(int? instructorId = null, int? courseId = null, int? intakeId = null, bool? isActive = null)
        {
            return await _repository.GetInstructorCourseAssignmentAsync(instructorId, courseId, intakeId, isActive);
        }

        #endregion

        #region Exam Views

        public async Task<IEnumerable<ExamDetailsViewDto>> GetExamDetailsAsync(int? examId = null, int? courseId = null, int? instructorId = null, string? examStatus = null, bool? isActive = null)
        {
            return await _repository.GetExamDetailsAsync(examId, courseId, instructorId, examStatus, isActive);
        }

        public async Task<IEnumerable<QuestionPoolViewDto>> GetQuestionPoolAsync(int? questionId = null, int? courseId = null, int? instructorId = null, string? questionType = null, string? difficultyLevel = null, bool? isActive = null)
        {
            return await _repository.GetQuestionPoolAsync(questionId, courseId, instructorId, questionType, difficultyLevel, isActive);
        }

        public async Task<IEnumerable<StudentExamResultsViewDto>> GetStudentExamResultsAsync(int? studentId = null, int? examId = null, int? courseId = null, bool? isPassed = null)
        {
            return await _repository.GetStudentExamResultsAsync(studentId, examId, courseId, isPassed);
        }

        public async Task<IEnumerable<StudentAnswerDetailsViewDto>> GetStudentAnswerDetailsAsync(int? studentExamId = null, int? studentId = null, int? examId = null, bool? needsManualGrading = null)
        {
            return await _repository.GetStudentAnswerDetailsAsync(studentExamId, studentId, examId, needsManualGrading);
        }

        public async Task<IEnumerable<PendingGradingViewDto>> GetPendingGradingAsync(int? instructorId = null, int? examId = null, int? studentId = null)
        {
            return await _repository.GetPendingGradingAsync(instructorId, examId, studentId);
        }

        public async Task<IEnumerable<ExamStatisticsViewDto>> GetExamStatisticsAsync(int? examId = null, int? courseId = null)
        {
            return await _repository.GetExamStatisticsAsync(examId, courseId);
        }

        public async Task<IEnumerable<TextAnswersAnalysisViewDto>> GetTextAnswersAnalysisAsync(int? examId = null, int? studentId = null, int? instructorId = null, string? answerClassification = null, bool? isPendingGrading = null)
        {
            return await _repository.GetTextAnswersAnalysisAsync(examId, studentId, instructorId, answerClassification, isPendingGrading);
        }

        #endregion
    }
}
