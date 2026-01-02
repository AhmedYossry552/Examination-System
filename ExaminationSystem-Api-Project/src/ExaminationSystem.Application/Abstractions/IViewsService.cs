using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    /// <summary>
    /// Service interface for database views
    /// </summary>
    public interface IViewsService
    {
        // Security Views
        Task<IEnumerable<UserDetailsViewDto>> GetUserDetailsAsync(int? userId = null, string? userType = null, bool? isActive = null);

        // Academic Views
        Task<IEnumerable<StudentDetailsViewDto>> GetStudentDetailsAsync(int? studentId = null, int? branchId = null, int? trackId = null, int? intakeId = null, bool? isActive = null);
        Task<IEnumerable<InstructorDetailsViewDto>> GetInstructorDetailsAsync(int? instructorId = null, bool? isTrainingManager = null, bool? isActive = null);
        Task<IEnumerable<CourseDetailsViewDto>> GetCourseDetailsAsync(int? courseId = null, bool? isActive = null);
        Task<IEnumerable<CourseEnrollmentViewDto>> GetCourseEnrollmentAsync(int? studentId = null, int? courseId = null, bool? isPassed = null);
        Task<IEnumerable<InstructorCourseAssignmentViewDto>> GetInstructorCourseAssignmentAsync(int? instructorId = null, int? courseId = null, int? intakeId = null, bool? isActive = null);

        // Exam Views
        Task<IEnumerable<ExamDetailsViewDto>> GetExamDetailsAsync(int? examId = null, int? courseId = null, int? instructorId = null, string? examStatus = null, bool? isActive = null);
        Task<IEnumerable<QuestionPoolViewDto>> GetQuestionPoolAsync(int? questionId = null, int? courseId = null, int? instructorId = null, string? questionType = null, string? difficultyLevel = null, bool? isActive = null);
        Task<IEnumerable<StudentExamResultsViewDto>> GetStudentExamResultsAsync(int? studentId = null, int? examId = null, int? courseId = null, bool? isPassed = null);
        Task<IEnumerable<StudentAnswerDetailsViewDto>> GetStudentAnswerDetailsAsync(int? studentExamId = null, int? studentId = null, int? examId = null, bool? needsManualGrading = null);
        Task<IEnumerable<PendingGradingViewDto>> GetPendingGradingAsync(int? instructorId = null, int? examId = null, int? studentId = null);
        Task<IEnumerable<ExamStatisticsViewDto>> GetExamStatisticsAsync(int? examId = null, int? courseId = null);
        Task<IEnumerable<TextAnswersAnalysisViewDto>> GetTextAnswersAnalysisAsync(int? examId = null, int? studentId = null, int? instructorId = null, string? answerClassification = null, bool? isPendingGrading = null);
    }
}
