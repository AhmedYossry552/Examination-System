using System;
using System.Collections.Generic;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class NotificationDto
    {
        public int NotificationID { get; set; }
        public string NotificationType { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string? RelatedEntityType { get; set; }
        public int? RelatedEntityID { get; set; }
        public bool IsRead { get; set; }
        public DateTime? ReadDate { get; set; }
        public string Priority { get; set; } = string.Empty;
        public DateTime CreatedDate { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }

    public class PagedNotificationsDto
    {
        public List<NotificationDto> Items { get; set; } = new List<NotificationDto>();
        public int TotalCount { get; set; }
    }

    public class UnreadCountDto
    {
        public int UnreadCount { get; set; }
    }
}
