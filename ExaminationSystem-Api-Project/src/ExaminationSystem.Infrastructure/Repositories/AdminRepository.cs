using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class AdminRepository : IAdminRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;
        public AdminRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<int> CreateUserAsync(CreateUserDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@Username", dto.Username);
            p.Add("@Password", dto.Password);
            p.Add("@Email", dto.Email);
            p.Add("@FirstName", dto.FirstName);
            p.Add("@LastName", dto.LastName);
            p.Add("@PhoneNumber", dto.PhoneNumber);
            p.Add("@UserType", dto.UserType);
            p.Add("@UserID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Security.SP_Admin_CreateUser", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@UserID");
        }

        public async Task UpdateUserAsync(int userId, UpdateUserDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@Email", dto.Email);
            p.Add("@FirstName", dto.FirstName);
            p.Add("@LastName", dto.LastName);
            p.Add("@PhoneNumber", dto.PhoneNumber);
            p.Add("@IsActive", dto.IsActive);
            await conn.ExecuteAsync("Security.SP_Admin_UpdateUser", p, commandType: CommandType.StoredProcedure);
        }

        public async Task DeleteUserAsync(int targetUserId, int adminUserId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", targetUserId);
            p.Add("@AdminUserID", adminUserId);
            await conn.ExecuteAsync("Security.SP_Admin_DeleteUser", p, commandType: CommandType.StoredProcedure);
        }

        public async Task ResetPasswordAsync(int adminUserId, int targetUserId, string newPassword)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@AdminUserID", adminUserId);
            p.Add("@TargetUserID", targetUserId);
            p.Add("@NewPassword", newPassword);
            await conn.ExecuteAsync("Security.SP_Admin_ResetPassword", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<UserLiteDto>> ListUsersAsync()
        {
            using var conn = _connectionFactory.CreateConnection();
            const string sql = @"SELECT UserID, Username, Email, FirstName, LastName, PhoneNumber, UserType, IsActive
                                 FROM Security.[User] ORDER BY UserID";
            var result = await conn.QueryAsync<UserLiteDto>(sql);
            return result;
        }

        public async Task<UserLiteDto?> GetUserByIdAsync(int userId)
        {
            using var conn = _connectionFactory.CreateConnection();
            const string sql = @"SELECT UserID, Username, Email, FirstName, LastName, PhoneNumber, UserType, IsActive
                                 FROM Security.[User] WHERE UserID = @UserID";
            return await conn.QueryFirstOrDefaultAsync<UserLiteDto>(sql, new { UserID = userId });
        }

        public async Task<bool?> GetUserActiveStatusAsync(int userId)
        {
            using var conn = _connectionFactory.CreateConnection();
            const string sql = "SELECT IsActive FROM Security.[User] WHERE UserID = @UserID";
            return await conn.QueryFirstOrDefaultAsync<bool?>(sql, new { UserID = userId });
        }

        public async Task<IEnumerable<AuditLogDto>> GetAuditLogsAsync(string? eventType, string? status, DateTime? dateFrom, DateTime? dateTo, int page, int pageSize)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@EventType", eventType);
            p.Add("@AggregateType", (string?)null);
            p.Add("@StartDate", dateFrom);
            p.Add("@EndDate", dateTo);
            p.Add("@PageNumber", page);
            p.Add("@PageSize", pageSize);

            var result = await conn.QueryAsync<AuditLogDto>(
                "EventStore.SP_GetSystemActivity",
                p,
                commandType: CommandType.StoredProcedure);
            return result;
        }
    }
}
