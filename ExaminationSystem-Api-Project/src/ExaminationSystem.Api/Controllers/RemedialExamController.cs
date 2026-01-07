using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for remedial exam management
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize(Roles = "Admin,TrainingManager,Instructor")]
    public class RemedialExamController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public RemedialExamController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        /// <summary>
        /// Get candidates eligible for remedial exams
        /// </summary>
        [HttpGet("candidates")]
        public async Task<IActionResult> GetCandidates([FromQuery] int examId)
        {
            var candidates = await _service.GetRemedialCandidatesAsync(examId);
            return Ok(candidates);
        }

        /// <summary>
        /// Get remedial exam progress statistics
        /// </summary>
        [HttpGet("progress")]
        public async Task<IActionResult> GetProgress()
        {
            var progress = await _service.GetRemedialProgressAsync();
            return Ok(progress);
        }

        /// <summary>
        /// Get remedial exam history for a student
        /// </summary>
        [HttpGet("student/{studentId}/history")]
        public async Task<IActionResult> GetStudentHistory(int studentId)
        {
            var history = await _service.GetStudentRemedialHistoryAsync(studentId);
            return Ok(history);
        }

        /// <summary>
        /// Auto-assign remedial exams to eligible students
        /// </summary>
        [HttpPost("auto-assign")]
        [Authorize(Roles = "Admin,TrainingManager")]
        public async Task<IActionResult> AutoAssign()
        {
            await _service.AutoAssignRemedialExamsAsync();
            return Ok(new { message = "Remedial exams auto-assigned successfully" });
        }
    }
}
