using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IEventRepository
    {
        Task<IEnumerable<UserTimelineEventDto>> GetUserTimelineAsync(int userId, DateTime? startDate, DateTime? endDate, int pageNumber, int pageSize);
        Task<IEnumerable<StudentExamJourneyEventDto>> GetStudentExamJourneyAsync(int studentId, int examId);
    }
}