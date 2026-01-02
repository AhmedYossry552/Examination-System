using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IAuthService
    {
        Task<LoginResult> LoginAsync(string username, string password, string? ip, string? userAgent);
        Task<RefreshResult> RefreshAsync(string refreshToken, string? ip, string? userAgent);
        Task LogoutAsync(string refreshToken, string? ip);
    }
}
