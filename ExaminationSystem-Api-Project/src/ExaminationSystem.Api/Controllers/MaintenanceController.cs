using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for system maintenance and cleanup jobs
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class MaintenanceController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public MaintenanceController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        /// <summary>
        /// Cleanup expired refresh tokens
        /// </summary>
        [HttpPost("cleanup/refresh-tokens")]
        public async Task<IActionResult> CleanupRefreshTokens()
        {
            await _service.CleanupExpiredRefreshTokensAsync();
            return Ok(new { message = "Expired refresh tokens cleaned up" });
        }

        /// <summary>
        /// Cleanup expired sessions
        /// </summary>
        [HttpPost("cleanup/sessions")]
        public async Task<IActionResult> CleanupSessions()
        {
            await _service.CleanupExpiredSessionsAsync();
            return Ok(new { message = "Expired sessions cleaned up" });
        }

        /// <summary>
        /// Cleanup old notifications
        /// </summary>
        [HttpPost("cleanup/notifications")]
        public async Task<IActionResult> CleanupNotifications([FromQuery] int daysOld = 30)
        {
            await _service.CleanupOldNotificationsAsync(daysOld);
            return Ok(new { message = $"Notifications older than {daysOld} days cleaned up" });
        }

        /// <summary>
        /// Cleanup sent emails
        /// </summary>
        [HttpPost("cleanup/emails")]
        public async Task<IActionResult> CleanupEmails([FromQuery] int daysOld = 30)
        {
            await _service.CleanupSentEmailsAsync(daysOld);
            return Ok(new { message = $"Sent emails older than {daysOld} days cleaned up" });
        }

        /// <summary>
        /// Run all cleanup jobs
        /// </summary>
        [HttpPost("cleanup/all")]
        public async Task<IActionResult> CleanupAll([FromQuery] int daysOld = 30)
        {
            await _service.CleanupExpiredRefreshTokensAsync();
            await _service.CleanupExpiredSessionsAsync();
            await _service.CleanupOldNotificationsAsync(daysOld);
            await _service.CleanupSentEmailsAsync(daysOld);
            
            return Ok(new { message = "All cleanup jobs completed" });
        }
    }
}
