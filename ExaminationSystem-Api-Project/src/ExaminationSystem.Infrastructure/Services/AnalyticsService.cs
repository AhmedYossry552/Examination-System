using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class AnalyticsService : IAnalyticsService
    {
        private readonly IAnalyticsRepository _repo;

        public AnalyticsService(IAnalyticsRepository repo)
        {
            _repo = repo;
        }

        public Task<DashboardOverviewDto> GetDashboardOverviewAsync()
        {
            return _repo.GetDashboardOverviewAsync();
        }

        public Task<IEnumerable<QuestionDifficultyAnalysisDto>> AnalyzeQuestionDifficultyAsync(int? questionId, int? courseId)
        {
            return _repo.AnalyzeQuestionDifficultyAsync(questionId, courseId);
        }

        public Task<StudentPerformancePredictionDto?> PredictStudentPerformanceAsync(int studentId)
        {
            return _repo.PredictStudentPerformanceAsync(studentId);
        }

        public Task<IEnumerable<AtRiskStudentDto>> IdentifyAtRiskStudentsAsync(int? courseId, int? intakeId, decimal? riskThreshold)
        {
            var threshold = riskThreshold ?? 0.6m;
            return _repo.IdentifyAtRiskStudentsAsync(courseId, intakeId, threshold);
        }

        public Task<CoursePerformanceDashboardDto?> GetCoursePerformanceDashboardAsync(int courseId, int? intakeId)
        {
            return _repo.GetCoursePerformanceDashboardAsync(courseId, intakeId);
        }
    }
}
