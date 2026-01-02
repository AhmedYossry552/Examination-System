using System;
using System.Collections.Generic;

namespace ExaminationSystem.Application.Abstractions.Models
{
    // ============== Pagination DTOs ==============
    public class PaginatedResult<T>
    {
        public List<T> Items { get; set; } = new();
        public int TotalCount { get; set; }
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
        public bool HasPreviousPage => PageNumber > 1;
        public bool HasNextPage => PageNumber < TotalPages;
    }

    public class PaginatedStudentDto
    {
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string BranchName { get; set; } = string.Empty;
        public string TrackName { get; set; } = string.Empty;
        public string IntakeName { get; set; } = string.Empty;
        public decimal? GPA { get; set; }
        public bool IsActive { get; set; }
    }

    public class PaginatedExamDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public string InstructorName { get; set; } = string.Empty;
        public string ExamType { get; set; } = string.Empty;
        public int TotalMarks { get; set; }
        public int DurationMinutes { get; set; }
        public DateTime StartDateTime { get; set; }
        public DateTime EndDateTime { get; set; }
        public string ExamStatus { get; set; } = string.Empty;
        public int AssignedStudents { get; set; }
        public int CompletedCount { get; set; }
    }

    public class PaginatedQuestionDto
    {
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public string DifficultyLevel { get; set; } = string.Empty;
        public int Points { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CreatorName { get; set; } = string.Empty;
        public DateTime CreatedDate { get; set; }
    }

    // ============== Remedial Exam DTOs ==============
    public class RemedialCandidateDto
    {
        public int StudentID { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public decimal Score { get; set; }
        public decimal PassMarks { get; set; }
        public bool IsEligible { get; set; }
    }

    public class RemedialProgressDto
    {
        public int TotalCandidates { get; set; }
        public int AssignedCount { get; set; }
        public int CompletedCount { get; set; }
        public int PassedCount { get; set; }
        public decimal PassRate { get; set; }
    }

    public class StudentRemedialHistoryDto
    {
        public int RemedialExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public decimal OriginalScore { get; set; }
        public decimal? RemedialScore { get; set; }
        public DateTime? AttemptDate { get; set; }
        public bool? IsPassed { get; set; }
        public string Status { get; set; } = string.Empty;
    }

    // ============== Email Queue DTOs ==============
    public class EmailQueueStatusDto
    {
        public int TotalEmails { get; set; }
        public int PendingCount { get; set; }
        public int SentCount { get; set; }
        public int FailedCount { get; set; }
        public int ScheduledCount { get; set; }
        public DateTime? LastProcessedAt { get; set; }
    }

    public class EmailQueueItemDto
    {
        public int EmailID { get; set; }
        public string RecipientEmail { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? SentAt { get; set; }
        public int RetryCount { get; set; }
    }

    public class ScheduleEmailDto
    {
        public string RecipientEmail { get; set; } = string.Empty;
        public string RecipientName { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public DateTime? ScheduledFor { get; set; }
        public int Priority { get; set; } = 1;
    }

    // ============== Event Store DTOs ==============
    public class EventDto
    {
        public long EventID { get; set; }
        public string AggregateType { get; set; } = string.Empty;
        public int AggregateID { get; set; }
        public string EventType { get; set; } = string.Empty;
        public string EventData { get; set; } = string.Empty;
        public int? UserID { get; set; }
        public string? Username { get; set; }
        public DateTime CreatedAt { get; set; }
        public string? CorrelationID { get; set; }
    }

    public class AppendEventDto
    {
        public string AggregateType { get; set; } = string.Empty;
        public int AggregateId { get; set; }
        public string EventType { get; set; } = string.Empty;
        public string EventData { get; set; } = string.Empty;
        public string? CorrelationID { get; set; }
    }

    public class SystemActivityDto
    {
        public string ActivityType { get; set; } = string.Empty;
        public int Count { get; set; }
        public DateTime LastOccurrence { get; set; }
    }

    public class EventStatisticsDto
    {
        public string EventType { get; set; } = string.Empty;
        public int TotalCount { get; set; }
        public int TodayCount { get; set; }
        public int ThisWeekCount { get; set; }
        public int ThisMonthCount { get; set; }
    }

    // ============== API Key DTOs ==============
    public class ApiKeyDto
    {
        public int ApiKeyID { get; set; }
        public string KeyName { get; set; } = string.Empty;
        public string KeyPrefix { get; set; } = string.Empty;
        public string Permissions { get; set; } = string.Empty;
        public int? RateLimitPerMinute { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ExpiresAt { get; set; }
        public DateTime? LastUsedAt { get; set; }
        public bool IsActive { get; set; }
        public int TotalRequests { get; set; }
    }

    public class CreateApiKeyDto
    {
        public string KeyName { get; set; } = string.Empty;
        public string Permissions { get; set; } = string.Empty;
        public int? RateLimitPerMinute { get; set; }
        public int? ExpiresInDays { get; set; }
        public DateTime? ExpiresAt { get; set; }
        public int? RateLimit { get; set; }
    }

    public class ApiKeyCreatedDto
    {
        public int ApiKeyID { get; set; }
        public string KeyName { get; set; } = string.Empty;
        public string ApiKey { get; set; } = string.Empty; // Only shown once
        public DateTime CreatedAt { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }

    public class ApiUsageStatisticsDto
    {
        public int TotalRequests { get; set; }
        public int TodayRequests { get; set; }
        public int SuccessfulRequests { get; set; }
        public int FailedRequests { get; set; }
        public decimal AverageResponseTime { get; set; }
        public List<ApiUsageByEndpointDto> TopEndpoints { get; set; } = new();
    }

    public class ApiUsageByEndpointDto
    {
        public string Endpoint { get; set; } = string.Empty;
        public int RequestCount { get; set; }
        public decimal AverageResponseTime { get; set; }
    }

    // ============== Notification DTOs ==============
    public class CreateNotificationDto
    {
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string NotificationType { get; set; } = string.Empty;
        public string? ActionUrl { get; set; }
    }

    public class BulkNotificationDto
    {
        public List<int> UserIDs { get; set; } = new();
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string NotificationType { get; set; } = string.Empty;
        public string? TargetRole { get; set; }
        public int? CourseId { get; set; }
    }

    // ============== Lookup DTOs ==============
    public class LookupDataDto
    {
        public List<LookupItemDto> Branches { get; set; } = new();
        public List<LookupItemDto> Tracks { get; set; } = new();
        public List<LookupItemDto> Intakes { get; set; } = new();
        public List<LookupItemDto> Courses { get; set; } = new();
        public List<LookupItemDto> Instructors { get; set; } = new();
    }

    public class LookupItemDto
    {
        public int ID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
    }

    // ============== Global Search DTO ==============
    public class GlobalSearchResultDto
    {
        public string ResultType { get; set; } = string.Empty;
        public int ID { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? Url { get; set; }
    }

    // ============== Student Enrollment DTOs ==============
    public class EnrollStudentDto
    {
        public int StudentID { get; set; }
        public int CourseID { get; set; }
    }

    public class StudentCourseGradeDto
    {
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public decimal? ExamScore { get; set; }
        public decimal? FinalGrade { get; set; }
        public string? GradeLetter { get; set; }
        public bool IsPassed { get; set; }
    }

    public class UpdateFinalGradesDto
    {
        public int CourseID { get; set; }
        public int InstructorID { get; set; }
    }

    // ============== EventStore Additional DTOs ==============
    public class ArchiveEventsDto
    {
        public int DaysOld { get; set; } = 90;
    }

    public class CreateSnapshotDto
    {
        public string AggregateType { get; set; } = string.Empty;
        public int AggregateId { get; set; }
        public string SnapshotData { get; set; } = string.Empty;
    }

    public class CorrelatedEventDto
    {
        public long EventID { get; set; }
        public string AggregateType { get; set; } = string.Empty;
        public int AggregateID { get; set; }
        public string EventType { get; set; } = string.Empty;
        public string EventData { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public string? CorrelationID { get; set; }
    }

    // ============== Exam Additional DTOs ==============
    public class BulkAssignStudentsDto
    {
        public int ExamID { get; set; }
        public List<int> StudentIDs { get; set; } = new();
    }

    public class AdvancedExamQuestionDto
    {
        public int QuestionID { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string QuestionType { get; set; } = string.Empty;
        public int Points { get; set; }
        public int QuestionOrder { get; set; }
        public List<AdvancedQuestionOptionDto> Options { get; set; } = new();
    }

    public class AdvancedQuestionOptionDto
    {
        public int OptionID { get; set; }
        public string OptionText { get; set; } = string.Empty;
        public bool IsCorrect { get; set; }
    }

    public class RandomQuestionDto
    {
        public int CourseID { get; set; }
        public string QuestionType { get; set; } = string.Empty;
        public int Count { get; set; } = 1;
    }

    public class StudentExamResultDto
    {
        public int ExamID { get; set; }
        public string ExamName { get; set; } = string.Empty;
        public string CourseName { get; set; } = string.Empty;
        public decimal Score { get; set; }
        public decimal TotalMarks { get; set; }
        public decimal Percentage { get; set; }
        public bool IsPassed { get; set; }
        public DateTime? CompletedAt { get; set; }
    }

    // ============== System Statistics DTO ==============
    public class SystemStatisticsDto
    {
        public int TotalUsers { get; set; }
        public int TotalStudents { get; set; }
        public int TotalInstructors { get; set; }
        public int TotalCourses { get; set; }
        public int TotalExams { get; set; }
        public int TotalQuestions { get; set; }
        public int ActiveExams { get; set; }
        public int ExamsCompletedToday { get; set; }
        public int NewUsersThisWeek { get; set; }
    }

    // ============== Session/Token DTOs ==============
    public class UserRefreshTokenDto
    {
        public int TokenID { get; set; }
        public string Token { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsRevoked { get; set; }
        public string? DeviceInfo { get; set; }
    }

    public class ValidateSessionDto
    {
        public int SessionID { get; set; }
        public int UserID { get; set; }
        public bool IsValid { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }

    public class RefreshSessionDto
    {
        public int SessionID { get; set; }
        public int ExtendMinutes { get; set; } = 30;
    }

    // ============== API Logging DTO ==============
    public class LogApiRequestDto
    {
        public int? ApiKeyId { get; set; }
        public string Endpoint { get; set; } = string.Empty;
        public string Method { get; set; } = string.Empty;
        public int StatusCode { get; set; }
        public int ResponseTimeMs { get; set; }
        public string? IpAddress { get; set; }
    }

    // ============== Email Template DTOs ==============
    public class SendWelcomeEmailDto
    {
        public int UserID { get; set; }
        public string Email { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
    }

    public class SendPasswordResetEmailDto
    {
        public int UserID { get; set; }
        public string Email { get; set; } = string.Empty;
        public string ResetToken { get; set; } = string.Empty;
    }

    public class SendExamReminderEmailDto
    {
        public int ExamID { get; set; }
        public int StudentID { get; set; }
    }

    public class SendGradeEmailDto
    {
        public int ExamID { get; set; }
        public int StudentID { get; set; }
    }
}
