using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    /// <summary>
    /// Service implementation for advanced features
    /// </summary>
    public class AdvancedFeaturesService : IAdvancedFeaturesService
    {
        private readonly IAdvancedFeaturesRepository _repository;

        public AdvancedFeaturesService(IAdvancedFeaturesRepository repository)
        {
            _repository = repository;
        }

        #region Pagination

        public async Task<PaginatedResult<PaginatedStudentDto>> GetStudentsPaginatedAsync(
            int pageNumber, int pageSize, string? searchTerm = null)
        {
            var (items, totalCount) = await _repository.GetStudentsPaginatedAsync(pageNumber, pageSize, searchTerm);
            
            return new PaginatedResult<PaginatedStudentDto>
            {
                Items = items.ToList(),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<PaginatedResult<PaginatedExamDto>> GetExamsPaginatedAsync(
            int pageNumber, int pageSize, string? searchTerm = null)
        {
            var (items, totalCount) = await _repository.GetExamsPaginatedAsync(pageNumber, pageSize, searchTerm);
            
            return new PaginatedResult<PaginatedExamDto>
            {
                Items = items.ToList(),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<PaginatedResult<PaginatedQuestionDto>> GetQuestionsPaginatedAsync(
            int pageNumber, int pageSize, int? courseId = null)
        {
            var (items, totalCount) = await _repository.GetQuestionsPaginatedAsync(pageNumber, pageSize, courseId);
            
            return new PaginatedResult<PaginatedQuestionDto>
            {
                Items = items.ToList(),
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        #endregion

        #region Remedial Exams

        public async Task<IEnumerable<RemedialCandidateDto>> GetRemedialCandidatesAsync(int? courseId = null)
        {
            return await _repository.GetRemedialCandidatesAsync(courseId);
        }

        public async Task<RemedialProgressDto> GetRemedialProgressAsync()
        {
            return await _repository.GetRemedialProgressAsync();
        }

        public async Task<IEnumerable<StudentRemedialHistoryDto>> GetStudentRemedialHistoryAsync(int studentId)
        {
            return await _repository.GetStudentRemedialHistoryAsync(studentId);
        }

        public async Task AutoAssignRemedialExamsAsync()
        {
            await _repository.AutoAssignRemedialExamsAsync();
        }

        #endregion

        #region Email Queue

        public async Task<EmailQueueStatusDto> GetEmailQueueStatusAsync()
        {
            return await _repository.GetEmailQueueStatusAsync();
        }

        public async Task<IEnumerable<EmailQueueItemDto>> GetPendingEmailsAsync()
        {
            return await _repository.GetPendingEmailsAsync();
        }

        public async Task ScheduleEmailAsync(ScheduleEmailDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.RecipientEmail))
                throw new ArgumentException("Recipient email is required");
            
            if (string.IsNullOrWhiteSpace(dto.Subject))
                throw new ArgumentException("Subject is required");

            await _repository.ScheduleEmailAsync(dto);
        }

        public async Task ProcessEmailQueueAsync()
        {
            await _repository.ProcessEmailQueueAsync();
        }

        public async Task RetryFailedEmailsAsync()
        {
            await _repository.RetryFailedEmailsAsync();
        }

        #endregion

        #region Event Store

        public async Task AppendEventAsync(int userId, AppendEventDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.AggregateType))
                throw new ArgumentException("Aggregate type is required");
            
            if (string.IsNullOrWhiteSpace(dto.EventType))
                throw new ArgumentException("Event type is required");

            await _repository.AppendEventAsync(userId, dto);
        }

        public async Task<IEnumerable<EventDto>> GetAggregateEventsAsync(string aggregateType, int aggregateId)
        {
            return await _repository.GetAggregateEventsAsync(aggregateType, aggregateId);
        }

        public async Task<IEnumerable<EventDto>> GetUserTimelineAsync(int userId)
        {
            return await _repository.GetUserTimelineAsync(userId);
        }

        public async Task<IEnumerable<SystemActivityDto>> GetSystemActivityAsync(int days = 7)
        {
            if (days <= 0) days = 7;
            if (days > 365) days = 365;

            return await _repository.GetSystemActivityAsync(days);
        }

        public async Task<IEnumerable<EventStatisticsDto>> GetEventStatisticsAsync()
        {
            return await _repository.GetEventStatisticsAsync();
        }

        #endregion

        #region API Key Management

        public async Task<IEnumerable<ApiKeyDto>> GetAllApiKeysAsync()
        {
            return await _repository.GetAllApiKeysAsync();
        }

        public async Task<ApiKeyCreatedDto> CreateApiKeyAsync(int userId, CreateApiKeyDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.KeyName))
                throw new ArgumentException("Key name is required");

            return await _repository.CreateApiKeyAsync(userId, dto);
        }

        public async Task RevokeApiKeyAsync(int apiKeyId)
        {
            await _repository.RevokeApiKeyAsync(apiKeyId);
        }

        public async Task ResetApiKeyRateLimitAsync(int apiKeyId)
        {
            await _repository.ResetApiKeyRateLimitAsync(apiKeyId);
        }

        public async Task<ApiUsageStatisticsDto> GetApiUsageStatisticsAsync()
        {
            return await _repository.GetApiUsageStatisticsAsync();
        }

        #endregion

        #region Notifications

        public async Task CreateNotificationAsync(CreateNotificationDto dto)
        {
            if (dto.UserId <= 0)
                throw new ArgumentException("User ID is required");
            
            if (string.IsNullOrWhiteSpace(dto.Title))
                throw new ArgumentException("Title is required");

            await _repository.CreateNotificationAsync(dto);
        }

        public async Task SendBulkNotificationsAsync(BulkNotificationDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Title))
                throw new ArgumentException("Title is required");
            
            if (string.IsNullOrWhiteSpace(dto.Message))
                throw new ArgumentException("Message is required");

            await _repository.SendBulkNotificationsAsync(dto);
        }

        #endregion

        #region Lookup & Search

        public async Task<LookupDataDto> GetLookupDataAsync()
        {
            return await _repository.GetLookupDataAsync();
        }

        public async Task<IEnumerable<GlobalSearchResultDto>> GlobalSearchAsync(string searchTerm, string userType = "Admin")
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return new List<GlobalSearchResultDto>();

            return await _repository.GlobalSearchAsync(searchTerm, userType);
        }

        #endregion

        #region Cleanup Jobs

        public async Task CleanupExpiredRefreshTokensAsync()
        {
            await _repository.CleanupExpiredRefreshTokensAsync();
        }

        public async Task CleanupExpiredSessionsAsync()
        {
            await _repository.CleanupExpiredSessionsAsync();
        }

        public async Task CleanupOldNotificationsAsync(int daysOld = 30)
        {
            if (daysOld <= 0) daysOld = 30;
            await _repository.CleanupOldNotificationsAsync(daysOld);
        }

        public async Task CleanupSentEmailsAsync(int daysOld = 30)
        {
            if (daysOld <= 0) daysOld = 30;
            await _repository.CleanupSentEmailsAsync(daysOld);
        }

        #endregion

        #region Branch/Track/Intake Updates

        public async Task UpdateBranchAsync(int managerUserId, int branchId, UpdateBranchDto dto)
        {
            if (managerUserId <= 0)
                throw new ArgumentException("Manager User ID is required");
            if (branchId <= 0)
                throw new ArgumentException("Branch ID is required");
            await _repository.UpdateBranchAsync(managerUserId, branchId, dto);
        }

        public async Task UpdateTrackAsync(int managerUserId, int trackId, UpdateTrackDto dto)
        {
            if (managerUserId <= 0)
                throw new ArgumentException("Manager User ID is required");
            if (trackId <= 0)
                throw new ArgumentException("Track ID is required");
            await _repository.UpdateTrackAsync(managerUserId, trackId, dto);
        }

        public async Task UpdateIntakeAsync(int managerUserId, int intakeId, UpdateIntakeDto dto)
        {
            if (managerUserId <= 0)
                throw new ArgumentException("Manager User ID is required");
            if (intakeId <= 0)
                throw new ArgumentException("Intake ID is required");
            await _repository.UpdateIntakeAsync(managerUserId, intakeId, dto);
        }

        #endregion

        #region Student Enrollment & Grades

        public async Task EnrollStudentInCourseAsync(EnrollStudentDto dto)
        {
            if (dto.StudentID <= 0)
                throw new ArgumentException("Student ID is required");
            if (dto.CourseID <= 0)
                throw new ArgumentException("Course ID is required");
            await _repository.EnrollStudentInCourseAsync(dto);
        }

        public async Task<IEnumerable<StudentCourseGradeDto>> GetStudentCourseGradesAsync(int studentId)
        {
            return await _repository.GetStudentCourseGradesAsync(studentId);
        }

        public async Task UpdateCourseFinalGradesAsync(UpdateFinalGradesDto dto)
        {
            if (dto.CourseID <= 0)
                throw new ArgumentException("Course ID is required");
            await _repository.UpdateCourseFinalGradesAsync(dto);
        }

        #endregion

        #region EventStore Additional

        public async Task ArchiveOldEventsAsync(int daysOld = 90)
        {
            if (daysOld <= 0) daysOld = 90;
            await _repository.ArchiveOldEventsAsync(daysOld);
        }

        public async Task CreateSnapshotAsync(CreateSnapshotDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.AggregateType))
                throw new ArgumentException("Aggregate type is required");
            await _repository.CreateSnapshotAsync(dto);
        }

        public async Task<IEnumerable<CorrelatedEventDto>> GetCorrelatedEventsAsync(string correlationId)
        {
            if (string.IsNullOrWhiteSpace(correlationId))
                return new List<CorrelatedEventDto>();
            return await _repository.GetCorrelatedEventsAsync(correlationId);
        }

        #endregion

        #region Exam Additional

        public async Task BulkAssignStudentsToExamAsync(BulkAssignStudentsDto dto)
        {
            if (dto.ExamID <= 0)
                throw new ArgumentException("Exam ID is required");
            if (dto.StudentIDs == null || dto.StudentIDs.Count == 0)
                throw new ArgumentException("At least one student ID is required");
            await _repository.BulkAssignStudentsToExamAsync(dto);
        }

        public async Task<IEnumerable<AdvancedExamQuestionDto>> GetExamQuestionsAsync(int examId)
        {
            return await _repository.GetExamQuestionsAsync(examId);
        }

        public async Task<IEnumerable<PaginatedQuestionDto>> GetRandomQuestionsByTypeAsync(RandomQuestionDto dto)
        {
            if (dto.CourseID <= 0)
                throw new ArgumentException("Course ID is required");
            return await _repository.GetRandomQuestionsByTypeAsync(dto);
        }

        public async Task<IEnumerable<StudentExamResultDto>> GetStudentExamResultsAsync(int studentId)
        {
            return await _repository.GetStudentExamResultsAsync(studentId);
        }

        #endregion

        #region System Statistics

        public async Task<SystemStatisticsDto> GetSystemStatisticsAsync()
        {
            return await _repository.GetSystemStatisticsAsync();
        }

        #endregion

        #region Session Management

        public async Task<IEnumerable<UserRefreshTokenDto>> GetUserRefreshTokensAsync(int userId)
        {
            return await _repository.GetUserRefreshTokensAsync(userId);
        }

        public async Task<ValidateSessionDto> ValidateSessionAsync(int sessionId)
        {
            return await _repository.ValidateSessionAsync(sessionId);
        }

        public async Task RefreshSessionAsync(RefreshSessionDto dto)
        {
            if (dto.SessionID <= 0)
                throw new ArgumentException("Session ID is required");
            await _repository.RefreshSessionAsync(dto);
        }

        #endregion

        #region API Logging

        public async Task LogApiRequestAsync(LogApiRequestDto dto)
        {
            await _repository.LogApiRequestAsync(dto);
        }

        public async Task<bool> ValidateApiKeyAsync(string apiKey)
        {
            if (string.IsNullOrWhiteSpace(apiKey))
                return false;
            return await _repository.ValidateApiKeyAsync(apiKey);
        }

        #endregion

        #region Email Templates

        public async Task SendWelcomeEmailAsync(SendWelcomeEmailDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Email))
                throw new ArgumentException("Email is required");
            await _repository.SendWelcomeEmailAsync(dto);
        }

        public async Task SendPasswordResetEmailAsync(SendPasswordResetEmailDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Email))
                throw new ArgumentException("Email is required");
            await _repository.SendPasswordResetEmailAsync(dto);
        }

        public async Task SendExamReminderEmailAsync(SendExamReminderEmailDto dto)
        {
            if (dto.ExamID <= 0)
                throw new ArgumentException("Exam ID is required");
            await _repository.SendExamReminderEmailAsync(dto);
        }

        public async Task SendGradeEmailAsync(SendGradeEmailDto dto)
        {
            if (dto.ExamID <= 0)
                throw new ArgumentException("Exam ID is required");
            await _repository.SendGradeEmailAsync(dto);
        }

        public async Task MarkEmailAsSentAsync(int emailId)
        {
            await _repository.MarkEmailAsSentAsync(emailId);
        }

        public async Task MarkEmailAsFailedAsync(int emailId, string error)
        {
            await _repository.MarkEmailAsFailedAsync(emailId, error);
        }

        #endregion

        #region Notifications

        public async Task NotifyExamAssignedAsync(int examId, int studentId)
        {
            await _repository.NotifyExamAssignedAsync(examId, studentId);
        }

        public async Task NotifyExamReminderAsync(int examId)
        {
            await _repository.NotifyExamReminderAsync(examId);
        }

        public async Task NotifyGradeReleasedAsync(int examId, int studentId)
        {
            await _repository.NotifyGradeReleasedAsync(examId, studentId);
        }

        public async Task NotifyPasswordResetAsync(int userId)
        {
            await _repository.NotifyPasswordResetAsync(userId);
        }

        #endregion
    }
}
