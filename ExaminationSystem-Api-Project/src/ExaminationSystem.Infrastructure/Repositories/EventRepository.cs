using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class EventRepository : IEventRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;
        public EventRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IEnumerable<UserTimelineEventDto>> GetUserTimelineAsync(int userId, DateTime? startDate, DateTime? endDate, int pageNumber, int pageSize)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@StartDate", startDate);
            p.Add("@EndDate", endDate);
            p.Add("@PageNumber", pageNumber);
            p.Add("@PageSize", pageSize);
            return await conn.QueryAsync<UserTimelineEventDto>("EventStore.SP_GetUserTimeline", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<StudentExamJourneyEventDto>> GetStudentExamJourneyAsync(int studentId, int examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            p.Add("@ExamID", examId);
            return await conn.QueryAsync<StudentExamJourneyEventDto>("EventStore.SP_GetStudentExamJourney", p, commandType: CommandType.StoredProcedure);
        }
    }
}