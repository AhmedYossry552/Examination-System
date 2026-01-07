using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for database views - provides read-only access to aggregated data
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class ViewsController : ControllerBase
    {
        private readonly IViewsService _viewsService;

        public ViewsController(IViewsService viewsService)
        {
            _viewsService = viewsService;
        }

        #region Security Views

        /// <summary>
        /// Get user details from VW_UserDetails view
        /// </summary>
        [HttpGet("users")]
        public async Task<ActionResult<IEnumerable<UserDetailsViewDto>>> GetUserDetails(
            [FromQuery] int? userId = null,
            [FromQuery] string? userType = null,
            [FromQuery] bool? isActive = null)
        {
            var result = await _viewsService.GetUserDetailsAsync(userId, userType, isActive);
            return Ok(result);
        }

        #endregion

        #region Academic Views

        /// <summary>
        /// Get student details from VW_StudentDetails view
        /// </summary>
        [HttpGet("students")]
        public async Task<ActionResult<IEnumerable<StudentDetailsViewDto>>> GetStudentDetails(
            [FromQuery] int? studentId = null,
            [FromQuery] int? branchId = null,
            [FromQuery] int? trackId = null,
            [FromQuery] int? intakeId = null,
            [FromQuery] bool? isActive = null)
        {
            var result = await _viewsService.GetStudentDetailsAsync(studentId, branchId, trackId, intakeId, isActive);
            return Ok(result);
        }

        /// <summary>
        /// Get instructor details from VW_InstructorDetails view
        /// </summary>
        [HttpGet("instructors")]
        public async Task<ActionResult<IEnumerable<InstructorDetailsViewDto>>> GetInstructorDetails(
            [FromQuery] int? instructorId = null,
            [FromQuery] bool? isTrainingManager = null,
            [FromQuery] bool? isActive = null)
        {
            var result = await _viewsService.GetInstructorDetailsAsync(instructorId, isTrainingManager, isActive);
            return Ok(result);
        }

        /// <summary>
        /// Get course details from VW_CourseDetails view
        /// </summary>
        [HttpGet("courses")]
        public async Task<ActionResult<IEnumerable<CourseDetailsViewDto>>> GetCourseDetails(
            [FromQuery] int? courseId = null,
            [FromQuery] bool? isActive = null)
        {
            var result = await _viewsService.GetCourseDetailsAsync(courseId, isActive);
            return Ok(result);
        }

        /// <summary>
        /// Get course enrollment from VW_CourseEnrollment view
        /// </summary>
        [HttpGet("course-enrollments")]
        public async Task<ActionResult<IEnumerable<CourseEnrollmentViewDto>>> GetCourseEnrollment(
            [FromQuery] int? studentId = null,
            [FromQuery] int? courseId = null,
            [FromQuery] bool? isPassed = null)
        {
            var result = await _viewsService.GetCourseEnrollmentAsync(studentId, courseId, isPassed);
            return Ok(result);
        }

        /// <summary>
        /// Get instructor course assignments from VW_InstructorCourseAssignment view
        /// </summary>
        [HttpGet("instructor-assignments")]
        public async Task<ActionResult<IEnumerable<InstructorCourseAssignmentViewDto>>> GetInstructorCourseAssignment(
            [FromQuery] int? instructorId = null,
            [FromQuery] int? courseId = null,
            [FromQuery] int? intakeId = null,
            [FromQuery] bool? isActive = null)
        {
            var result = await _viewsService.GetInstructorCourseAssignmentAsync(instructorId, courseId, intakeId, isActive);
            return Ok(result);
        }

        #endregion

        #region Exam Views

        /// <summary>
        /// Get exam details from VW_ExamDetails view
        /// </summary>
        [HttpGet("exams")]
        public async Task<ActionResult<IEnumerable<ExamDetailsViewDto>>> GetExamDetails(
            [FromQuery] int? examId = null,
            [FromQuery] int? courseId = null,
            [FromQuery] int? instructorId = null,
            [FromQuery] string? examStatus = null,
            [FromQuery] bool? isActive = null)
        {
            var result = await _viewsService.GetExamDetailsAsync(examId, courseId, instructorId, examStatus, isActive);
            return Ok(result);
        }

        /// <summary>
        /// Get question pool from VW_QuestionPool view
        /// </summary>
        [HttpGet("questions")]
        public async Task<ActionResult<IEnumerable<QuestionPoolViewDto>>> GetQuestionPool(
            [FromQuery] int? questionId = null,
            [FromQuery] int? courseId = null,
            [FromQuery] int? instructorId = null,
            [FromQuery] string? questionType = null,
            [FromQuery] string? difficultyLevel = null,
            [FromQuery] bool? isActive = null)
        {
            var result = await _viewsService.GetQuestionPoolAsync(questionId, courseId, instructorId, questionType, difficultyLevel, isActive);
            return Ok(result);
        }

        /// <summary>
        /// Get student exam results from VW_StudentExamResults view
        /// </summary>
        [HttpGet("exam-results")]
        public async Task<ActionResult<IEnumerable<StudentExamResultsViewDto>>> GetStudentExamResults(
            [FromQuery] int? studentId = null,
            [FromQuery] int? examId = null,
            [FromQuery] int? courseId = null,
            [FromQuery] bool? isPassed = null)
        {
            var result = await _viewsService.GetStudentExamResultsAsync(studentId, examId, courseId, isPassed);
            return Ok(result);
        }

        /// <summary>
        /// Get student answer details from VW_StudentAnswerDetails view
        /// </summary>
        [HttpGet("answer-details")]
        public async Task<ActionResult<IEnumerable<StudentAnswerDetailsViewDto>>> GetStudentAnswerDetails(
            [FromQuery] int? studentExamId = null,
            [FromQuery] int? studentId = null,
            [FromQuery] int? examId = null,
            [FromQuery] bool? needsManualGrading = null)
        {
            var result = await _viewsService.GetStudentAnswerDetailsAsync(studentExamId, studentId, examId, needsManualGrading);
            return Ok(result);
        }

        /// <summary>
        /// Get pending grading from VW_PendingGrading view
        /// </summary>
        [HttpGet("pending-grading")]
        public async Task<ActionResult<IEnumerable<PendingGradingViewDto>>> GetPendingGrading(
            [FromQuery] int? instructorId = null,
            [FromQuery] int? examId = null,
            [FromQuery] int? studentId = null)
        {
            var result = await _viewsService.GetPendingGradingAsync(instructorId, examId, studentId);
            return Ok(result);
        }

        /// <summary>
        /// Get exam statistics from VW_ExamStatistics view
        /// </summary>
        [HttpGet("exam-statistics")]
        public async Task<ActionResult<IEnumerable<ExamStatisticsViewDto>>> GetExamStatistics(
            [FromQuery] int? examId = null,
            [FromQuery] int? courseId = null)
        {
            var result = await _viewsService.GetExamStatisticsAsync(examId, courseId);
            return Ok(result);
        }

        /// <summary>
        /// Get text answers analysis from VW_TextAnswersAnalysis view (BONUS FEATURE)
        /// Provides AI-like similarity scoring for text answers
        /// </summary>
        [HttpGet("text-analysis")]
        public async Task<ActionResult<IEnumerable<TextAnswersAnalysisViewDto>>> GetTextAnswersAnalysis(
            [FromQuery] int? examId = null,
            [FromQuery] int? studentId = null,
            [FromQuery] int? instructorId = null,
            [FromQuery] string? answerClassification = null,
            [FromQuery] bool? isPendingGrading = null)
        {
            var result = await _viewsService.GetTextAnswersAnalysisAsync(examId, studentId, instructorId, answerClassification, isPendingGrading);
            return Ok(result);
        }

        #endregion
    }
}
