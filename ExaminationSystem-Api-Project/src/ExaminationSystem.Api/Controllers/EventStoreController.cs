using System.Security.Claims;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for event sourcing and audit trail
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class EventStoreController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public EventStoreController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        private int GetCurrentUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : 0;
        }

        /// <summary>
        /// Append a new event
        /// </summary>
        [HttpPost("events")]
        public async Task<IActionResult> AppendEvent([FromBody] AppendEventDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid event data" });

            var userId = GetCurrentUserId();
            await _service.AppendEventAsync(userId, dto);
            return Ok(new { message = "Event appended successfully" });
        }

        /// <summary>
        /// Get events for a specific aggregate
        /// </summary>
        [HttpGet("events/{aggregateType}/{aggregateId}")]
        public async Task<IActionResult> GetAggregateEvents(string aggregateType, int aggregateId)
        {
            var events = await _service.GetAggregateEventsAsync(aggregateType, aggregateId);
            return Ok(events);
        }

        /// <summary>
        /// Get timeline for current user
        /// </summary>
        [HttpGet("timeline")]
        public async Task<IActionResult> GetUserTimeline()
        {
            var userId = GetCurrentUserId();
            var events = await _service.GetUserTimelineAsync(userId);
            return Ok(events);
        }

        /// <summary>
        /// Get timeline for a specific user (admin only)
        /// </summary>
        [HttpGet("timeline/{userId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetUserTimeline(int userId)
        {
            var events = await _service.GetUserTimelineAsync(userId);
            return Ok(events);
        }

        /// <summary>
        /// Get system activity for the last N days
        /// </summary>
        [HttpGet("activity")]
        [Authorize(Roles = "Admin,Manager")]
        public async Task<IActionResult> GetSystemActivity([FromQuery] int days = 7)
        {
            var activity = await _service.GetSystemActivityAsync(days);
            return Ok(activity);
        }

        /// <summary>
        /// Get event statistics
        /// </summary>
        [HttpGet("statistics")]
        [Authorize(Roles = "Admin,Manager")]
        public async Task<IActionResult> GetStatistics()
        {
            var stats = await _service.GetEventStatisticsAsync();
            return Ok(stats);
        }
    }
}
