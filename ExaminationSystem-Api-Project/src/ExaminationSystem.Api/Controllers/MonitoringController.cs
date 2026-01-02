using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/monitoring")]
    [Authorize(Roles = "Admin,TrainingManager,Instructor")]
    public class MonitoringController : ControllerBase
    {
        private readonly IMonitoringService _service;

        public MonitoringController(IMonitoringService service)
        {
            _service = service;
        }

        [HttpGet("live-exams")]
        public async Task<ActionResult<IEnumerable<LiveExamMonitoringDto>>> GetLiveExamMonitoring(
            [FromQuery] int? examId = null,
            [FromQuery] int? studentId = null)
        {
            var result = await _service.GetLiveExamMonitoringAsync(examId, studentId);
            return Ok(result);
        }

        [HttpGet("exam-sessions")]
        public async Task<ActionResult<IEnumerable<ExamSessionStatisticsDto>>> GetExamSessionStatistics(
            [FromQuery] int? examId = null)
        {
            var result = await _service.GetExamSessionStatisticsAsync(examId);
            return Ok(result);
        }

        [HttpGet("suspicious-activity")]
        [Authorize(Roles = "Admin,TrainingManager,Instructor")]
        public async Task<ActionResult<IEnumerable<SuspiciousActivityDto>>> GetSuspiciousActivity(
            [FromQuery] int? studentId = null,
            [FromQuery] int? studentExamId = null)
        {
            var result = await _service.GetSuspiciousActivityAsync(studentId, studentExamId);
            return Ok(result);
        }
    }
}
