using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface ITokenService
    {
        AccessTokenResult GenerateAccessToken(int userId, string username, string role);
        string GenerateSecureToken(int size = 64);
    }
}
