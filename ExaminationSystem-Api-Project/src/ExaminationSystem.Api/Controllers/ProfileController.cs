using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/profile")]
    [Authorize]
    public class ProfileController : ControllerBase
    {
        private readonly IProfileService _service;
        public ProfileController(IProfileService service)
        {
            _service = service;
        }

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpGet("me")]
        public async Task<ActionResult<ProfileDto>> GetMe()
        {
            var data = await _service.GetProfileAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpPut("me")]
        public async Task<IActionResult> UpdateMe([FromBody] ProfileUpdateDto dto)
        {
            await _service.UpdateProfileAsync(CurrentUserId, dto);
            return NoContent();
        }

        public record ChangePasswordRequest(string OldPassword, string NewPassword);

        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest req)
        {
            await _service.ChangePasswordAsync(CurrentUserId, req.OldPassword, req.NewPassword);
            return NoContent();
        }
    }
}
