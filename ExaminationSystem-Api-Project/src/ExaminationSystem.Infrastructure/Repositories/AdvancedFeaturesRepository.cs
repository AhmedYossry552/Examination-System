using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace ExaminationSystem.Infrastructure.Repositories
{
    /// <summary>
    /// Repository for advanced features using all stored procedures
    /// </summary>
    public class AdvancedFeaturesRepository : IAdvancedFeaturesRepository
    {
        private readonly string _connectionString;

        public AdvancedFeaturesRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string not found");
        }

        private SqlConnection CreateConnection() => new SqlConnection(_connectionString);

        #region Pagination

        public async Task<(IEnumerable<PaginatedStudentDto> Items, int TotalCount)> GetStudentsPaginatedAsync(
            int pageNumber, int pageSize, string? searchTerm)
        {
            using var connection = CreateConnection();
            
            var parameters = new DynamicParameters();
            parameters.Add("@PageNumber", pageNumber);
            parameters.Add("@PageSize", pageSize);
            parameters.Add("@SearchTerm", searchTerm ?? "");
            parameters.Add("@TotalCount", dbType: DbType.Int32, direction: ParameterDirection.Output);

            var students = await connection.QueryAsync<PaginatedStudentDto>(
                "Academic.SP_GetStudents_Paginated",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            var totalCount = parameters.Get<int>("@TotalCount");
            return (students, totalCount);
        }

        public async Task<(IEnumerable<PaginatedExamDto> Items, int TotalCount)> GetExamsPaginatedAsync(
            int pageNumber, int pageSize, string? searchTerm)
        {
            using var connection = CreateConnection();
            
            var parameters = new DynamicParameters();
            parameters.Add("@PageNumber", pageNumber);
            parameters.Add("@PageSize", pageSize);
            parameters.Add("@SearchTerm", searchTerm ?? "");
            parameters.Add("@TotalCount", dbType: DbType.Int32, direction: ParameterDirection.Output);

            var exams = await connection.QueryAsync<PaginatedExamDto>(
                "Exam.SP_GetExams_Paginated",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            var totalCount = parameters.Get<int>("@TotalCount");
            return (exams, totalCount);
        }

        public async Task<(IEnumerable<PaginatedQuestionDto> Items, int TotalCount)> GetQuestionsPaginatedAsync(
            int pageNumber, int pageSize, int? courseId)
        {
            using var connection = CreateConnection();
            
            var parameters = new DynamicParameters();
            parameters.Add("@PageNumber", pageNumber);
            parameters.Add("@PageSize", pageSize);
            parameters.Add("@CourseId", courseId);
            parameters.Add("@TotalCount", dbType: DbType.Int32, direction: ParameterDirection.Output);

            var questions = await connection.QueryAsync<PaginatedQuestionDto>(
                "Exam.SP_GetQuestions_Paginated",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            var totalCount = parameters.Get<int>("@TotalCount");
            return (questions, totalCount);
        }

        #endregion

        #region Remedial Exams

        public async Task<IEnumerable<RemedialCandidateDto>> GetRemedialCandidatesAsync(int? courseId)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<RemedialCandidateDto>(
                "Exam.SP_GetRemedialExamCandidates",
                new { CourseId = courseId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<RemedialProgressDto> GetRemedialProgressAsync()
        {
            using var connection = CreateConnection();
            
            return await connection.QueryFirstOrDefaultAsync<RemedialProgressDto>(
                "Exam.SP_GetRemedialExamProgress",
                commandType: CommandType.StoredProcedure
            ) ?? new RemedialProgressDto();
        }

        public async Task<IEnumerable<StudentRemedialHistoryDto>> GetStudentRemedialHistoryAsync(int studentId)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<StudentRemedialHistoryDto>(
                "Exam.SP_GetStudentRemedialHistory",
                new { StudentId = studentId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task AutoAssignRemedialExamsAsync()
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Exam.SP_AutoAssignRemedialExams",
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region Email Queue

        public async Task<EmailQueueStatusDto> GetEmailQueueStatusAsync()
        {
            using var connection = CreateConnection();
            
            return await connection.QueryFirstOrDefaultAsync<EmailQueueStatusDto>(
                "Security.SP_GetEmailQueueStatus",
                commandType: CommandType.StoredProcedure
            ) ?? new EmailQueueStatusDto();
        }

        public async Task<IEnumerable<EmailQueueItemDto>> GetPendingEmailsAsync()
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<EmailQueueItemDto>(
                "Security.SP_GetPendingEmails",
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task ScheduleEmailAsync(ScheduleEmailDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_ScheduleEmail",
                new
                {
                    ToEmail = dto.RecipientEmail,
                    dto.Subject,
                    dto.Body,
                    EmailType = "Scheduled",
                    ScheduledDate = dto.ScheduledFor ?? DateTime.Now.AddHours(1),
                    Priority = dto.Priority == 1 ? "Normal" : (dto.Priority == 2 ? "High" : "Low")
                },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task ProcessEmailQueueAsync()
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_ProcessEmailQueue",
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task RetryFailedEmailsAsync()
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_RetryFailedEmails",
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region Event Store

        public async Task AppendEventAsync(int userId, AppendEventDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "EventStore.SP_AppendEvent",
                new
                {
                    dto.AggregateType,
                    dto.AggregateId,
                    dto.EventType,
                    dto.EventData,
                    UserId = userId
                },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<IEnumerable<EventDto>> GetAggregateEventsAsync(string aggregateType, int aggregateId)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<EventDto>(
                "EventStore.SP_GetAggregateEvents",
                new { AggregateType = aggregateType, AggregateId = aggregateId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<IEnumerable<EventDto>> GetUserTimelineAsync(int userId)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<EventDto>(
                "EventStore.SP_GetUserTimeline",
                new { UserId = userId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<IEnumerable<SystemActivityDto>> GetSystemActivityAsync(int days)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<SystemActivityDto>(
                "EventStore.SP_GetSystemActivity",
                new { Days = days },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<IEnumerable<EventStatisticsDto>> GetEventStatisticsAsync()
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<EventStatisticsDto>(
                "EventStore.SP_GetEventStatistics",
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region API Key Management

        public async Task<IEnumerable<ApiKeyDto>> GetAllApiKeysAsync()
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<ApiKeyDto>(
                "Security.SP_GetAllAPIKeys",
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<ApiKeyCreatedDto> CreateApiKeyAsync(int userId, CreateApiKeyDto dto)
        {
            using var connection = CreateConnection();
            
            var parameters = new DynamicParameters();
            parameters.Add("@UserId", userId);
            parameters.Add("@KeyName", dto.KeyName);
            parameters.Add("@ExpiresAt", dto.ExpiresAt);
            parameters.Add("@RateLimit", dto.RateLimit);
            parameters.Add("@GeneratedKey", dbType: DbType.String, size: 100, direction: ParameterDirection.Output);

            await connection.ExecuteAsync(
                "Security.SP_CreateAPIKey",
                parameters,
                commandType: CommandType.StoredProcedure
            );

            var generatedKey = parameters.Get<string>("@GeneratedKey");
            return new ApiKeyCreatedDto
            {
                KeyName = dto.KeyName,
                ApiKey = generatedKey,
                ExpiresAt = dto.ExpiresAt
            };
        }

        public async Task RevokeApiKeyAsync(int apiKeyId)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_RevokeAPIKey",
                new { ApiKeyId = apiKeyId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task ResetApiKeyRateLimitAsync(int apiKeyId)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_ResetAPIKeyRateLimit",
                new { ApiKeyId = apiKeyId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<ApiUsageStatisticsDto> GetApiUsageStatisticsAsync()
        {
            using var connection = CreateConnection();
            
            return await connection.QueryFirstOrDefaultAsync<ApiUsageStatisticsDto>(
                "Security.SP_GetAPIUsageStatistics",
                commandType: CommandType.StoredProcedure
            ) ?? new ApiUsageStatisticsDto();
        }

        #endregion

        #region Notifications

        public async Task CreateNotificationAsync(CreateNotificationDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_CreateNotification",
                new
                {
                    dto.UserId,
                    dto.Title,
                    dto.Message,
                    dto.NotificationType
                },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task SendBulkNotificationsAsync(BulkNotificationDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_SendBulkNotifications",
                new
                {
                    dto.Title,
                    dto.Message,
                    dto.NotificationType,
                    dto.TargetRole,
                    dto.CourseId
                },
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region Lookup & Search

        public async Task<LookupDataDto> GetLookupDataAsync()
        {
            using var connection = CreateConnection();
            
            using var multi = await connection.QueryMultipleAsync(
                "Security.SP_GetLookupData",
                commandType: CommandType.StoredProcedure
            );

            var result = new LookupDataDto
            {
                Branches = (await multi.ReadAsync<LookupItemDto>()).ToList(),
                Tracks = (await multi.ReadAsync<LookupItemDto>()).ToList(),
                Courses = (await multi.ReadAsync<LookupItemDto>()).ToList(),
                Intakes = (await multi.ReadAsync<LookupItemDto>()).ToList()
            };

            return result;
        }

        public async Task<IEnumerable<GlobalSearchResultDto>> GlobalSearchAsync(string searchTerm, string userType = "Admin")
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<GlobalSearchResultDto>(
                "Security.SP_SearchGlobal",
                new { SearchTerm = searchTerm, UserType = userType },
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region Cleanup Jobs

        public async Task CleanupExpiredRefreshTokensAsync()
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_CleanupExpiredRefreshTokens",
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task CleanupExpiredSessionsAsync()
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_CleanupExpiredSessions",
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task CleanupOldNotificationsAsync(int daysOld)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_CleanupOldNotifications",
                new { DaysOld = daysOld },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task CleanupSentEmailsAsync(int daysOld)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_CleanupSentEmails",
                new { DaysOld = daysOld },
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region Branch/Track/Intake Updates

        public async Task UpdateBranchAsync(int managerUserId, int branchId, UpdateBranchDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Academic.SP_Branch_Update",
                new { ManagerUserID = managerUserId, BranchID = branchId, dto.BranchName, dto.BranchLocation, dto.BranchManager, dto.PhoneNumber, dto.Email, dto.IsActive },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task UpdateTrackAsync(int managerUserId, int trackId, UpdateTrackDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Academic.SP_Track_Update",
                new { ManagerUserID = managerUserId, TrackID = trackId, dto.TrackName, dto.TrackDescription, dto.DurationMonths, dto.IsActive },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task UpdateIntakeAsync(int managerUserId, int intakeId, UpdateIntakeDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Academic.SP_Intake_Update",
                new { ManagerUserID = managerUserId, IntakeID = intakeId, dto.IntakeName, dto.IntakeYear, dto.IntakeNumber, dto.StartDate, dto.EndDate, dto.IsActive },
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region Student Enrollment & Grades

        public async Task EnrollStudentInCourseAsync(EnrollStudentDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Academic.SP_Student_EnrollInCourse",
                new { dto.StudentID, dto.CourseID },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<IEnumerable<StudentCourseGradeDto>> GetStudentCourseGradesAsync(int studentId)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<StudentCourseGradeDto>(
                "Academic.SP_Student_GetCourseGrades",
                new { StudentId = studentId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task UpdateCourseFinalGradesAsync(UpdateFinalGradesDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Academic.SP_Instructor_UpdateCourseFinalGrades",
                new { dto.CourseID, dto.InstructorID },
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region EventStore Additional

        public async Task ArchiveOldEventsAsync(int daysOld)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "EventStore.SP_ArchiveOldEvents",
                new { DaysOld = daysOld },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task CreateSnapshotAsync(CreateSnapshotDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "EventStore.SP_CreateSnapshot",
                new { dto.AggregateType, dto.AggregateId, dto.SnapshotData },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<IEnumerable<CorrelatedEventDto>> GetCorrelatedEventsAsync(string correlationId)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<CorrelatedEventDto>(
                "EventStore.SP_GetCorrelatedEvents",
                new { CorrelationId = correlationId },
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region Exam Additional

        public async Task BulkAssignStudentsToExamAsync(BulkAssignStudentsDto dto)
        {
            using var connection = CreateConnection();
            
            // Create a DataTable for the student IDs
            var studentTable = new System.Data.DataTable();
            studentTable.Columns.Add("StudentID", typeof(int));
            foreach (var id in dto.StudentIDs)
            {
                studentTable.Rows.Add(id);
            }

            var parameters = new DynamicParameters();
            parameters.Add("@ExamID", dto.ExamID);
            parameters.Add("@StudentIDs", studentTable.AsTableValuedParameter("dbo.IntList"));

            await connection.ExecuteAsync(
                "Exam.SP_API_BulkAssignStudentsToExam",
                parameters,
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<IEnumerable<AdvancedExamQuestionDto>> GetExamQuestionsAsync(int examId)
        {
            using var connection = CreateConnection();
            
            using var multi = await connection.QueryMultipleAsync(
                "Exam.SP_Exam_GetQuestions",
                new { ExamId = examId },
                commandType: CommandType.StoredProcedure
            );

            var questions = (await multi.ReadAsync<AdvancedExamQuestionDto>()).ToList();
            var options = (await multi.ReadAsync<dynamic>()).ToList();

            foreach (var question in questions)
            {
                question.Options = options
                    .Where(o => (int)o.QuestionID == question.QuestionID)
                    .Select(o => new AdvancedQuestionOptionDto
                    {
                        OptionID = (int)o.OptionID,
                        OptionText = (string)o.OptionText,
                        IsCorrect = (bool)o.IsCorrect
                    }).ToList();
            }

            return questions;
        }

        public async Task<IEnumerable<PaginatedQuestionDto>> GetRandomQuestionsByTypeAsync(RandomQuestionDto dto)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<PaginatedQuestionDto>(
                "Exam.SP_Question_GetRandomByType",
                new { dto.CourseID, dto.QuestionType, dto.Count },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<IEnumerable<StudentExamResultDto>> GetStudentExamResultsAsync(int studentId)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<StudentExamResultDto>(
                "Exam.SP_Student_GetExamResults",
                new { StudentId = studentId },
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region System Statistics

        public async Task<SystemStatisticsDto> GetSystemStatisticsAsync()
        {
            using var connection = CreateConnection();
            
            return await connection.QueryFirstOrDefaultAsync<SystemStatisticsDto>(
                "Security.SP_Admin_GetSystemStatistics",
                commandType: CommandType.StoredProcedure
            ) ?? new SystemStatisticsDto();
        }

        #endregion

        #region Session Management

        public async Task<IEnumerable<UserRefreshTokenDto>> GetUserRefreshTokensAsync(int userId)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryAsync<UserRefreshTokenDto>(
                "Security.SP_GetUserRefreshTokens",
                new { UserId = userId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<ValidateSessionDto> ValidateSessionAsync(int sessionId)
        {
            using var connection = CreateConnection();
            
            return await connection.QueryFirstOrDefaultAsync<ValidateSessionDto>(
                "Security.SP_ValidateSession",
                new { SessionId = sessionId },
                commandType: CommandType.StoredProcedure
            ) ?? new ValidateSessionDto();
        }

        public async Task RefreshSessionAsync(RefreshSessionDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_RefreshSession",
                new { dto.SessionID, dto.ExtendMinutes },
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region API Logging

        public async Task LogApiRequestAsync(LogApiRequestDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_LogAPIRequest",
                new { dto.ApiKeyId, dto.Endpoint, dto.Method, dto.StatusCode, dto.ResponseTimeMs, dto.IpAddress },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<bool> ValidateApiKeyAsync(string apiKey)
        {
            using var connection = CreateConnection();
            
            var result = await connection.QueryFirstOrDefaultAsync<int?>(
                "Security.SP_ValidateAPIKey",
                new { ApiKey = apiKey },
                commandType: CommandType.StoredProcedure
            );

            return result.HasValue && result.Value > 0;
        }

        #endregion

        #region Email Templates

        public async Task SendWelcomeEmailAsync(SendWelcomeEmailDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_SendWelcomeEmail",
                new { dto.UserID, dto.Email, dto.FullName },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task SendPasswordResetEmailAsync(SendPasswordResetEmailDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_SendPasswordResetEmail",
                new { dto.UserID, dto.Email, dto.ResetToken },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task SendExamReminderEmailAsync(SendExamReminderEmailDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Exam.SP_SendExamReminderEmail",
                new { dto.ExamID, dto.StudentID },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task SendGradeEmailAsync(SendGradeEmailDto dto)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Exam.SP_SendGradeEmail",
                new { dto.ExamID, dto.StudentID },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task MarkEmailAsSentAsync(int emailId)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_MarkEmailAsSent",
                new { EmailId = emailId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task MarkEmailAsFailedAsync(int emailId, string error)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_MarkEmailAsFailed",
                new { EmailId = emailId, ErrorMessage = error },
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion

        #region Notifications

        public async Task NotifyExamAssignedAsync(int examId, int studentId)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Exam.SP_NotifyExamAssigned",
                new { ExamId = examId, StudentId = studentId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task NotifyExamReminderAsync(int examId)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Exam.SP_NotifyExamReminder",
                new { ExamId = examId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task NotifyGradeReleasedAsync(int examId, int studentId)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Exam.SP_NotifyGradeReleased",
                new { ExamId = examId, StudentId = studentId },
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task NotifyPasswordResetAsync(int userId)
        {
            using var connection = CreateConnection();
            
            await connection.ExecuteAsync(
                "Security.SP_NotifyPasswordReset",
                new { UserId = userId },
                commandType: CommandType.StoredProcedure
            );
        }

        #endregion
    }
}
