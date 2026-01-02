using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class SessionRepository : ISessionRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;

        public SessionRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IEnumerable<ActiveSessionDto>> GetActiveSessionsAsync(int userId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);

            var result = await conn.QueryAsync<ActiveSessionDto>(
                "Security.SP_GetActiveSessions",
                p,
                commandType: CommandType.StoredProcedure);

            return result;
        }

        public async Task EndSessionAsync(string sessionToken)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@SessionToken", sessionToken);

            try
            {
                await conn.ExecuteAsync(
                    "Security.SP_EndSession",
                    p,
                    commandType: CommandType.StoredProcedure);
            }
            catch
            {
                // Swallow errors (e.g. session not found) to avoid leaking DB error details
                // Global logging can capture these via Serilog if needed.
            }
        }

        public async Task EndAllUserSessionsAsync(int userId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);

            await conn.ExecuteAsync(
                "Security.SP_EndAllUserSessions",
                p,
                commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<SessionHistoryDto>> GetSessionHistoryAsync(int? userId, int daysBack)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@DaysBack", daysBack);

            var result = await conn.QueryAsync<SessionHistoryDto>(
                "Security.SP_GetSessionHistory",
                p,
                commandType: CommandType.StoredProcedure);

            return result;
        }

        public async Task CleanupExpiredSessionsAsync()
        {
            using var conn = _connectionFactory.CreateConnection();
            await conn.ExecuteAsync(
                "Security.SP_CleanupExpiredSessions",
                commandType: CommandType.StoredProcedure);
        }
    }
}
