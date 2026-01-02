using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/notifications")]
    [Authorize]
    public class NotificationController : ControllerBase
    {
        private readonly INotificationService _service;

        public NotificationController(INotificationService service)
        {
            _service = service;
        }

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        [HttpGet]
        public async Task<ActionResult<PagedNotificationsDto>> GetNotifications(
            [FromQuery] bool unreadOnly = false,
            [FromQuery(Name = "type")] string? notificationType = null,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 20)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize <= 0 || pageSize > 100) pageSize = 20;

            var result = await _service.GetUserNotificationsAsync(CurrentUserId, unreadOnly, notificationType, pageNumber, pageSize);
            return Ok(result);
        }

        [HttpGet("unread-count")]
        public async Task<ActionResult<UnreadCountDto>> GetUnreadCount()
        {
            var count = await _service.GetUnreadCountAsync(CurrentUserId);
            var dto = new UnreadCountDto { UnreadCount = count };
            return Ok(dto);
        }

        [HttpPost("{notificationId:int}/read")]
        public async Task<IActionResult> MarkAsRead([FromRoute] int notificationId)
        {
            await _service.MarkAsReadAsync(CurrentUserId, notificationId);
            return NoContent();
        }

        [HttpPost("read-all")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            await _service.MarkAllAsReadAsync(CurrentUserId);
            return NoContent();
        }

        [HttpDelete("{notificationId:int}")]
        public async Task<IActionResult> Delete([FromRoute] int notificationId)
        {
            await _service.DeleteNotificationAsync(CurrentUserId, notificationId);
            return NoContent();
        }
    }
}
