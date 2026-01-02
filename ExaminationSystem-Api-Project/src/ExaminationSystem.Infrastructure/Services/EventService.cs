using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class EventService : IEventService
    {
        private readonly IEventRepository _repo;
        public EventService(IEventRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<UserTimelineEventDto>> GetUserTimelineAsync(int userId, DateTime? startDate, DateTime? endDate, int pageNumber, int pageSize)
        {
            return _repo.GetUserTimelineAsync(userId, startDate, endDate, pageNumber, pageSize);
        }

        public Task<IEnumerable<StudentExamJourneyEventDto>> GetStudentExamJourneyAsync(int studentId, int examId)
        {
            return _repo.GetStudentExamJourneyAsync(studentId, examId);
        }
    }
}