using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IMonitoringService
    {
        Task<IEnumerable<LiveExamMonitoringDto>> GetLiveExamMonitoringAsync(
            int? examId,
            int? studentId);

        Task<IEnumerable<ExamSessionStatisticsDto>> GetExamSessionStatisticsAsync(
            int? examId);

        Task<IEnumerable<SuspiciousActivityDto>> GetSuspiciousActivityAsync(
            int? studentId,
            int? studentExamId);
    }
}
