using System.Security.Claims;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for academic entity management (Branches, Tracks, Intakes)
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin,Manager")]
    public class AcademicManagementController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public AcademicManagementController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                ?? User.FindFirst("userId")?.Value 
                ?? User.FindFirst("sub")?.Value;
            return int.TryParse(userIdClaim, out var userId) ? userId : 0;
        }

        #region Branch Management

        /// <summary>
        /// Update a branch
        /// </summary>
        [HttpPut("branches/{branchId}")]
        public async Task<IActionResult> UpdateBranch(int branchId, [FromBody] UpdateBranchDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid branch data" });

            var userId = GetCurrentUserId();
            await _service.UpdateBranchAsync(userId, branchId, dto);
            return Ok(new { message = "Branch updated successfully" });
        }

        #endregion

        #region Track Management

        /// <summary>
        /// Update a track
        /// </summary>
        [HttpPut("tracks/{trackId}")]
        public async Task<IActionResult> UpdateTrack(int trackId, [FromBody] UpdateTrackDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid track data" });

            var userId = GetCurrentUserId();
            await _service.UpdateTrackAsync(userId, trackId, dto);
            return Ok(new { message = "Track updated successfully" });
        }

        #endregion

        #region Intake Management

        /// <summary>
        /// Update an intake
        /// </summary>
        [HttpPut("intakes/{intakeId}")]
        public async Task<IActionResult> UpdateIntake(int intakeId, [FromBody] UpdateIntakeDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid intake data" });

            var userId = GetCurrentUserId();
            await _service.UpdateIntakeAsync(userId, intakeId, dto);
            return Ok(new { message = "Intake updated successfully" });
        }

        #endregion

        #region Student Enrollment

        /// <summary>
        /// Enroll a student in a course
        /// </summary>
        [HttpPost("students/enroll")]
        public async Task<IActionResult> EnrollStudent([FromBody] EnrollStudentDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid enrollment data" });

            await _service.EnrollStudentInCourseAsync(dto);
            return Ok(new { message = "Student enrolled successfully" });
        }

        /// <summary>
        /// Get student course grades
        /// </summary>
        [HttpGet("students/{studentId}/grades")]
        public async Task<IActionResult> GetStudentGrades(int studentId)
        {
            var grades = await _service.GetStudentCourseGradesAsync(studentId);
            return Ok(grades);
        }

        /// <summary>
        /// Update final grades for a course
        /// </summary>
        [HttpPost("courses/final-grades")]
        public async Task<IActionResult> UpdateFinalGrades([FromBody] UpdateFinalGradesDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid data" });

            await _service.UpdateCourseFinalGradesAsync(dto);
            return Ok(new { message = "Final grades updated successfully" });
        }

        #endregion
    }
}
