using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class MonitoringRepository : IMonitoringRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;

        public MonitoringRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IEnumerable<LiveExamMonitoringDto>> GetLiveExamMonitoringAsync(int? examId, int? studentId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Exam.VW_LiveExamMonitoring
                        WHERE (@ExamID IS NULL OR ExamID = @ExamID)
                          AND (@StudentID IS NULL OR StudentID = @StudentID)";

            var p = new DynamicParameters();
            p.Add("@ExamID", examId);
            p.Add("@StudentID", studentId);

            var result = await conn.QueryAsync<LiveExamMonitoringDto>(sql, p);
            return result;
        }

        public async Task<IEnumerable<ExamSessionStatisticsDto>> GetExamSessionStatisticsAsync(int? examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Exam.VW_ExamSessionStatistics
                        WHERE (@ExamID IS NULL OR ExamID = @ExamID)";

            var p = new DynamicParameters();
            p.Add("@ExamID", examId);

            var result = await conn.QueryAsync<ExamSessionStatisticsDto>(sql, p);
            return result;
        }

        public async Task<IEnumerable<SuspiciousActivityDto>> GetSuspiciousActivityAsync(int? studentId, int? studentExamId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Exam.VW_SuspiciousActivityMonitor
                        WHERE (@StudentID IS NULL OR StudentID = @StudentID)
                          AND (@StudentExamID IS NULL OR StudentExamID = @StudentExamID)";

            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            p.Add("@StudentExamID", studentExamId);

            var result = await conn.QueryAsync<SuspiciousActivityDto>(sql, p);
            return result;
        }
    }
}
