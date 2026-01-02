using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class MonitoringService : IMonitoringService
    {
        private readonly IMonitoringRepository _repo;

        public MonitoringService(IMonitoringRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<LiveExamMonitoringDto>> GetLiveExamMonitoringAsync(int? examId, int? studentId)
        {
            return _repo.GetLiveExamMonitoringAsync(examId, studentId);
        }

        public Task<IEnumerable<ExamSessionStatisticsDto>> GetExamSessionStatisticsAsync(int? examId)
        {
            return _repo.GetExamSessionStatisticsAsync(examId);
        }

        public Task<IEnumerable<SuspiciousActivityDto>> GetSuspiciousActivityAsync(int? studentId, int? studentExamId)
        {
            return _repo.GetSuspiciousActivityAsync(studentId, studentExamId);
        }
    }
}
