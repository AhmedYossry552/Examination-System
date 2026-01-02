using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using ExaminationSystem.Application.Abstractions;

namespace ExaminationSystem.Api.Controllers
{
    [ApiController]
    [Route("api/v1/events")]
    public class EventController : ControllerBase
    {
        private readonly IEventService _service;
        public EventController(IEventService service)
        {
            _service = service;
        }

        // User activity timeline
        [HttpGet("user/{userId:int}/timeline")]
        [Authorize(Roles = "Admin,TrainingManager,Instructor")]
        public async Task<IActionResult> GetUserTimeline(
            int userId,
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 50)
        {
            var result = await _service.GetUserTimelineAsync(userId, startDate, endDate, pageNumber, pageSize);
            return Ok(result);
        }

        // Student exam journey
        [HttpGet("students/{studentId:int}/exams/{examId:int}/journey")]
        [Authorize(Roles = "Admin,TrainingManager,Instructor")]
        public async Task<IActionResult> GetStudentExamJourney(int studentId, int examId)
        {
            var result = await _service.GetStudentExamJourneyAsync(studentId, examId);
            return Ok(result);
        }
    }
}