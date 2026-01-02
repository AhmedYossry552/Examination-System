using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _auth;

        public AuthController(IAuthService auth)
        {
            _auth = auth;
        }

        public record LoginRequest(string Username, string Password);
        public record RefreshRequest(string RefreshToken);
        public record LogoutRequest(string RefreshToken);
        public record ForgotPasswordRequest(string Email);
        public record ResetPasswordRequest(string Token, string NewPassword);

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<ActionResult<LoginResult>> Login([FromBody] LoginRequest req)
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
            var userAgent = Request.Headers.UserAgent.ToString();
            var result = await _auth.LoginAsync(req.Username, req.Password, ip, userAgent);
            return Ok(result);
        }

        [HttpPost("refresh")]
        [AllowAnonymous]
        public async Task<ActionResult<RefreshResult>> Refresh([FromBody] RefreshRequest req)
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
            var userAgent = Request.Headers.UserAgent.ToString();
            var result = await _auth.RefreshAsync(req.RefreshToken, ip, userAgent);
            return Ok(result);
        }

        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout([FromBody] LogoutRequest req)
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
            await _auth.LogoutAsync(req.RefreshToken, ip);
            return NoContent();
        }

        [HttpPost("forgot-password")]
        [AllowAnonymous]
        public ActionResult ForgotPassword([FromBody] ForgotPasswordRequest req)
        {
            // In production, this would send an email with reset token
            // For now, return success to prevent email enumeration attacks
            return Ok(new { message = "If an account with that email exists, a password reset link has been sent." });
        }

        [HttpPost("reset-password")]
        [AllowAnonymous]
        public ActionResult ResetPassword([FromBody] ResetPasswordRequest req)
        {
            // In production, validate token and reset password
            if (string.IsNullOrEmpty(req.Token) || string.IsNullOrEmpty(req.NewPassword))
            {
                return BadRequest(new { message = "Token and new password are required." });
            }
            return Ok(new { message = "Password has been reset successfully." });
        }
    }
}
