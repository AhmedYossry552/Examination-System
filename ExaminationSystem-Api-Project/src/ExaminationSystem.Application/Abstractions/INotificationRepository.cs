using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface INotificationRepository
    {
        Task<(IReadOnlyList<NotificationDto> Items, int TotalCount)> GetUserNotificationsAsync(
            int userId,
            bool unreadOnly,
            string? notificationType,
            int pageNumber,
            int pageSize);

        Task<int> GetUnreadCountAsync(int userId);

        Task MarkAsReadAsync(int? notificationId, int? userId, bool markAll);

        Task DeleteNotificationAsync(int notificationId, int userId);
    }
}
