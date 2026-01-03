using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IManagerRepository
    {
        // Dashboard
        Task<ManagerDashboardDto> GetDashboardAsync();

        Task<IEnumerable<BranchDto>> GetBranchesAsync();
        Task<IEnumerable<TrackDto>> GetTracksByBranchAsync(int branchId);
        Task<IEnumerable<IntakeDto>> GetIntakesAsync();
        Task<IEnumerable<CourseDto>> GetCoursesAsync(bool includeInactive = false);
        Task<int> AddCourseAsync(int managerUserId, CreateCourseDto dto);
        Task UpdateCourseAsync(int managerUserId, int courseId, UpdateCourseDto dto);
        Task<IEnumerable<InstructorLiteDto>> GetCourseInstructorsAsync(int courseId);
        Task AssignInstructorToCourseAsync(int instructorId, int courseId, int intakeId, int branchId, int trackId);
        Task<IEnumerable<StudentLiteDto>> GetStudentsFilteredAsync(int? intakeId, int? branchId, int? trackId);
        Task<int> CreateStudentAccountAsync(CreateStudentAccountDto dto);
        Task UpdateStudentAsync(int studentId, UpdateStudentDto dto);
        Task DeactivateStudentAsync(int managerUserId, int studentId);

        // Instructors
        Task<IEnumerable<InstructorLiteDto>> GetInstructorsAsync();
        Task<int> CreateInstructorAccountAsync(CreateInstructorAccountDto dto);
        Task UpdateInstructorAsync(int instructorId, UpdateInstructorDto dto);
        Task DeactivateInstructorAsync(int managerUserId, int instructorId);
        Task<int> AddBranchAsync(int managerUserId, CreateBranchDto dto);
        Task UpdateBranchAsync(int managerUserId, int branchId, UpdateBranchDto dto);
        Task<int> AddTrackAsync(int managerUserId, CreateTrackDto dto);
        Task UpdateTrackAsync(int managerUserId, int trackId, UpdateTrackDto dto);
        Task<int> AddIntakeAsync(int managerUserId, CreateIntakeDto dto);
        Task UpdateIntakeAsync(int managerUserId, int intakeId, UpdateIntakeDto dto);

        // Enrollments
        Task<IEnumerable<EnrollmentDto>> GetEnrollmentsAsync(int? courseId = null, int? studentId = null);
        Task<int> CreateEnrollmentAsync(int studentId, int courseId);
        Task DeleteEnrollmentAsync(int enrollmentId);

        // Reports
        Task<ReportOverviewDto> GetReportOverviewAsync(string? period = null);
        Task<IEnumerable<CoursePerformanceReportDto>> GetCoursePerformanceAsync(int? courseId = null);
        Task<StudentPerformanceReportDto?> GetStudentPerformanceAsync(int studentId);
        Task<IEnumerable<ExamResultReportDto>> GetExamResultsAsync();
    }
}
