using System;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/admin")]
    [Authorize(Roles = "Admin")]
    public class AdminController : ControllerBase
    {
        private readonly IAdminService _service;
        public AdminController(IAdminService service)
        {
            _service = service;
        }

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        #region Users
        [HttpGet("users")]
        public async Task<ActionResult> ListUsers()
        {
            var list = await _service.ListUsersAsync(CurrentUserId);
            return Ok(list);
        }

        [HttpGet("users/{userId:int}")]
        public async Task<ActionResult> GetUserById([FromRoute] int userId)
        {
            var user = await _service.GetUserByIdAsync(userId);
            if (user == null)
                return NotFound(new { message = "User not found" });
            return Ok(user);
        }

        [HttpPost("users")]
        public async Task<ActionResult<int>> CreateUser([FromBody] CreateUserDto dto)
        {
            var id = await _service.CreateUserAsync(CurrentUserId, dto);
            return Ok(id);
        }

        [HttpPut("users/{userId:int}")]
        public async Task<IActionResult> UpdateUser([FromRoute] int userId, [FromBody] UpdateUserDto dto)
        {
            await _service.UpdateUserAsync(CurrentUserId, userId, dto);
            return NoContent();
        }

        [HttpPost("users/{userId:int}/toggle-status")]
        public async Task<IActionResult> ToggleUserStatus([FromRoute] int userId)
        {
            await _service.ToggleUserStatusAsync(CurrentUserId, userId);
            return Ok(new { message = "User status toggled successfully" });
        }

        [HttpDelete("users/{userId:int}")]
        public async Task<IActionResult> DeleteUser([FromRoute] int userId)
        {
            await _service.DeleteUserAsync(CurrentUserId, userId);
            return NoContent();
        }

        public record ResetPasswordRequest(string NewPassword);

        [HttpPost("users/{userId:int}/reset-password")]
        public async Task<IActionResult> ResetPassword([FromRoute] int userId, [FromBody] ResetPasswordRequest req)
        {
            await _service.ResetPasswordAsync(CurrentUserId, userId, req.NewPassword);
            return NoContent();
        }
        #endregion

        #region Audit Logs
        [HttpGet("audit-logs")]
        public async Task<ActionResult<IEnumerable<AuditLogDto>>> GetAuditLogs(
            [FromQuery] string? action = null,
            [FromQuery] string? status = null,
            [FromQuery] DateTime? dateFrom = null,
            [FromQuery] DateTime? dateTo = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 100)
        {
            var logs = await _service.GetAuditLogsAsync(action, status, dateFrom, dateTo, page, pageSize);
            return Ok(logs);
        }
        #endregion

        #region System Settings
        // TODO: Persist system settings to database instead of static variable
        // Currently settings are lost on application restart
        public record SystemSettingsDto
        {
            public string SiteName { get; init; } = "Examination System";
            public string SiteDescription { get; init; } = "Online Examination Platform";
            public bool MaintenanceMode { get; init; } = false;
            public bool AllowRegistration { get; init; } = true;
            public string DefaultLanguage { get; init; } = "en";
            public string Timezone { get; init; } = "UTC";
            public int SessionTimeout { get; init; } = 30;
            public int MaxLoginAttempts { get; init; } = 5;
            public int PasswordMinLength { get; init; } = 8;
            public bool RequireUppercase { get; init; } = true;
            public bool RequireNumbers { get; init; } = true;
            public bool RequireSpecialChars { get; init; } = true;
            public bool EmailNotifications { get; init; } = true;
            public bool SmsNotifications { get; init; } = false;
            public int ExamReminderHours { get; init; } = 24;
            public bool ResultNotification { get; init; } = true;
            public bool AutoGradeMultipleChoice { get; init; } = true;
            public bool ShowCorrectAnswers { get; init; } = true;
            public bool AllowExamRetake { get; init; } = false;
            public int MaxRetakeAttempts { get; init; } = 1;
            public int PassingPercentage { get; init; } = 60;
        }

        private static SystemSettingsDto _settings = new();

        [HttpGet("settings")]
        public ActionResult<SystemSettingsDto> GetSettings()
        {
            return Ok(_settings);
        }

        [HttpPut("settings")]
        public ActionResult UpdateSettings([FromBody] SystemSettingsDto settings)
        {
            _settings = settings;
            return NoContent();
        }
        #endregion
    }
}
