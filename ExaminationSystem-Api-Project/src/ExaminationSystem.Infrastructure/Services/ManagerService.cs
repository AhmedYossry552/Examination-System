using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Services
{
    public class ManagerService : IManagerService
    {
        private readonly IManagerRepository _repo;
        public ManagerService(IManagerRepository repo)
        {
            _repo = repo;
        }

        public Task<ManagerDashboardDto> GetDashboardAsync(int userId) => _repo.GetDashboardAsync();

        public Task<IEnumerable<BranchDto>> GetBranchesAsync(int userId) => _repo.GetBranchesAsync();

        public Task<IEnumerable<TrackDto>> GetTracksByBranchAsync(int userId, int branchId) => _repo.GetTracksByBranchAsync(branchId);

        public Task<IEnumerable<IntakeDto>> GetIntakesAsync(int userId) => _repo.GetIntakesAsync();

        public Task<IEnumerable<CourseDto>> GetCoursesAsync(int userId, bool includeInactive = false) => _repo.GetCoursesAsync(includeInactive);

        public Task<int> AddCourseAsync(int userId, CreateCourseDto dto) => _repo.AddCourseAsync(userId, dto);

        public Task UpdateCourseAsync(int userId, int courseId, UpdateCourseDto dto) => _repo.UpdateCourseAsync(userId, courseId, dto);

        public Task<IEnumerable<InstructorLiteDto>> GetCourseInstructorsAsync(int userId, int courseId) => _repo.GetCourseInstructorsAsync(courseId);

        public async Task AssignInstructorToCourseAsync(int userId, int instructorId, int courseId, int intakeId, int branchId, int trackId)
            => await _repo.AssignInstructorToCourseAsync(instructorId, courseId, intakeId, branchId, trackId);

        public Task<IEnumerable<StudentLiteDto>> GetStudentsFilteredAsync(int userId, int? intakeId, int? branchId, int? trackId)
            => _repo.GetStudentsFilteredAsync(intakeId, branchId, trackId);

        public Task<int> CreateStudentAccountAsync(int userId, CreateStudentAccountDto dto)
            => _repo.CreateStudentAccountAsync(dto);

        public Task UpdateStudentAsync(int userId, int studentId, UpdateStudentDto dto)
            => _repo.UpdateStudentAsync(studentId, dto);

        public Task DeactivateStudentAsync(int userId, int studentId)
            => _repo.DeactivateStudentAsync(userId, studentId);

        public Task<IEnumerable<InstructorLiteDto>> GetInstructorsAsync(int userId)
            => _repo.GetInstructorsAsync();

        public Task<int> CreateInstructorAccountAsync(int userId, CreateInstructorAccountDto dto)
            => _repo.CreateInstructorAccountAsync(dto);

        public Task UpdateInstructorAsync(int userId, int instructorId, UpdateInstructorDto dto)
            => _repo.UpdateInstructorAsync(instructorId, dto);

        public Task DeactivateInstructorAsync(int userId, int instructorId)
            => _repo.DeactivateInstructorAsync(userId, instructorId);

        public Task<int> AddBranchAsync(int userId, CreateBranchDto dto)
            => _repo.AddBranchAsync(userId, dto);

        public Task UpdateBranchAsync(int userId, int branchId, UpdateBranchDto dto)
            => _repo.UpdateBranchAsync(userId, branchId, dto);

        public Task<int> AddTrackAsync(int userId, CreateTrackDto dto)
            => _repo.AddTrackAsync(userId, dto);

        public Task UpdateTrackAsync(int userId, int trackId, UpdateTrackDto dto)
            => _repo.UpdateTrackAsync(userId, trackId, dto);

        public Task<int> AddIntakeAsync(int userId, CreateIntakeDto dto)
            => _repo.AddIntakeAsync(userId, dto);

        public Task UpdateIntakeAsync(int userId, int intakeId, UpdateIntakeDto dto)
            => _repo.UpdateIntakeAsync(userId, intakeId, dto);

        public Task<IEnumerable<EnrollmentDto>> GetEnrollmentsAsync(int userId, int? courseId = null, int? studentId = null)
            => _repo.GetEnrollmentsAsync(courseId, studentId);

        public Task<int> CreateEnrollmentAsync(int userId, int studentId, int courseId)
            => _repo.CreateEnrollmentAsync(studentId, courseId);

        public Task DeleteEnrollmentAsync(int userId, int enrollmentId)
            => _repo.DeleteEnrollmentAsync(enrollmentId);

        // Reports
        public Task<ReportOverviewDto> GetReportOverviewAsync(int userId, string? period = null)
            => _repo.GetReportOverviewAsync(period);

        public Task<IEnumerable<CoursePerformanceReportDto>> GetCoursePerformanceAsync(int userId, int? courseId = null)
            => _repo.GetCoursePerformanceAsync(courseId);

        public Task<StudentPerformanceReportDto?> GetStudentPerformanceAsync(int userId, int studentId)
            => _repo.GetStudentPerformanceAsync(studentId);

        public Task<IEnumerable<ExamResultReportDto>> GetExamResultsAsync(int userId)
            => _repo.GetExamResultsAsync();
    }
}
