using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for email management operations
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize(Roles = "Admin")]
    public class EmailManagementController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public EmailManagementController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        /// <summary>
        /// Send welcome email to a user
        /// </summary>
        [HttpPost("welcome")]
        public async Task<IActionResult> SendWelcomeEmail([FromBody] SendWelcomeEmailDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid data" });

            await _service.SendWelcomeEmailAsync(dto);
            return Ok(new { message = "Welcome email queued" });
        }

        /// <summary>
        /// Send password reset email
        /// </summary>
        [HttpPost("password-reset")]
        public async Task<IActionResult> SendPasswordResetEmail([FromBody] SendPasswordResetEmailDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid data" });

            await _service.SendPasswordResetEmailAsync(dto);
            return Ok(new { message = "Password reset email queued" });
        }

        /// <summary>
        /// Send exam reminder email
        /// </summary>
        [HttpPost("exam-reminder")]
        public async Task<IActionResult> SendExamReminderEmail([FromBody] SendExamReminderEmailDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid data" });

            await _service.SendExamReminderEmailAsync(dto);
            return Ok(new { message = "Exam reminder email queued" });
        }

        /// <summary>
        /// Send grade notification email
        /// </summary>
        [HttpPost("grade-notification")]
        public async Task<IActionResult> SendGradeEmail([FromBody] SendGradeEmailDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid data" });

            await _service.SendGradeEmailAsync(dto);
            return Ok(new { message = "Grade email queued" });
        }

        /// <summary>
        /// Mark email as sent
        /// </summary>
        [HttpPost("{emailId}/mark-sent")]
        public async Task<IActionResult> MarkAsSent(int emailId)
        {
            await _service.MarkEmailAsSentAsync(emailId);
            return Ok(new { message = "Email marked as sent" });
        }

        /// <summary>
        /// Mark email as failed
        /// </summary>
        [HttpPost("{emailId}/mark-failed")]
        public async Task<IActionResult> MarkAsFailed(int emailId, [FromBody] MarkEmailFailedRequest request)
        {
            await _service.MarkEmailAsFailedAsync(emailId, request?.Error ?? "Unknown error");
            return Ok(new { message = "Email marked as failed" });
        }

        /// <summary>
        /// Notify user of password reset
        /// </summary>
        [HttpPost("notify-password-reset/{userId}")]
        public async Task<IActionResult> NotifyPasswordReset(int userId)
        {
            await _service.NotifyPasswordResetAsync(userId);
            return Ok(new { message = "Password reset notification sent" });
        }

        /// <summary>
        /// Schedule an email for future sending
        /// </summary>
        [HttpPost("schedule")]
        public async Task<IActionResult> ScheduleEmail([FromBody] ScheduleEmailDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid data" });

            await _service.ScheduleEmailAsync(dto);
            return Ok(new { message = "Email scheduled successfully" });
        }
    }

    public class MarkEmailFailedRequest
    {
        public string Error { get; set; } = string.Empty;
    }
}
