using System;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class ActiveSessionDto
    {
        public int SessionID { get; set; }
        public string SessionToken { get; set; } = string.Empty;
        public string? IPAddress { get; set; }
        public string? UserAgent { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime ExpiresAt { get; set; }
        public DateTime LastActivityDate { get; set; }
        public int MinutesSinceActivity { get; set; }
        public int MinutesUntilExpiry { get; set; }
    }

    public class SessionHistoryDto
    {
        public int SessionID { get; set; }
        public int UserID { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string UserType { get; set; } = string.Empty;
        public string? IPAddress { get; set; }
        public string? UserAgent { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime ExpiresAt { get; set; }
        public DateTime LastActivityDate { get; set; }
        public bool IsActive { get; set; }
        public int SessionDurationMinutes { get; set; }
    }
}
