using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/manager")]
    [Authorize(Roles = "TrainingManager,Admin")]
    public class ManagerController : ControllerBase
    {
        private readonly IManagerService _service;
        public ManagerController(IManagerService service)
        {
            _service = service;
        }

        private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        // Dashboard
        [HttpGet("dashboard")]
        public async Task<ActionResult<ManagerDashboardDto>> GetDashboard()
        {
            var data = await _service.GetDashboardAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpGet("branches")]
        public async Task<ActionResult<IEnumerable<BranchDto>>> GetBranches()
        {
            var data = await _service.GetBranchesAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpGet("branches/{branchId:int}/tracks")]
        public async Task<ActionResult<IEnumerable<TrackDto>>> GetTracksByBranch([FromRoute] int branchId)
        {
            var data = await _service.GetTracksByBranchAsync(CurrentUserId, branchId);
            return Ok(data);
        }

        [HttpGet("intakes")]
        public async Task<ActionResult<IEnumerable<IntakeDto>>> GetIntakes()
        {
            var data = await _service.GetIntakesAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpGet("courses")]
        public async Task<ActionResult<IEnumerable<CourseDto>>> GetCourses([FromQuery] bool includeInactive = false)
        {
            var data = await _service.GetCoursesAsync(CurrentUserId, includeInactive);
            return Ok(data);
        }

        [HttpPost("courses")]
        public async Task<ActionResult<int>> AddCourse([FromBody] CreateCourseDto dto)
        {
            var id = await _service.AddCourseAsync(CurrentUserId, dto);
            return Ok(id);
        }

        [HttpPut("courses/{courseId:int}")]
        public async Task<IActionResult> UpdateCourse([FromRoute] int courseId, [FromBody] UpdateCourseDto dto)
        {
            await _service.UpdateCourseAsync(CurrentUserId, courseId, dto);
            return NoContent();
        }

        [HttpGet("courses/{courseId:int}/instructors")]
        public async Task<ActionResult<IEnumerable<InstructorLiteDto>>> GetCourseInstructors([FromRoute] int courseId)
        {
            var data = await _service.GetCourseInstructorsAsync(CurrentUserId, courseId);
            return Ok(data);
        }

        public record AssignInstructorRequest(int InstructorId, int IntakeId, int BranchId, int TrackId);

        [HttpPost("courses/{courseId:int}/assign-instructor")]
        public async Task<IActionResult> AssignInstructor([FromRoute] int courseId, [FromBody] AssignInstructorRequest req)
        {
            await _service.AssignInstructorToCourseAsync(CurrentUserId, req.InstructorId, courseId, req.IntakeId, req.BranchId, req.TrackId);
            return NoContent();
        }

        [HttpGet("students")]
        public async Task<ActionResult<IEnumerable<StudentLiteDto>>> GetStudents([FromQuery] int? intakeId, [FromQuery] int? branchId, [FromQuery] int? trackId)
        {
            var data = await _service.GetStudentsFilteredAsync(CurrentUserId, intakeId, branchId, trackId);
            return Ok(data);
        }

        [HttpPost("students")]
        public async Task<ActionResult<int>> CreateStudent([FromBody] CreateStudentAccountDto dto)
        {
            var id = await _service.CreateStudentAccountAsync(CurrentUserId, dto);
            return Ok(id);
        }

        [HttpPut("students/{studentId:int}")]
        public async Task<IActionResult> UpdateStudent([FromRoute] int studentId, [FromBody] UpdateStudentDto dto)
        {
            await _service.UpdateStudentAsync(CurrentUserId, studentId, dto);
            return NoContent();
        }

        [HttpDelete("students/{studentId:int}")]
        public async Task<IActionResult> DeactivateStudent([FromRoute] int studentId)
        {
            await _service.DeactivateStudentAsync(CurrentUserId, studentId);
            return NoContent();
        }

        // Instructors
        [HttpGet("instructors")]
        public async Task<ActionResult<IEnumerable<InstructorLiteDto>>> GetInstructors()
        {
            var data = await _service.GetInstructorsAsync(CurrentUserId);
            return Ok(data);
        }

        [HttpPost("instructors")]
        public async Task<ActionResult<int>> CreateInstructor([FromBody] CreateInstructorAccountDto dto)
        {
            var id = await _service.CreateInstructorAccountAsync(CurrentUserId, dto);
            return Ok(id);
        }

        [HttpPut("instructors/{instructorId:int}")]
        public async Task<IActionResult> UpdateInstructor([FromRoute] int instructorId, [FromBody] UpdateInstructorDto dto)
        {
            await _service.UpdateInstructorAsync(CurrentUserId, instructorId, dto);
            return NoContent();
        }

        [HttpDelete("instructors/{instructorId:int}")]
        public async Task<IActionResult> DeactivateInstructor([FromRoute] int instructorId)
        {
            await _service.DeactivateInstructorAsync(CurrentUserId, instructorId);
            return NoContent();
        }

        [HttpPost("branches")]
        public async Task<ActionResult<int>> AddBranch([FromBody] CreateBranchDto dto)
        {
            var id = await _service.AddBranchAsync(CurrentUserId, dto);
            return Ok(id);
        }

        [HttpPut("branches/{branchId:int}")]
        public async Task<IActionResult> UpdateBranch([FromRoute] int branchId, [FromBody] UpdateBranchDto dto)
        {
            await _service.UpdateBranchAsync(CurrentUserId, branchId, dto);
            return NoContent();
        }

        [HttpPost("tracks")]
        public async Task<ActionResult<int>> AddTrack([FromBody] CreateTrackDto dto)
        {
            var id = await _service.AddTrackAsync(CurrentUserId, dto);
            return Ok(id);
        }

        [HttpPut("tracks/{trackId:int}")]
        public async Task<IActionResult> UpdateTrack([FromRoute] int trackId, [FromBody] UpdateTrackDto dto)
        {
            await _service.UpdateTrackAsync(CurrentUserId, trackId, dto);
            return NoContent();
        }

        [HttpPost("intakes")]
        public async Task<ActionResult<int>> AddIntake([FromBody] CreateIntakeDto dto)
        {
            var id = await _service.AddIntakeAsync(CurrentUserId, dto);
            return Ok(id);
        }

        [HttpPut("intakes/{intakeId:int}")]
        public async Task<IActionResult> UpdateIntake([FromRoute] int intakeId, [FromBody] UpdateIntakeDto dto)
        {
            await _service.UpdateIntakeAsync(CurrentUserId, intakeId, dto);
            return NoContent();
        }

        // Enrollments
        [HttpGet("enrollments")]
        public async Task<ActionResult<IEnumerable<EnrollmentDto>>> GetEnrollments([FromQuery] int? courseId, [FromQuery] int? studentId)
        {
            var data = await _service.GetEnrollmentsAsync(CurrentUserId, courseId, studentId);
            return Ok(data);
        }

        public record CreateEnrollmentRequest(int StudentId, int CourseId);

        [HttpPost("enrollments")]
        public async Task<ActionResult<int>> CreateEnrollment([FromBody] CreateEnrollmentRequest req)
        {
            var id = await _service.CreateEnrollmentAsync(CurrentUserId, req.StudentId, req.CourseId);
            return Ok(id);
        }

        [HttpDelete("enrollments/{enrollmentId:int}")]
        public async Task<IActionResult> DeleteEnrollment([FromRoute] int enrollmentId)
        {
            await _service.DeleteEnrollmentAsync(CurrentUserId, enrollmentId);
            return NoContent();
        }

        #region Reports
        [HttpGet("reports/overview")]
        public async Task<ActionResult<Application.Abstractions.ReportOverviewDto>> GetReportOverview([FromQuery] string? period = null)
        {
            var overview = await _service.GetReportOverviewAsync(CurrentUserId, period);
            return Ok(overview);
        }

        [HttpGet("reports/course-performance")]
        public async Task<ActionResult<IEnumerable<Application.Abstractions.CoursePerformanceReportDto>>> GetCoursePerformance([FromQuery] int? courseId = null)
        {
            var courses = await _service.GetCoursePerformanceAsync(CurrentUserId, courseId);
            return Ok(courses);
        }

        [HttpGet("reports/student-performance/{studentId:int}")]
        public async Task<ActionResult<Application.Abstractions.StudentPerformanceReportDto>> GetStudentPerformance([FromRoute] int studentId)
        {
            var student = await _service.GetStudentPerformanceAsync(CurrentUserId, studentId);
            if (student == null)
                return NotFound(new { message = "Student not found" });
            return Ok(student);
        }

        [HttpGet("reports/exam-results")]
        public async Task<ActionResult<IEnumerable<Application.Abstractions.ExamResultReportDto>>> GetExamResults()
        {
            var results = await _service.GetExamResultsAsync(CurrentUserId);
            return Ok(results);
        }
        #endregion
    }
}
