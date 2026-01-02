using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/instructor")]
    [Authorize(Roles = "Instructor,TrainingManager")]
    public class InstructorController : ControllerBase
    {
        private readonly IInstructorService _service;
        private readonly IAnalyticsService _analyticsService;
        public InstructorController(IInstructorService service, IAnalyticsService analyticsService)
        {
            _service = service;
            _analyticsService = analyticsService;
        }

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        // Dashboard
        [HttpGet("dashboard")]
        public async Task<ActionResult<InstructorDashboardDto>> GetDashboard()
        {
            var data = await _service.GetDashboardAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpGet("courses")]
        [HttpGet("my-courses")]
        public async Task<ActionResult<IEnumerable<CourseDto>>> GetMyCourses()
        {
            var data = await _service.GetMyCoursesAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpGet("courses/{courseId:int}/students")]
        public async Task<ActionResult<IEnumerable<CourseStudentDto>>> GetCourseStudents([FromRoute] int courseId)
        {
            var data = await _service.GetCourseStudentsAsync(CurrentUserId, courseId);
            return Ok(data);
        }

        // Exams CRUD
        [HttpGet("exams")]
        public async Task<ActionResult<IEnumerable<ExamLiteDto>>> GetExams()
        {
            var data = await _service.GetMyExamsAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpGet("exams/{examId:int}")]
        public async Task<ActionResult<ExamDetailDto>> GetExamById([FromRoute] int examId)
        {
            var data = await _service.GetExamByIdAsync(CurrentUserId, examId);
            if (data == null) return NotFound();
            return Ok(data);
        }

        [HttpPost("exams")]
        public async Task<ActionResult<int>> CreateExam([FromBody] CreateExamDto dto)
        {
            var examId = await _service.CreateExamAsync(CurrentUserId, dto);
            return Ok(examId);
        }

        [HttpPut("exams/{examId:int}")]
        public async Task<IActionResult> UpdateExam([FromRoute] int examId, [FromBody] CreateExamDto dto)
        {
            await _service.UpdateExamAsync(CurrentUserId, examId, dto);
            return NoContent();
        }

        [HttpDelete("exams/{examId:int}")]
        public async Task<IActionResult> DeleteExam([FromRoute] int examId)
        {
            await _service.DeleteExamAsync(CurrentUserId, examId);
            return NoContent();
        }

        public record AddQuestionRequest(int QuestionId, int Order, int Marks);

        [HttpPost("exams/{examId:int}/questions")]
        public async Task<IActionResult> AddQuestion([FromRoute] int examId, [FromBody] AddQuestionRequest req)
        {
            await _service.AddQuestionAsync(CurrentUserId, examId, req.QuestionId, req.Order, req.Marks);
            return NoContent();
        }

        [HttpPost("exams/{examId:int}/generate-random")]
        public async Task<IActionResult> GenerateRandom([FromRoute] int examId, [FromBody] GenerateRandomDto dto)
        {
            await _service.GenerateRandomAsync(CurrentUserId, examId, dto);
            return NoContent();
        }

        public record AssignStudentsRequest(IEnumerable<int> StudentIds);

        [HttpPost("exams/{examId:int}/assign-students")]
        public async Task<IActionResult> AssignStudents([FromRoute] int examId, [FromBody] AssignStudentsRequest req)
        {
            await _service.AssignToStudentsAsync(CurrentUserId, examId, req.StudentIds?.ToList() ?? new List<int>());
            return NoContent();
        }

        [HttpPost("exams/{examId:int}/assign-all")]
        public async Task<IActionResult> AssignAll([FromRoute] int examId)
        {
            await _service.AssignToAllCourseStudentsAsync(CurrentUserId, examId);
            return NoContent();
        }

        [HttpGet("grading/pending")]
        public async Task<ActionResult<IEnumerable<ExamToGradeDto>>> GetExamsToGrade()
        {
            var data = await _service.GetExamsToGradeAsync(CurrentUserId);
            return Ok(data);
        }

        public record GradeAnswerRequest(decimal MarksObtained, string? Comments);

        [HttpPost("grading/answers/{studentAnswerId:int}")]
        public async Task<IActionResult> GradeAnswer([FromRoute] int studentAnswerId, [FromBody] GradeAnswerRequest req)
        {
            await _service.GradeTextAnswerAsync(CurrentUserId, studentAnswerId, req.MarksObtained, req.Comments);
            return NoContent();
        }

        [HttpGet("exams/{examId:int}/statistics")]
        public async Task<ActionResult<ExamStatisticsDto>> GetExamStatistics([FromRoute] int examId)
        {
            var data = await _service.GetExamStatisticsAsync(CurrentUserId, examId);
            return Ok(data);
        }

        [HttpGet("exams/{examId:int}/report")]
        public async Task<ActionResult<InstructorExamReportDto>> GetExamReport([FromRoute] int examId)
        {
            var report = await _service.GetInstructorExamReportAsync(CurrentUserId, examId);
            return Ok(report);
        }

        // Question Pool Endpoints
        [HttpGet("questions")]
        public async Task<ActionResult<IEnumerable<QuestionDto>>> GetQuestions()
        {
            var data = await _service.GetAllQuestionsAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpPost("questions")]
        public async Task<ActionResult<int>> AddQuestion([FromBody] CreateQuestionDto dto)
        {
            var questionId = await _service.AddQuestionAsync(CurrentUserId, dto);
            return Ok(questionId);
        }

        [HttpPut("questions/{questionId:int}")]
        public async Task<IActionResult> UpdateQuestion([FromRoute] int questionId, [FromBody] UpdateQuestionDto dto)
        {
            await _service.UpdateQuestionAsync(CurrentUserId, questionId, dto);
            return NoContent();
        }

        [HttpDelete("questions/{questionId:int}")]
        public async Task<IActionResult> DeleteQuestion([FromRoute] int questionId)
        {
            await _service.DeleteQuestionAsync(CurrentUserId, questionId);
            return NoContent();
        }

        [HttpGet("courses/{courseId:int}/questions")]
        public async Task<ActionResult<IEnumerable<QuestionDto>>> GetQuestionsByCourse(
            [FromRoute] int courseId,
            [FromQuery] string? questionType = null,
            [FromQuery] string? difficultyLevel = null)
        {
            var questions = await _service.GetQuestionsByCourseAsync(CurrentUserId, courseId, questionType, difficultyLevel);
            return Ok(questions);
        }

        [HttpGet("questions/{questionId:int}/with-options")]
        public async Task<ActionResult<QuestionWithOptionsDto>> GetQuestionWithOptions([FromRoute] int questionId)
        {
            var question = await _service.GetQuestionWithOptionsAsync(CurrentUserId, questionId);
            if (question == null) return NotFound();
            return Ok(question);
        }

        [HttpPost("questions/{questionId:int}/options")]
        public async Task<ActionResult<int>> AddQuestionOption([FromRoute] int questionId, [FromBody] CreateQuestionOptionDto dto)
        {
            var optionId = await _service.AddQuestionOptionAsync(CurrentUserId, questionId, dto);
            return Ok(optionId);
        }

        [HttpPost("questions/{questionId:int}/answer")]
        public async Task<ActionResult<int>> AddQuestionAnswer([FromRoute] int questionId, [FromBody] CreateQuestionAnswerDto dto)
        {
            var answerId = await _service.AddQuestionAnswerAsync(CurrentUserId, questionId, dto);
            return Ok(answerId);
        }

        [HttpGet("courses/{courseId:int}/questions/statistics")]
        public async Task<ActionResult<QuestionPoolStatisticsDto>> GetQuestionPoolStatistics([FromRoute] int courseId)
        {
            var statistics = await _service.GetQuestionPoolStatisticsAsync(CurrentUserId, courseId);
            return Ok(statistics);
        }

        [HttpGet("text-answers/analysis")]
        public async Task<ActionResult<IEnumerable<TextAnswerAnalysisDto>>> GetTextAnswersAnalysis([FromQuery] int? examId = null)
        {
            var analysis = await _service.GetTextAnswersAnalysisAsync(CurrentUserId, examId);
            return Ok(analysis);
        }

        /// <summary>
        /// Get calculated difficulty analysis for questions based on student performance
        /// </summary>
        [HttpGet("questions/difficulty-analysis")]
        public async Task<ActionResult<IEnumerable<QuestionDifficultyAnalysisDto>>> GetQuestionDifficultyAnalysis(
            [FromQuery] int? questionId = null, 
            [FromQuery] int? courseId = null)
        {
            var analysis = await _analyticsService.AnalyzeQuestionDifficultyAsync(questionId, courseId);
            return Ok(analysis);
        }
    }
}
