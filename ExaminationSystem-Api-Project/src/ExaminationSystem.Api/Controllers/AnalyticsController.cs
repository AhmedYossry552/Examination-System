using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/analytics")]
    [Authorize(Roles = "Admin,TrainingManager,Instructor")]
    public class AnalyticsController : ControllerBase
    {
        private readonly IAnalyticsService _service;

        public AnalyticsController(IAnalyticsService service)
        {
            _service = service;
        }

        [HttpGet("dashboard")]
        [Authorize(Roles = "Admin,TrainingManager")]
        public async Task<ActionResult<DashboardOverviewDto>> GetDashboardOverview()
        {
            var result = await _service.GetDashboardOverviewAsync();
            return Ok(result);
        }

        [HttpGet("questions/difficulty")]
        [Authorize(Roles = "Admin,TrainingManager,Instructor")]
        public async Task<ActionResult<IEnumerable<QuestionDifficultyAnalysisDto>>> AnalyzeQuestionDifficulty(
            [FromQuery] int? questionId = null,
            [FromQuery] int? courseId = null)
        {
            var result = await _service.AnalyzeQuestionDifficultyAsync(questionId, courseId);
            return Ok(result);
        }

        [HttpGet("students/{studentId:int}/prediction")]
        [Authorize(Roles = "Admin,TrainingManager")]
        public async Task<ActionResult<StudentPerformancePredictionDto>> PredictStudentPerformance([FromRoute] int studentId)
        {
            var result = await _service.PredictStudentPerformanceAsync(studentId);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpGet("at-risk-students")]
        [Authorize(Roles = "Admin,TrainingManager")]
        public async Task<ActionResult<IEnumerable<AtRiskStudentDto>>> IdentifyAtRiskStudents(
            [FromQuery] int? courseId = null,
            [FromQuery] int? intakeId = null,
            [FromQuery] decimal? riskThreshold = null)
        {
            var result = await _service.IdentifyAtRiskStudentsAsync(courseId, intakeId, riskThreshold);
            return Ok(result);
        }

        [HttpGet("courses/{courseId:int}/performance")]
        [Authorize(Roles = "Admin,TrainingManager,Instructor")]
        public async Task<ActionResult<CoursePerformanceDashboardDto>> GetCoursePerformanceDashboard(
            [FromRoute] int courseId,
            [FromQuery] int? intakeId = null)
        {
            var result = await _service.GetCoursePerformanceDashboardAsync(courseId, intakeId);
            if (result == null) return NotFound();
            return Ok(result);
        }
    }
}
