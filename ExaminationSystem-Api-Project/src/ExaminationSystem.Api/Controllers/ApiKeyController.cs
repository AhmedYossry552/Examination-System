using System.Security.Claims;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for API key management
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize(Roles = "Admin")]
    public class ApiKeyController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public ApiKeyController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        private int GetCurrentUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(claim, out var id) ? id : 0;
        }

        /// <summary>
        /// Get all API keys
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var keys = await _service.GetAllApiKeysAsync();
            return Ok(keys);
        }

        /// <summary>
        /// Create a new API key
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateApiKeyDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid API key data" });

            var userId = GetCurrentUserId();
            var result = await _service.CreateApiKeyAsync(userId, dto);
            return Ok(result);
        }

        /// <summary>
        /// Revoke an API key
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> Revoke(int id)
        {
            await _service.RevokeApiKeyAsync(id);
            return Ok(new { message = "API key revoked" });
        }

        /// <summary>
        /// Reset rate limit for an API key
        /// </summary>
        [HttpPost("{id}/reset-rate-limit")]
        public async Task<IActionResult> ResetRateLimit(int id)
        {
            await _service.ResetApiKeyRateLimitAsync(id);
            return Ok(new { message = "Rate limit reset" });
        }

        /// <summary>
        /// Get API usage statistics
        /// </summary>
        [HttpGet("usage-statistics")]
        public async Task<IActionResult> GetUsageStatistics()
        {
            var stats = await _service.GetApiUsageStatisticsAsync();
            return Ok(stats);
        }
    }
}
