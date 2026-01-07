using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for system administration
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize(Roles = "Admin")]
    public class SystemAdminController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public SystemAdminController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        /// <summary>
        /// Get system statistics
        /// </summary>
        [HttpGet("statistics")]
        public async Task<IActionResult> GetStatistics()
        {
            var stats = await _service.GetSystemStatisticsAsync();
            return Ok(stats);
        }

        /// <summary>
        /// Get user refresh tokens
        /// </summary>
        [HttpGet("users/{userId}/tokens")]
        public async Task<IActionResult> GetUserTokens(int userId)
        {
            var tokens = await _service.GetUserRefreshTokensAsync(userId);
            return Ok(tokens);
        }

        /// <summary>
        /// Validate a session
        /// </summary>
        [HttpGet("sessions/{sessionId}/validate")]
        public async Task<IActionResult> ValidateSession(int sessionId)
        {
            var result = await _service.ValidateSessionAsync(sessionId);
            return Ok(result);
        }

        /// <summary>
        /// Refresh/extend a session
        /// </summary>
        [HttpPost("sessions/refresh")]
        public async Task<IActionResult> RefreshSession([FromBody] RefreshSessionDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid session data" });

            await _service.RefreshSessionAsync(dto);
            return Ok(new { message = "Session refreshed successfully" });
        }

        /// <summary>
        /// Validate an API key
        /// </summary>
        [HttpGet("apikeys/validate")]
        public async Task<IActionResult> ValidateApiKey([FromQuery] string key)
        {
            if (string.IsNullOrWhiteSpace(key))
                return BadRequest(new { message = "API key is required" });

            var isValid = await _service.ValidateApiKeyAsync(key);
            return Ok(new { isValid });
        }

        /// <summary>
        /// Log an API request (for internal use)
        /// </summary>
        [HttpPost("api-log")]
        public async Task<IActionResult> LogApiRequest([FromBody] LogApiRequestDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid log data" });

            await _service.LogApiRequestAsync(dto);
            return Ok(new { message = "Request logged" });
        }

        /// <summary>
        /// Archive old events
        /// </summary>
        [HttpPost("events/archive")]
        public async Task<IActionResult> ArchiveEvents([FromQuery] int daysOld = 90)
        {
            await _service.ArchiveOldEventsAsync(daysOld);
            return Ok(new { message = $"Events older than {daysOld} days archived" });
        }

        /// <summary>
        /// Create a snapshot
        /// </summary>
        [HttpPost("snapshots")]
        public async Task<IActionResult> CreateSnapshot([FromBody] CreateSnapshotDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid snapshot data" });

            await _service.CreateSnapshotAsync(dto);
            return Ok(new { message = "Snapshot created" });
        }

        /// <summary>
        /// Get correlated events
        /// </summary>
        [HttpGet("events/correlated/{correlationId}")]
        public async Task<IActionResult> GetCorrelatedEvents(string correlationId)
        {
            var events = await _service.GetCorrelatedEventsAsync(correlationId);
            return Ok(events);
        }
    }
}
