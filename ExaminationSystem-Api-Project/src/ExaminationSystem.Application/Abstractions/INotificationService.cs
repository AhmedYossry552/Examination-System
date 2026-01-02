using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface INotificationService
    {
        Task<PagedNotificationsDto> GetUserNotificationsAsync(
            int userId,
            bool unreadOnly,
            string? notificationType,
            int pageNumber,
            int pageSize);

        Task<int> GetUnreadCountAsync(int userId);

        Task MarkAsReadAsync(int userId, int notificationId);

        Task MarkAllAsReadAsync(int userId);

        Task DeleteNotificationAsync(int userId, int notificationId);
    }
}
