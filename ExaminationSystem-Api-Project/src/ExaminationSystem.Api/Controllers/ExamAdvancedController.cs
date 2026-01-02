using System.Security.Claims;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for advanced exam operations
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ExamAdvancedController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public ExamAdvancedController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        private int GetCurrentUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : 0;
        }

        /// <summary>
        /// Bulk assign students to an exam
        /// </summary>
        [HttpPost("bulk-assign")]
        [Authorize(Roles = "Admin,Manager,Instructor")]
        public async Task<IActionResult> BulkAssignStudents([FromBody] BulkAssignStudentsDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid data" });

            await _service.BulkAssignStudentsToExamAsync(dto);
            return Ok(new { message = $"{dto.StudentIDs.Count} students assigned to exam" });
        }

        /// <summary>
        /// Get exam questions
        /// </summary>
        [HttpGet("{examId}/questions")]
        public async Task<IActionResult> GetExamQuestions(int examId)
        {
            var questions = await _service.GetExamQuestionsAsync(examId);
            return Ok(questions);
        }

        /// <summary>
        /// Get random questions by type
        /// </summary>
        [HttpPost("random-questions")]
        [Authorize(Roles = "Admin,Manager,Instructor")]
        public async Task<IActionResult> GetRandomQuestions([FromBody] RandomQuestionDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid data" });

            var questions = await _service.GetRandomQuestionsByTypeAsync(dto);
            return Ok(questions);
        }

        /// <summary>
        /// Get student exam results
        /// </summary>
        [HttpGet("students/{studentId}/results")]
        public async Task<IActionResult> GetStudentResults(int studentId)
        {
            // Check if user can access this data
            var currentUserId = GetCurrentUserId();
            var isAdmin = User.IsInRole("Admin") || User.IsInRole("Manager") || User.IsInRole("Instructor");
            
            if (!isAdmin && currentUserId != studentId)
                return Forbid();

            var results = await _service.GetStudentExamResultsAsync(studentId);
            return Ok(results);
        }

        /// <summary>
        /// Get current user's exam results
        /// </summary>
        [HttpGet("my-results")]
        public async Task<IActionResult> GetMyResults()
        {
            var userId = GetCurrentUserId();
            var results = await _service.GetStudentExamResultsAsync(userId);
            return Ok(results);
        }

        /// <summary>
        /// Send exam reminder
        /// </summary>
        [HttpPost("{examId}/send-reminder")]
        [Authorize(Roles = "Admin,Manager,Instructor")]
        public async Task<IActionResult> SendExamReminder(int examId)
        {
            await _service.NotifyExamReminderAsync(examId);
            return Ok(new { message = "Exam reminder sent" });
        }

        /// <summary>
        /// Notify student of exam assignment
        /// </summary>
        [HttpPost("{examId}/notify-assigned/{studentId}")]
        [Authorize(Roles = "Admin,Manager,Instructor")]
        public async Task<IActionResult> NotifyExamAssigned(int examId, int studentId)
        {
            await _service.NotifyExamAssignedAsync(examId, studentId);
            return Ok(new { message = "Student notified" });
        }

        /// <summary>
        /// Notify student of grade release
        /// </summary>
        [HttpPost("{examId}/notify-grade/{studentId}")]
        [Authorize(Roles = "Admin,Manager,Instructor")]
        public async Task<IActionResult> NotifyGradeReleased(int examId, int studentId)
        {
            await _service.NotifyGradeReleasedAsync(examId, studentId);
            return Ok(new { message = "Grade notification sent" });
        }
    }
}
