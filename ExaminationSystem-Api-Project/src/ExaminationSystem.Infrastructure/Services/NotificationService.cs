using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class NotificationService : INotificationService
    {
        private readonly INotificationRepository _repo;

        public NotificationService(INotificationRepository repo)
        {
            _repo = repo;
        }

        public async Task<PagedNotificationsDto> GetUserNotificationsAsync(
            int userId,
            bool unreadOnly,
            string? notificationType,
            int pageNumber,
            int pageSize)
        {
            var (items, total) = await _repo.GetUserNotificationsAsync(userId, unreadOnly, notificationType, pageNumber, pageSize);
            return new PagedNotificationsDto
            {
                Items = new List<NotificationDto>(items),
                TotalCount = total
            };
        }

        public Task<int> GetUnreadCountAsync(int userId)
        {
            return _repo.GetUnreadCountAsync(userId);
        }

        public Task MarkAsReadAsync(int userId, int notificationId)
        {
            return _repo.MarkAsReadAsync(notificationId, null, false);
        }

        public Task MarkAllAsReadAsync(int userId)
        {
            return _repo.MarkAsReadAsync(null, userId, true);
        }

        public Task DeleteNotificationAsync(int userId, int notificationId)
        {
            return _repo.DeleteNotificationAsync(notificationId, userId);
        }
    }
}
