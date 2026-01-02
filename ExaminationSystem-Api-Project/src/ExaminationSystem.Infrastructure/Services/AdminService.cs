using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class AdminService : IAdminService
    {
        private readonly IAdminRepository _repo;
        public AdminService(IAdminRepository repo)
        {
            _repo = repo;
        }

        public async Task<int> CreateUserAsync(int currentUserId, CreateUserDto dto)
        {
            return await _repo.CreateUserAsync(dto);
        }

        public async Task UpdateUserAsync(int currentUserId, int userId, UpdateUserDto dto)
        {
            await _repo.UpdateUserAsync(userId, dto);
        }

        public async Task DeleteUserAsync(int currentUserId, int userId)
        {
            await _repo.DeleteUserAsync(userId, currentUserId);
        }

        public async Task ResetPasswordAsync(int currentUserId, int userId, string newPassword)
        {
            await _repo.ResetPasswordAsync(currentUserId, userId, newPassword);
        }

        public Task<IEnumerable<UserLiteDto>> ListUsersAsync(int currentUserId)
        {
            return _repo.ListUsersAsync();
        }

        public Task<UserLiteDto?> GetUserByIdAsync(int userId)
        {
            return _repo.GetUserByIdAsync(userId);
        }

        public async Task ToggleUserStatusAsync(int currentUserId, int userId)
        {
            var currentStatus = await _repo.GetUserActiveStatusAsync(userId);
            if (currentStatus == null)
                throw new InvalidOperationException("User not found.");
            
            await _repo.UpdateUserAsync(userId, new UpdateUserDto { IsActive = !currentStatus.Value });
        }

        public Task<IEnumerable<AuditLogDto>> GetAuditLogsAsync(string? eventType, string? status, DateTime? dateFrom, DateTime? dateTo, int page, int pageSize)
        {
            return _repo.GetAuditLogsAsync(eventType, status, dateFrom, dateTo, page, pageSize);
        }
    }
}
