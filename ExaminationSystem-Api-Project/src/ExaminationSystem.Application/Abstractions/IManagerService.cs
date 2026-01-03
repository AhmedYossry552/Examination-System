using System.Collections.Generic;
using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IManagerService
    {
        // Dashboard
        Task<ManagerDashboardDto> GetDashboardAsync(int userId);

        Task<IEnumerable<BranchDto>> GetBranchesAsync(int userId);
        Task<IEnumerable<TrackDto>> GetTracksByBranchAsync(int userId, int branchId);
        Task<IEnumerable<IntakeDto>> GetIntakesAsync(int userId);
        Task<IEnumerable<CourseDto>> GetCoursesAsync(int userId, bool includeInactive = false);
        Task<int> AddCourseAsync(int userId, CreateCourseDto dto);
        Task UpdateCourseAsync(int userId, int courseId, UpdateCourseDto dto);
        Task<IEnumerable<InstructorLiteDto>> GetCourseInstructorsAsync(int userId, int courseId);
        Task AssignInstructorToCourseAsync(int userId, int instructorId, int courseId, int intakeId, int branchId, int trackId);
        Task<IEnumerable<StudentLiteDto>> GetStudentsFilteredAsync(int userId, int? intakeId, int? branchId, int? trackId);
        Task<int> CreateStudentAccountAsync(int userId, CreateStudentAccountDto dto);
        Task UpdateStudentAsync(int userId, int studentId, UpdateStudentDto dto);
        Task DeactivateStudentAsync(int userId, int studentId);

        // Instructors
        Task<IEnumerable<InstructorLiteDto>> GetInstructorsAsync(int userId);
        Task<int> CreateInstructorAccountAsync(int userId, CreateInstructorAccountDto dto);
        Task UpdateInstructorAsync(int userId, int instructorId, UpdateInstructorDto dto);
        Task DeactivateInstructorAsync(int userId, int instructorId);
        Task<int> AddBranchAsync(int userId, CreateBranchDto dto);
        Task UpdateBranchAsync(int userId, int branchId, UpdateBranchDto dto);
        Task<int> AddTrackAsync(int userId, CreateTrackDto dto);
        Task UpdateTrackAsync(int userId, int trackId, UpdateTrackDto dto);
        Task<int> AddIntakeAsync(int userId, CreateIntakeDto dto);
        Task UpdateIntakeAsync(int userId, int intakeId, UpdateIntakeDto dto);

        // Enrollments
        Task<IEnumerable<EnrollmentDto>> GetEnrollmentsAsync(int userId, int? courseId = null, int? studentId = null);
        Task<int> CreateEnrollmentAsync(int userId, int studentId, int courseId);
        Task DeleteEnrollmentAsync(int userId, int enrollmentId);

        // Reports
        Task<ReportOverviewDto> GetReportOverviewAsync(int userId, string? period = null);
        Task<IEnumerable<CoursePerformanceReportDto>> GetCoursePerformanceAsync(int userId, int? courseId = null);
        Task<StudentPerformanceReportDto?> GetStudentPerformanceAsync(int userId, int studentId);
        Task<IEnumerable<ExamResultReportDto>> GetExamResultsAsync(int userId);
    }

    // Report DTOs
    public record ReportOverviewDto(
        int TotalStudents,
        int TotalInstructors,
        int TotalCourses,
        int TotalExams,
        int ActiveEnrollments,
        double AveragePassRate,
        int ExamsThisMonth,
        int NewStudentsThisMonth
    );

    public record CoursePerformanceReportDto(
        int CourseId,
        string CourseName,
        string CourseCode,
        int TotalStudents,
        int CompletedExams,
        double AverageScore,
        double PassRate,
        string TopPerformer
    );

    public record StudentPerformanceReportDto(
        int StudentId,
        string StudentName,
        string Email,
        int TotalExams,
        int PassedExams,
        double AverageScore,
        double AttendanceRate,
        string Status,
        List<ExamPerformanceReportDto> ExamHistory
    );

    public record ExamPerformanceReportDto(
        int ExamId,
        string ExamName,
        string CourseName,
        System.DateTime ExamDate,
        double Score,
        bool Passed
    );

    public record ExamResultReportDto(
        int ExamId,
        string ExamName,
        string CourseName,
        int TotalStudents,
        int SubmittedCount,
        int PassedCount,
        double AverageScore,
        double PassRate,
        System.DateTime ExamDate,
        string Status
    );
}
