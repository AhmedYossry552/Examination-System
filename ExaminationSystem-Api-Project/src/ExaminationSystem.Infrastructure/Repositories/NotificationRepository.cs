using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class NotificationRepository : INotificationRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;

        public NotificationRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<(IReadOnlyList<NotificationDto> Items, int TotalCount)> GetUserNotificationsAsync(
            int userId,
            bool unreadOnly,
            string? notificationType,
            int pageNumber,
            int pageSize)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@UnreadOnly", unreadOnly);
            p.Add("@NotificationType", notificationType);
            p.Add("@PageNumber", pageNumber);
            p.Add("@PageSize", pageSize);

            using var multi = await conn.QueryMultipleAsync("Security.SP_GetUserNotifications", p, commandType: CommandType.StoredProcedure);
            var items = (await multi.ReadAsync<NotificationDto>()).AsList();
            var total = await multi.ReadSingleAsync<int>();
            return (items, total);
        }

        public async Task<int> GetUnreadCountAsync(int userId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@UnreadCount", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Security.SP_GetUnreadCount", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@UnreadCount");
        }

        public async Task MarkAsReadAsync(int? notificationId, int? userId, bool markAll)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@NotificationID", notificationId);
            p.Add("@UserID", userId);
            p.Add("@MarkAll", markAll);
            await conn.ExecuteAsync("Security.SP_MarkAsRead", p, commandType: CommandType.StoredProcedure);
        }

        public async Task DeleteNotificationAsync(int notificationId, int userId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@NotificationID", notificationId);
            p.Add("@UserID", userId);
            await conn.ExecuteAsync("Security.SP_DeleteNotification", p, commandType: CommandType.StoredProcedure);
        }
    }
}
