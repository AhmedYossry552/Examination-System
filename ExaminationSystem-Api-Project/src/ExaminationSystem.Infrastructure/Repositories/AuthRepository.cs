using System.Data;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class AuthRepository : IAuthRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;

        public AuthRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<(int UserId, string UserType)> AuthenticateUserAsync(string username, string password)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@Username", username);
            p.Add("@Password", password);
            p.Add("@UserID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            p.Add("@UserType", dbType: DbType.String, size: 20, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Security.SP_Admin_AuthenticateUser", p, commandType: CommandType.StoredProcedure);
            var userId = p.Get<int?>("@UserID");
            var userType = p.Get<string>("@UserType");
            if (userId == null)
            {
                throw new System.UnauthorizedAccessException("Invalid username or password.");
            }
            return (userId.Value, userType);
        }

        public async Task<int> CreateUserSessionAsync(int userId, string sessionToken, string? ipAddress, string? userAgent, int expiryHours)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@SessionToken", sessionToken);
            p.Add("@IPAddress", ipAddress);
            p.Add("@UserAgent", userAgent);
            p.Add("@ExpiryHours", expiryHours);
            p.Add("@SessionID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Security.SP_CreateUserSession", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@SessionID");
        }

        public async Task<int> CreateRefreshTokenAsync(int userId, string token, int expiryDays, string? ipAddress, string? deviceInfo)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@Token", token);
            p.Add("@ExpiryDays", expiryDays);
            p.Add("@IPAddress", ipAddress);
            p.Add("@DeviceInfo", deviceInfo);
            p.Add("@RefreshTokenID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Security.SP_CreateRefreshToken", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@RefreshTokenID");
        }

        public async Task<(bool IsValid, int? UserId)> ValidateRefreshTokenAsync(string token)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@Token", token);
            p.Add("@UserID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            p.Add("@IsValid", dbType: DbType.Boolean, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Security.SP_ValidateRefreshToken", p, commandType: CommandType.StoredProcedure);
            var isValid = p.Get<bool>("@IsValid");
            var userId = p.Get<int?>("@UserID");
            return (isValid, userId);
        }

        public async Task RevokeRefreshTokenAsync(string token, string? reason, string? ipAddress, string? replacedByToken)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@Token", token);
            p.Add("@Reason", reason);
            p.Add("@IPAddress", ipAddress);
            p.Add("@ReplacedByToken", replacedByToken);
            await conn.ExecuteAsync("Security.SP_RevokeRefreshToken", p, commandType: CommandType.StoredProcedure);
        }

        public async Task RevokeAllUserRefreshTokensAsync(int userId, string reason)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@Reason", reason);
            await conn.ExecuteAsync("Security.SP_RevokeAllUserRefreshTokens", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<UserInfo> GetUserInfoAsync(int userId)
        {
            using var conn = _connectionFactory.CreateConnection();
            const string sql = @"SELECT UserID, Username, UserType FROM Security.[User] WHERE UserID = @UserID";
            var row = await conn.QuerySingleAsync(sql, new { UserID = userId });
            int id = (int)row.UserID;
            string username = (string)row.Username;
            string userType = (string)row.UserType;
            return new UserInfo(id, username, userType);
        }
    }
}
