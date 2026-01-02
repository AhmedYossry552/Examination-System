using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class SessionService : ISessionService
    {
        private readonly ISessionRepository _repo;
        private readonly IExamMonitorNotifier? _notifier;

        public SessionService(ISessionRepository repo, IExamMonitorNotifier? notifier = null)
        {
            _repo = repo;
            _notifier = notifier;
        }

        public Task<IEnumerable<ActiveSessionDto>> GetActiveSessionsForUserAsync(int userId)
        {
            return _repo.GetActiveSessionsAsync(userId);
        }

        public Task EndSessionAsync(string sessionToken)
        {
            var task = _repo.EndSessionAsync(sessionToken);
            if (_notifier != null)
            {
                task = task.ContinueWith(async _ =>
                {
                    await _notifier.NotifyAsync("sessionEnded", new { sessionToken });
                }).Unwrap();
            }
            return task;
        }

        public Task EndAllUserSessionsAsync(int userId)
        {
            var task = _repo.EndAllUserSessionsAsync(userId);
            if (_notifier != null)
            {
                task = task.ContinueWith(async _ =>
                {
                    await _notifier.NotifyAsync("userSessionsEnded", new { userId });
                }).Unwrap();
            }
            return task;
        }

        public Task<IEnumerable<SessionHistoryDto>> GetSessionHistoryAsync(int? userId, int daysBack)
        {
            return _repo.GetSessionHistoryAsync(userId, daysBack);
        }

        public Task CleanupExpiredSessionsAsync()
        {
            return _repo.CleanupExpiredSessionsAsync();
        }
    }
}
