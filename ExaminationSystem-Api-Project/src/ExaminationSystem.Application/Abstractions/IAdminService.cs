using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IAdminService
    {
        Task<int> CreateUserAsync(int currentUserId, CreateUserDto dto);
        Task UpdateUserAsync(int currentUserId, int userId, UpdateUserDto dto);
        Task DeleteUserAsync(int currentUserId, int userId);
        Task ResetPasswordAsync(int currentUserId, int userId, string newPassword);
        Task<IEnumerable<UserLiteDto>> ListUsersAsync(int currentUserId);
        Task<UserLiteDto?> GetUserByIdAsync(int userId);
        Task ToggleUserStatusAsync(int currentUserId, int userId);
        Task<IEnumerable<AuditLogDto>> GetAuditLogsAsync(string? eventType, string? status, DateTime? dateFrom, DateTime? dateTo, int page, int pageSize);
    }

    // Properties must match SP EventStore.SP_GetSystemActivity output columns exactly
    public record AuditLogDto(
        long EventID,
        string EventType,
        string AggregateType,
        string AggregateID,
        DateTime OccurredAt,
        int UserID,
        string Username,
        string UserType,
        string? IPAddress,
        int TotalRecords
    );
}
