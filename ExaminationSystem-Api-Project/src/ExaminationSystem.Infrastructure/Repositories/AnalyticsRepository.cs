using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class AnalyticsRepository : IAnalyticsRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;

        public AnalyticsRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<DashboardOverviewDto> GetDashboardOverviewAsync()
        {
            using var conn = _connectionFactory.CreateConnection();
            const string sql = "SELECT TOP 1 * FROM Security.VW_DashboardOverview";
            return await conn.QuerySingleAsync<DashboardOverviewDto>(sql);
        }

        public async Task<IEnumerable<QuestionDifficultyAnalysisDto>> AnalyzeQuestionDifficultyAsync(int? questionId, int? courseId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@QuestionID", questionId);
            p.Add("@CourseID", courseId);
            var result = await conn.QueryAsync<QuestionDifficultyAnalysisDto>(
                "Analytics.SP_AnalyzeQuestionDifficulty",
                p,
                commandType: CommandType.StoredProcedure);
            return result;
        }

        public async Task<StudentPerformancePredictionDto?> PredictStudentPerformanceAsync(int studentId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            var result = await conn.QuerySingleOrDefaultAsync<StudentPerformancePredictionDto>(
                "Analytics.SP_PredictStudentPerformance",
                p,
                commandType: CommandType.StoredProcedure);
            return result;
        }

        public async Task<IEnumerable<AtRiskStudentDto>> IdentifyAtRiskStudentsAsync(int? courseId, int? intakeId, decimal riskThreshold)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@CourseID", courseId);
            p.Add("@IntakeID", intakeId);
            p.Add("@RiskThreshold", riskThreshold);
            var result = await conn.QueryAsync<AtRiskStudentDto>(
                "Analytics.SP_IdentifyAtRiskStudents",
                p,
                commandType: CommandType.StoredProcedure);
            return result;
        }

        public async Task<CoursePerformanceDashboardDto?> GetCoursePerformanceDashboardAsync(int courseId, int? intakeId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@CourseID", courseId);
            p.Add("@IntakeID", intakeId);

            using var multi = await conn.QueryMultipleAsync(
                "Analytics.SP_GetCoursePerformanceDashboard",
                p,
                commandType: CommandType.StoredProcedure);

            var overview = await multi.ReadSingleOrDefaultAsync<CoursePerformanceOverviewDto>();
            if (overview == null)
            {
                return null;
            }

            var questions = (await multi.ReadAsync<CourseQuestionPerformanceDto>()).AsList();
            return new CoursePerformanceDashboardDto
            {
                Overview = overview,
                Questions = new List<CourseQuestionPerformanceDto>(questions)
            };
        }
    }
}
