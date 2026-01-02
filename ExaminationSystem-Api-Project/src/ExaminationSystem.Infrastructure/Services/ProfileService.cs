using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class ProfileService : IProfileService
    {
        private readonly IProfileRepository _repo;
        public ProfileService(IProfileRepository repo)
        {
            _repo = repo;
        }

        public Task<ProfileDto> GetProfileAsync(int userId) => _repo.GetProfileAsync(userId);

        public Task UpdateProfileAsync(int userId, ProfileUpdateDto dto) => _repo.UpdateProfileAsync(userId, dto);

        public Task ChangePasswordAsync(int userId, string oldPassword, string newPassword)
            => _repo.ChangePasswordAsync(userId, oldPassword, newPassword);
    }
}
