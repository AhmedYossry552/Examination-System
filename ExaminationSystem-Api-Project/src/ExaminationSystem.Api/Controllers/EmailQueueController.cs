using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for email queue management
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize(Roles = "Admin")]
    public class EmailQueueController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public EmailQueueController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        /// <summary>
        /// Get email queue status
        /// </summary>
        [HttpGet("status")]
        public async Task<IActionResult> GetStatus()
        {
            var status = await _service.GetEmailQueueStatusAsync();
            return Ok(status);
        }

        /// <summary>
        /// Get pending emails in queue
        /// </summary>
        [HttpGet("pending")]
        public async Task<IActionResult> GetPendingEmails()
        {
            var emails = await _service.GetPendingEmailsAsync();
            return Ok(emails);
        }

        /// <summary>
        /// Schedule an email
        /// </summary>
        [HttpPost("schedule")]
        public async Task<IActionResult> ScheduleEmail([FromBody] ScheduleEmailDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid email data" });

            await _service.ScheduleEmailAsync(dto);
            return Ok(new { message = "Email scheduled successfully" });
        }

        /// <summary>
        /// Process the email queue (send pending emails)
        /// </summary>
        [HttpPost("process")]
        public async Task<IActionResult> ProcessQueue()
        {
            await _service.ProcessEmailQueueAsync();
            return Ok(new { message = "Email queue processed" });
        }

        /// <summary>
        /// Retry failed emails
        /// </summary>
        [HttpPost("retry-failed")]
        public async Task<IActionResult> RetryFailed()
        {
            await _service.RetryFailedEmailsAsync();
            return Ok(new { message = "Failed emails queued for retry" });
        }
    }
}
