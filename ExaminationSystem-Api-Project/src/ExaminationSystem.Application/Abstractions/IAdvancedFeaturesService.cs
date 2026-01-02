using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    /// <summary>
    /// Advanced features service for pagination, remedial exams, email queue, etc.
    /// </summary>
    public interface IAdvancedFeaturesService
    {
        // Pagination
        Task<PaginatedResult<PaginatedStudentDto>> GetStudentsPaginatedAsync(int pageNumber, int pageSize, string? searchTerm = null);
        Task<PaginatedResult<PaginatedExamDto>> GetExamsPaginatedAsync(int pageNumber, int pageSize, string? searchTerm = null);
        Task<PaginatedResult<PaginatedQuestionDto>> GetQuestionsPaginatedAsync(int pageNumber, int pageSize, int? courseId = null);

        // Remedial Exams
        Task<IEnumerable<RemedialCandidateDto>> GetRemedialCandidatesAsync(int? courseId = null);
        Task<RemedialProgressDto> GetRemedialProgressAsync();
        Task<IEnumerable<StudentRemedialHistoryDto>> GetStudentRemedialHistoryAsync(int studentId);
        Task AutoAssignRemedialExamsAsync();

        // Email Queue
        Task<EmailQueueStatusDto> GetEmailQueueStatusAsync();
        Task<IEnumerable<EmailQueueItemDto>> GetPendingEmailsAsync();
        Task ScheduleEmailAsync(ScheduleEmailDto dto);
        Task ProcessEmailQueueAsync();
        Task RetryFailedEmailsAsync();

        // Event Store
        Task AppendEventAsync(int userId, AppendEventDto dto);
        Task<IEnumerable<EventDto>> GetAggregateEventsAsync(string aggregateType, int aggregateId);
        Task<IEnumerable<EventDto>> GetUserTimelineAsync(int userId);
        Task<IEnumerable<SystemActivityDto>> GetSystemActivityAsync(int days = 7);
        Task<IEnumerable<EventStatisticsDto>> GetEventStatisticsAsync();

        // API Key Management
        Task<IEnumerable<ApiKeyDto>> GetAllApiKeysAsync();
        Task<ApiKeyCreatedDto> CreateApiKeyAsync(int userId, CreateApiKeyDto dto);
        Task RevokeApiKeyAsync(int apiKeyId);
        Task ResetApiKeyRateLimitAsync(int apiKeyId);
        Task<ApiUsageStatisticsDto> GetApiUsageStatisticsAsync();

        // Notifications
        Task CreateNotificationAsync(CreateNotificationDto dto);
        Task SendBulkNotificationsAsync(BulkNotificationDto dto);

        // Lookup & Search
        Task<LookupDataDto> GetLookupDataAsync();
        Task<IEnumerable<GlobalSearchResultDto>> GlobalSearchAsync(string searchTerm, string userType = "Admin");

        // Cleanup Jobs
        Task CleanupExpiredRefreshTokensAsync();
        Task CleanupExpiredSessionsAsync();
        Task CleanupOldNotificationsAsync(int daysOld = 30);
        Task CleanupSentEmailsAsync(int daysOld = 30);

        // Branch/Track/Intake Updates
        Task UpdateBranchAsync(int managerUserId, int branchId, UpdateBranchDto dto);
        Task UpdateTrackAsync(int managerUserId, int trackId, UpdateTrackDto dto);
        Task UpdateIntakeAsync(int managerUserId, int intakeId, UpdateIntakeDto dto);

        // Student Enrollment & Grades
        Task EnrollStudentInCourseAsync(EnrollStudentDto dto);
        Task<IEnumerable<StudentCourseGradeDto>> GetStudentCourseGradesAsync(int studentId);
        Task UpdateCourseFinalGradesAsync(UpdateFinalGradesDto dto);

        // EventStore Additional
        Task ArchiveOldEventsAsync(int daysOld = 90);
        Task CreateSnapshotAsync(CreateSnapshotDto dto);
        Task<IEnumerable<CorrelatedEventDto>> GetCorrelatedEventsAsync(string correlationId);

        // Exam Additional
        Task BulkAssignStudentsToExamAsync(BulkAssignStudentsDto dto);
        Task<IEnumerable<AdvancedExamQuestionDto>> GetExamQuestionsAsync(int examId);
        Task<IEnumerable<PaginatedQuestionDto>> GetRandomQuestionsByTypeAsync(RandomQuestionDto dto);
        Task<IEnumerable<StudentExamResultDto>> GetStudentExamResultsAsync(int studentId);

        // System Statistics
        Task<SystemStatisticsDto> GetSystemStatisticsAsync();

        // Session Management
        Task<IEnumerable<UserRefreshTokenDto>> GetUserRefreshTokensAsync(int userId);
        Task<ValidateSessionDto> ValidateSessionAsync(int sessionId);
        Task RefreshSessionAsync(RefreshSessionDto dto);

        // API Logging
        Task LogApiRequestAsync(LogApiRequestDto dto);
        Task<bool> ValidateApiKeyAsync(string apiKey);

        // Email Templates
        Task SendWelcomeEmailAsync(SendWelcomeEmailDto dto);
        Task SendPasswordResetEmailAsync(SendPasswordResetEmailDto dto);
        Task SendExamReminderEmailAsync(SendExamReminderEmailDto dto);
        Task SendGradeEmailAsync(SendGradeEmailDto dto);
        Task MarkEmailAsSentAsync(int emailId);
        Task MarkEmailAsFailedAsync(int emailId, string error);

        // Notifications
        Task NotifyExamAssignedAsync(int examId, int studentId);
        Task NotifyExamReminderAsync(int examId);
        Task NotifyGradeReleasedAsync(int examId, int studentId);
        Task NotifyPasswordResetAsync(int userId);
    }

    /// <summary>
    /// Repository interface for advanced features
    /// </summary>
    public interface IAdvancedFeaturesRepository
    {
        // Pagination
        Task<(IEnumerable<PaginatedStudentDto> Items, int TotalCount)> GetStudentsPaginatedAsync(int pageNumber, int pageSize, string? searchTerm);
        Task<(IEnumerable<PaginatedExamDto> Items, int TotalCount)> GetExamsPaginatedAsync(int pageNumber, int pageSize, string? searchTerm);
        Task<(IEnumerable<PaginatedQuestionDto> Items, int TotalCount)> GetQuestionsPaginatedAsync(int pageNumber, int pageSize, int? courseId);

        // Remedial Exams
        Task<IEnumerable<RemedialCandidateDto>> GetRemedialCandidatesAsync(int? courseId);
        Task<RemedialProgressDto> GetRemedialProgressAsync();
        Task<IEnumerable<StudentRemedialHistoryDto>> GetStudentRemedialHistoryAsync(int studentId);
        Task AutoAssignRemedialExamsAsync();

        // Email Queue
        Task<EmailQueueStatusDto> GetEmailQueueStatusAsync();
        Task<IEnumerable<EmailQueueItemDto>> GetPendingEmailsAsync();
        Task ScheduleEmailAsync(ScheduleEmailDto dto);
        Task ProcessEmailQueueAsync();
        Task RetryFailedEmailsAsync();

        // Event Store
        Task AppendEventAsync(int userId, AppendEventDto dto);
        Task<IEnumerable<EventDto>> GetAggregateEventsAsync(string aggregateType, int aggregateId);
        Task<IEnumerable<EventDto>> GetUserTimelineAsync(int userId);
        Task<IEnumerable<SystemActivityDto>> GetSystemActivityAsync(int days);
        Task<IEnumerable<EventStatisticsDto>> GetEventStatisticsAsync();

        // API Key Management
        Task<IEnumerable<ApiKeyDto>> GetAllApiKeysAsync();
        Task<ApiKeyCreatedDto> CreateApiKeyAsync(int userId, CreateApiKeyDto dto);
        Task RevokeApiKeyAsync(int apiKeyId);
        Task ResetApiKeyRateLimitAsync(int apiKeyId);
        Task<ApiUsageStatisticsDto> GetApiUsageStatisticsAsync();

        // Notifications
        Task CreateNotificationAsync(CreateNotificationDto dto);
        Task SendBulkNotificationsAsync(BulkNotificationDto dto);

        // Lookup & Search
        Task<LookupDataDto> GetLookupDataAsync();
        Task<IEnumerable<GlobalSearchResultDto>> GlobalSearchAsync(string searchTerm, string userType = "Admin");

        // Cleanup Jobs
        Task CleanupExpiredRefreshTokensAsync();
        Task CleanupExpiredSessionsAsync();
        Task CleanupOldNotificationsAsync(int daysOld);
        Task CleanupSentEmailsAsync(int daysOld);

        // Branch/Track/Intake Updates
        Task UpdateBranchAsync(int managerUserId, int branchId, UpdateBranchDto dto);
        Task UpdateTrackAsync(int managerUserId, int trackId, UpdateTrackDto dto);
        Task UpdateIntakeAsync(int managerUserId, int intakeId, UpdateIntakeDto dto);

        // Student Enrollment & Grades
        Task EnrollStudentInCourseAsync(EnrollStudentDto dto);
        Task<IEnumerable<StudentCourseGradeDto>> GetStudentCourseGradesAsync(int studentId);
        Task UpdateCourseFinalGradesAsync(UpdateFinalGradesDto dto);

        // EventStore Additional
        Task ArchiveOldEventsAsync(int daysOld);
        Task CreateSnapshotAsync(CreateSnapshotDto dto);
        Task<IEnumerable<CorrelatedEventDto>> GetCorrelatedEventsAsync(string correlationId);

        // Exam Additional
        Task BulkAssignStudentsToExamAsync(BulkAssignStudentsDto dto);
        Task<IEnumerable<AdvancedExamQuestionDto>> GetExamQuestionsAsync(int examId);
        Task<IEnumerable<PaginatedQuestionDto>> GetRandomQuestionsByTypeAsync(RandomQuestionDto dto);
        Task<IEnumerable<StudentExamResultDto>> GetStudentExamResultsAsync(int studentId);

        // System Statistics
        Task<SystemStatisticsDto> GetSystemStatisticsAsync();

        // Session Management
        Task<IEnumerable<UserRefreshTokenDto>> GetUserRefreshTokensAsync(int userId);
        Task<ValidateSessionDto> ValidateSessionAsync(int sessionId);
        Task RefreshSessionAsync(RefreshSessionDto dto);

        // API Logging
        Task LogApiRequestAsync(LogApiRequestDto dto);
        Task<bool> ValidateApiKeyAsync(string apiKey);

        // Email Templates
        Task SendWelcomeEmailAsync(SendWelcomeEmailDto dto);
        Task SendPasswordResetEmailAsync(SendPasswordResetEmailDto dto);
        Task SendExamReminderEmailAsync(SendExamReminderEmailDto dto);
        Task SendGradeEmailAsync(SendGradeEmailDto dto);
        Task MarkEmailAsSentAsync(int emailId);
        Task MarkEmailAsFailedAsync(int emailId, string error);

        // Notifications
        Task NotifyExamAssignedAsync(int examId, int studentId);
        Task NotifyExamReminderAsync(int examId);
        Task NotifyGradeReleasedAsync(int examId, int studentId);
        Task NotifyPasswordResetAsync(int userId);
    }
}
