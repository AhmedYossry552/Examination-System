using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAuthRepository _repo;
        private readonly ITokenService _tokens;

        public AuthService(IAuthRepository repo, ITokenService tokens)
        {
            _repo = repo;
            _tokens = tokens;
        }

        public async Task<LoginResult> LoginAsync(string username, string password, string? ip, string? userAgent)
        {
            var (userId, role) = await _repo.AuthenticateUserAsync(username, password);

            var access = _tokens.GenerateAccessToken(userId, username, role);
            var refresh = _tokens.GenerateSecureToken(64);

            await _repo.CreateRefreshTokenAsync(userId, refresh, 30, ip, userAgent);
            var sessionToken = _tokens.GenerateSecureToken(48);
            await _repo.CreateUserSessionAsync(userId, sessionToken, ip, userAgent, 8);

            return new LoginResult(userId, username, role, access.Token, access.ExpiresAt, refresh);
        }

        public async Task<RefreshResult> RefreshAsync(string refreshToken, string? ip, string? userAgent)
        {
            var (isValid, userId) = await _repo.ValidateRefreshTokenAsync(refreshToken);
            if (!isValid || userId == null)
            {
                throw new System.UnauthorizedAccessException("Invalid refresh token.");
            }

            var user = await _repo.GetUserInfoAsync(userId.Value);

            var newAccess = _tokens.GenerateAccessToken(user.UserId, user.Username, user.UserType);
            var newRefresh = _tokens.GenerateSecureToken(64);

            await _repo.RevokeRefreshTokenAsync(refreshToken, "Rotated", ip, newRefresh);
            await _repo.CreateRefreshTokenAsync(user.UserId, newRefresh, 30, ip, userAgent);

            return new RefreshResult(newAccess.Token, newAccess.ExpiresAt, newRefresh);
        }

        public async Task LogoutAsync(string refreshToken, string? ip)
        {
            await _repo.RevokeRefreshTokenAsync(refreshToken, "Logout", ip, null);
        }
    }
}
