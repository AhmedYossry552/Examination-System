using System;

namespace ExaminationSystem.Application.Abstractions.Models
{
    public class UserTimelineEventDto
    {
        public long EventID { get; set; }
        public string EventType { get; set; } = string.Empty;
        public string AggregateType { get; set; } = string.Empty;
        public string AggregateID { get; set; } = string.Empty;
        public string EventData { get; set; } = string.Empty;
        public DateTime OccurredAt { get; set; }
        public string? IPAddress { get; set; }
        public int TotalRecords { get; set; }
        public int TotalPages { get; set; }
    }

    public class StudentExamJourneyEventDto
    {
        public long EventID { get; set; }
        public string EventType { get; set; } = string.Empty;
        public string EventData { get; set; } = string.Empty;
        public DateTime OccurredAt { get; set; }
        public int? SecondsSinceLastEvent { get; set; }
    }
}