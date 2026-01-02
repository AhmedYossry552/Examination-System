using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface ISessionService
    {
        Task<IEnumerable<ActiveSessionDto>> GetActiveSessionsForUserAsync(int userId);
        Task EndSessionAsync(string sessionToken);
        Task EndAllUserSessionsAsync(int userId);
        Task<IEnumerable<SessionHistoryDto>> GetSessionHistoryAsync(int? userId, int daysBack);
        Task CleanupExpiredSessionsAsync();
    }
}
