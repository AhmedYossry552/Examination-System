using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem.Api.Controllers
{
    /// <summary>
    /// Controller for advanced system features
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AdvancedFeaturesController : ControllerBase
    {
        private readonly IAdvancedFeaturesService _service;

        public AdvancedFeaturesController(IAdvancedFeaturesService service)
        {
            _service = service;
        }

        #region Pagination Endpoints

        /// <summary>
        /// Get students with pagination
        /// </summary>
        [HttpGet("students/paginated")]
        public async Task<IActionResult> GetStudentsPaginated(
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? searchTerm = null)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize < 1) pageSize = 10;
            if (pageSize > 100) pageSize = 100;

            var result = await _service.GetStudentsPaginatedAsync(pageNumber, pageSize, searchTerm);
            return Ok(result);
        }

        /// <summary>
        /// Get exams with pagination
        /// </summary>
        [HttpGet("exams/paginated")]
        public async Task<IActionResult> GetExamsPaginated(
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? searchTerm = null)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize < 1) pageSize = 10;
            if (pageSize > 100) pageSize = 100;

            var result = await _service.GetExamsPaginatedAsync(pageNumber, pageSize, searchTerm);
            return Ok(result);
        }

        /// <summary>
        /// Get questions with pagination
        /// </summary>
        [HttpGet("questions/paginated")]
        public async Task<IActionResult> GetQuestionsPaginated(
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] int? courseId = null)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize < 1) pageSize = 10;
            if (pageSize > 100) pageSize = 100;

            var result = await _service.GetQuestionsPaginatedAsync(pageNumber, pageSize, courseId);
            return Ok(result);
        }

        #endregion

        #region Lookup & Search Endpoints

        /// <summary>
        /// Get lookup data (branches, tracks, courses, roles)
        /// </summary>
        [HttpGet("lookup")]
        [AllowAnonymous]
        public async Task<IActionResult> GetLookupData()
        {
            var result = await _service.GetLookupDataAsync();
            return Ok(result);
        }

        /// <summary>
        /// Global search across all entities
        /// </summary>
        [HttpGet("search")]
        public async Task<IActionResult> GlobalSearch([FromQuery] string q)
        {
            if (string.IsNullOrWhiteSpace(q))
                return BadRequest(new { message = "Search term is required" });

            var results = await _service.GlobalSearchAsync(q);
            return Ok(results);
        }

        #endregion
    }
}
