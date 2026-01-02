using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IProfileService
    {
        Task<ProfileDto> GetProfileAsync(int userId);
        Task UpdateProfileAsync(int userId, ProfileUpdateDto dto);
        Task ChangePasswordAsync(int userId, string oldPassword, string newPassword);
    }
}
