using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IAdminRepository
    {
        Task<int> CreateUserAsync(CreateUserDto dto);
        Task UpdateUserAsync(int userId, UpdateUserDto dto);
        Task DeleteUserAsync(int targetUserId, int adminUserId);
        Task ResetPasswordAsync(int adminUserId, int targetUserId, string newPassword);
        Task<IEnumerable<UserLiteDto>> ListUsersAsync();
        Task<UserLiteDto?> GetUserByIdAsync(int userId);
        Task<bool?> GetUserActiveStatusAsync(int userId);
        Task<IEnumerable<AuditLogDto>> GetAuditLogsAsync(string? eventType, string? status, DateTime? dateFrom, DateTime? dateTo, int page, int pageSize);
    }
}
