using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/sessions")]
    [Authorize]
    public class SessionController : ControllerBase
    {
        private readonly ISessionService _service;

        public SessionController(ISessionService service)
        {
            _service = service;
        }

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        // ----- Self-management endpoints -----

        [HttpGet("me/active")]
        public async Task<ActionResult<IEnumerable<ActiveSessionDto>>> GetMyActiveSessions()
        {
            var result = await _service.GetActiveSessionsForUserAsync(CurrentUserId);
            return Ok(result);
        }

        [HttpDelete("me/{sessionToken}")]
        public async Task<IActionResult> EndMySession([FromRoute] string sessionToken)
        {
            await _service.EndSessionAsync(sessionToken);
            return NoContent();
        }

        [HttpDelete("me")]
        public async Task<IActionResult> EndAllMySessions()
        {
            await _service.EndAllUserSessionsAsync(CurrentUserId);
            return NoContent();
        }

        // ----- Admin/Manager endpoints -----

        [HttpGet("users/{userId:int}/active")]
        [Authorize(Roles = "Admin,TrainingManager")]
        public async Task<ActionResult<IEnumerable<ActiveSessionDto>>> GetUserActiveSessions([FromRoute] int userId)
        {
            var result = await _service.GetActiveSessionsForUserAsync(userId);
            return Ok(result);
        }

        [HttpDelete("users/{userId:int}")]
        [Authorize(Roles = "Admin,TrainingManager")]
        public async Task<IActionResult> EndAllUserSessions([FromRoute] int userId)
        {
            await _service.EndAllUserSessionsAsync(userId);
            return NoContent();
        }

        [HttpGet("history")]
        [Authorize(Roles = "Admin,TrainingManager")]
        public async Task<ActionResult<IEnumerable<SessionHistoryDto>>> GetSessionHistory(
            [FromQuery] int? userId = null,
            [FromQuery] int daysBack = 30)
        {
            var result = await _service.GetSessionHistoryAsync(userId, daysBack);
            return Ok(result);
        }

        [HttpPost("cleanup")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CleanupExpiredSessions()
        {
            await _service.CleanupExpiredSessionsAsync();
            return NoContent();
        }
    }
}
