using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IAuthRepository
    {
        Task<(int UserId, string UserType)> AuthenticateUserAsync(string username, string password);
        Task<int> CreateUserSessionAsync(int userId, string sessionToken, string? ipAddress, string? userAgent, int expiryHours);
        Task<int> CreateRefreshTokenAsync(int userId, string token, int expiryDays, string? ipAddress, string? deviceInfo);
        Task<(bool IsValid, int? UserId)> ValidateRefreshTokenAsync(string token);
        Task RevokeRefreshTokenAsync(string token, string? reason, string? ipAddress, string? replacedByToken);
        Task RevokeAllUserRefreshTokensAsync(int userId, string reason);
        Task<UserInfo> GetUserInfoAsync(int userId);
    }
}
