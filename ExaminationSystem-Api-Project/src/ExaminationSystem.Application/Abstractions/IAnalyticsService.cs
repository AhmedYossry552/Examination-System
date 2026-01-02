using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IAnalyticsService
    {
        Task<DashboardOverviewDto> GetDashboardOverviewAsync();

        Task<IEnumerable<QuestionDifficultyAnalysisDto>> AnalyzeQuestionDifficultyAsync(
            int? questionId,
            int? courseId);

        Task<StudentPerformancePredictionDto?> PredictStudentPerformanceAsync(int studentId);

        Task<IEnumerable<AtRiskStudentDto>> IdentifyAtRiskStudentsAsync(
            int? courseId,
            int? intakeId,
            decimal? riskThreshold);

        Task<CoursePerformanceDashboardDto?> GetCoursePerformanceDashboardAsync(
            int courseId,
            int? intakeId);
    }
}
