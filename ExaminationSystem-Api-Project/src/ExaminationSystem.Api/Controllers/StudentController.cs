using System.Security.Claims;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/student")]
    [Authorize(Roles = "Student")]
    public class StudentController : ControllerBase
    {
        private readonly IStudentService _service;
        public StudentController(IStudentService service)
        {
            _service = service;
        }

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        #region Dashboard
        [HttpGet("dashboard")]
        public async Task<ActionResult> GetDashboard()
        {
            var progress = await _service.GetStudentProgressAsync(CurrentUserId);
            var availableExams = await _service.GetAvailableExamsAsync(CurrentUserId);
            return Ok(new { progress, availableExams });
        }
        #endregion

        #region Courses
        [HttpGet("courses")]
        public async Task<ActionResult<IEnumerable<StudentCourseProgressDto>>> GetMyCourses()
        {
            var progress = await _service.GetStudentProgressAsync(CurrentUserId);
            return Ok(progress.Courses);
        }
        #endregion

        #region Exams
        [HttpGet("exams")]
        public async Task<ActionResult> GetExams()
        {
            var data = await _service.GetAvailableExamsAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpGet("available-exams")]
        public async Task<ActionResult> GetAvailableExams()
        {
            var data = await _service.GetAvailableExamsAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpGet("progress")]
        public async Task<ActionResult<StudentProgressDto>> GetProgress()
        {
            var data = await _service.GetStudentProgressAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpPost("exams/{examId:int}/start")]
        public async Task<IActionResult> StartExam([FromRoute] int examId)
        {
            await _service.StartExamAsync(CurrentUserId, examId);
            return NoContent();
        }

        [HttpGet("exams/{examId:int}")]
        public async Task<ActionResult<StudentExamWithQuestionsDto>> GetExam([FromRoute] int examId)
        {
            var data = await _service.GetExamWithQuestionsAsync(CurrentUserId, examId);
            return Ok(data);
            
        }

        public record SubmitAnswerRequest(int QuestionId, string? AnswerText, int? SelectedOptionId);
        public record SubmitAnswersRequest(List<SubmitAnswerRequest> Answers);

        [HttpPost("exams/{examId:int}/answers")]
        public async Task<IActionResult> SubmitAnswer([FromRoute] int examId, [FromBody] SubmitAnswerRequest req)
        {
            await _service.SubmitAnswerAsync(CurrentUserId, examId, req.QuestionId, req.AnswerText, req.SelectedOptionId);
            return NoContent();
        }

        [HttpPost("exams/{examId:int}/submit-answers")]
        public async Task<IActionResult> SubmitAnswers([FromRoute] int examId, [FromBody] SubmitAnswersRequest req)
        {
            // Submit all answers in batch
            foreach (var answer in req.Answers)
            {
                await _service.SubmitAnswerAsync(CurrentUserId, examId, answer.QuestionId, answer.AnswerText, answer.SelectedOptionId);
            }
            return NoContent();
        }

        [HttpPost("exams/{examId:int}/submit")]
        public async Task<IActionResult> SubmitExam([FromRoute] int examId)
        {
            await _service.SubmitExamAsync(CurrentUserId, examId);
            return NoContent();
        }

        [HttpGet("exams/{examId:int}/results")]
        public async Task<ActionResult<StudentExamResultsDto>> GetResults([FromRoute] int examId)
        {
            if (examId <= 0)
            {
                return BadRequest(new { message = "Invalid exam ID" });
            }
            var data = await _service.GetExamResultsAsync(CurrentUserId, examId);
            return Ok(data);
        }
        #endregion
    }
}
