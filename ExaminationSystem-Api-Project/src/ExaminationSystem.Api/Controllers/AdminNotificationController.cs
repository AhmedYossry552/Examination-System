using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for admin notification management
    /// </summary>
    [ApiController]
    [Route("api/v1/admin/notifications")]
    [Authorize(Roles = "Admin,Manager")]
    public class AdminNotificationController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public AdminNotificationController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        /// <summary>
        /// Create a notification for a specific user
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateNotificationDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid notification data" });

            await _service.CreateNotificationAsync(dto);
            return Ok(new { message = "Notification created" });
        }

        /// <summary>
        /// Send bulk notifications to multiple users
        /// </summary>
        [HttpPost("bulk")]
        public async Task<IActionResult> SendBulk([FromBody] BulkNotificationDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid notification data" });

            await _service.SendBulkNotificationsAsync(dto);
            return Ok(new { message = "Bulk notifications sent" });
        }
    }
}
