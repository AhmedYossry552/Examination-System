using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class ManagerRepository : IManagerRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;
        public ManagerRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IEnumerable<BranchDto>> GetBranchesAsync()
        {
            using var conn = _connectionFactory.CreateConnection();
            return await conn.QueryAsync<BranchDto>("Academic.SP_Branch_GetAll", commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<TrackDto>> GetTracksByBranchAsync(int branchId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@BranchID", branchId);
            return await conn.QueryAsync<TrackDto>("Academic.SP_Track_GetByBranch", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<IntakeDto>> GetIntakesAsync()
        {
            using var conn = _connectionFactory.CreateConnection();
            return await conn.QueryAsync<IntakeDto>("Academic.SP_Intake_GetAll", commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<CourseDto>> GetCoursesAsync(bool includeInactive = false)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@IncludeInactive", includeInactive);
            return await conn.QueryAsync<CourseDto>("Academic.SP_Course_GetAll", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<int> AddCourseAsync(int managerUserId, CreateCourseDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ManagerUserID", managerUserId);
            p.Add("@CourseName", dto.CourseName);
            p.Add("@CourseCode", dto.CourseCode);
            p.Add("@CourseDescription", dto.CourseDescription);
            p.Add("@MaxDegree", dto.MaxDegree);
            p.Add("@MinDegree", dto.MinDegree);
            p.Add("@TotalHours", dto.TotalHours);
            p.Add("@CourseID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Academic.SP_Course_Add", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@CourseID");
        }

        public async Task UpdateCourseAsync(int managerUserId, int courseId, UpdateCourseDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ManagerUserID", managerUserId);
            p.Add("@CourseID", courseId);
            p.Add("@CourseName", dto.CourseName);
            p.Add("@CourseDescription", dto.CourseDescription);
            p.Add("@MaxDegree", dto.MaxDegree);
            p.Add("@MinDegree", dto.MinDegree);
            p.Add("@TotalHours", dto.TotalHours);
            p.Add("@IsActive", dto.IsActive);
            await conn.ExecuteAsync("Academic.SP_Course_Update", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<InstructorLiteDto>> GetCourseInstructorsAsync(int courseId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@CourseID", courseId);
            return await conn.QueryAsync<InstructorLiteDto>("Academic.SP_Course_GetInstructors", p, commandType: CommandType.StoredProcedure);
        }

        public async Task AssignInstructorToCourseAsync(int instructorId, int courseId, int intakeId, int branchId, int trackId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@CourseID", courseId);
            p.Add("@IntakeID", intakeId);
            p.Add("@BranchID", branchId);
            p.Add("@TrackID", trackId);
            await conn.ExecuteAsync("Academic.SP_Instructor_AssignToCourse", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<StudentLiteDto>> GetStudentsFilteredAsync(int? intakeId, int? branchId, int? trackId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@IntakeID", intakeId);
            p.Add("@BranchID", branchId);
            p.Add("@TrackID", trackId);
            return await conn.QueryAsync<StudentLiteDto>("Academic.SP_Student_GetByIntakeBranchTrack", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<int> CreateStudentAccountAsync(CreateStudentAccountDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p1 = new DynamicParameters();
            p1.Add("@Username", dto.Username);
            p1.Add("@Password", dto.Password);
            p1.Add("@Email", dto.Email);
            p1.Add("@FirstName", dto.FirstName);
            p1.Add("@LastName", dto.LastName);
            p1.Add("@PhoneNumber", dto.PhoneNumber);
            p1.Add("@UserType", "Student");
            p1.Add("@UserID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Security.SP_Admin_CreateUser", p1, commandType: CommandType.StoredProcedure);
            var userId = p1.Get<int>("@UserID");

            var p2 = new DynamicParameters();
            p2.Add("@UserID", userId);
            p2.Add("@IntakeID", dto.IntakeID);
            p2.Add("@BranchID", dto.BranchID);
            p2.Add("@TrackID", dto.TrackID);
            p2.Add("@EnrollmentDate", dto.EnrollmentDate);
            p2.Add("@StudentID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Academic.SP_Student_Add", p2, commandType: CommandType.StoredProcedure);
            return p2.Get<int>("@StudentID");
        }

        public async Task UpdateStudentAsync(int studentId, UpdateStudentDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            p.Add("@IntakeID", dto.IntakeID);
            p.Add("@BranchID", dto.BranchID);
            p.Add("@TrackID", dto.TrackID);
            p.Add("@GPA", dto.GPA);
            p.Add("@GraduationDate", dto.GraduationDate);
            await conn.ExecuteAsync("Academic.SP_Student_Update", p, commandType: CommandType.StoredProcedure);
        }

        public async Task DeactivateStudentAsync(int managerUserId, int studentId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var userId = await conn.ExecuteScalarAsync<int?>(
                "SELECT UserID FROM Academic.Student WHERE StudentID = @StudentID",
                new { StudentID = studentId }
            );

            if (userId.HasValue)
            {
                var pDel = new DynamicParameters();
                pDel.Add("@UserID", userId.Value);
                pDel.Add("@AdminUserID", managerUserId);
                await conn.ExecuteAsync("Security.SP_Admin_DeleteUser", pDel, commandType: CommandType.StoredProcedure);
            }

            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            await conn.ExecuteAsync("Academic.SP_Student_Deactivate", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<int> CreateInstructorAccountAsync(CreateInstructorAccountDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p1 = new DynamicParameters();
            p1.Add("@Username", dto.Username);
            p1.Add("@Password", dto.Password);
            p1.Add("@Email", dto.Email);
            p1.Add("@FirstName", dto.FirstName);
            p1.Add("@LastName", dto.LastName);
            p1.Add("@PhoneNumber", dto.PhoneNumber);
            p1.Add("@UserType", "Instructor");
            p1.Add("@UserID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Security.SP_Admin_CreateUser", p1, commandType: CommandType.StoredProcedure);
            var userId = p1.Get<int>("@UserID");

            var p2 = new DynamicParameters();
            p2.Add("@UserID", userId);
            p2.Add("@Specialization", dto.Specialization);
            p2.Add("@HireDate", dto.HireDate);
            p2.Add("@Salary", dto.Salary);
            p2.Add("@IsTrainingManager", dto.IsTrainingManager);
            p2.Add("@InstructorID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Academic.SP_Instructor_Add", p2, commandType: CommandType.StoredProcedure);
            return p2.Get<int>("@InstructorID");
        }

        public async Task UpdateInstructorAsync(int instructorId, UpdateInstructorDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@Specialization", dto.Specialization);
            p.Add("@HireDate", dto.HireDate);
            p.Add("@Salary", dto.Salary);
            p.Add("@IsTrainingManager", dto.IsTrainingManager);
            p.Add("@IsActive", dto.IsActive);
            await conn.ExecuteAsync("Academic.SP_Instructor_Update", p, commandType: CommandType.StoredProcedure);
        }

        public async Task DeactivateInstructorAsync(int managerUserId, int instructorId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var userId = await conn.ExecuteScalarAsync<int?>(
                "SELECT UserID FROM Academic.Instructor WHERE InstructorID = @InstructorID",
                new { InstructorID = instructorId }
            );

            if (userId.HasValue)
            {
                var pDel = new DynamicParameters();
                pDel.Add("@UserID", userId.Value);
                pDel.Add("@AdminUserID", managerUserId);
                await conn.ExecuteAsync("Security.SP_Admin_DeleteUser", pDel, commandType: CommandType.StoredProcedure);
            }

            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            await conn.ExecuteAsync("Academic.SP_Instructor_Deactivate", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<int> AddBranchAsync(int managerUserId, CreateBranchDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ManagerUserID", managerUserId);
            p.Add("@BranchName", dto.BranchName);
            p.Add("@BranchLocation", dto.BranchLocation);
            p.Add("@BranchManager", dto.BranchManager);
            p.Add("@PhoneNumber", dto.PhoneNumber);
            p.Add("@Email", dto.Email);
            p.Add("@BranchID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Academic.SP_Branch_Add", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@BranchID");
        }

        public async Task UpdateBranchAsync(int managerUserId, int branchId, UpdateBranchDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ManagerUserID", managerUserId);
            p.Add("@BranchID", branchId);
            p.Add("@BranchName", dto.BranchName);
            p.Add("@BranchLocation", dto.BranchLocation);
            p.Add("@BranchManager", dto.BranchManager);
            p.Add("@PhoneNumber", dto.PhoneNumber);
            p.Add("@Email", dto.Email);
            p.Add("@IsActive", dto.IsActive);
            await conn.ExecuteAsync("Academic.SP_Branch_Update", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<int> AddTrackAsync(int managerUserId, CreateTrackDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ManagerUserID", managerUserId);
            p.Add("@TrackName", dto.TrackName);
            p.Add("@BranchID", dto.BranchID);
            p.Add("@TrackDescription", dto.TrackDescription);
            p.Add("@DurationMonths", dto.DurationMonths);
            p.Add("@TrackID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Academic.SP_Track_Add", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@TrackID");
        }

        public async Task UpdateTrackAsync(int managerUserId, int trackId, UpdateTrackDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ManagerUserID", managerUserId);
            p.Add("@TrackID", trackId);
            p.Add("@TrackName", dto.TrackName);
            p.Add("@TrackDescription", dto.TrackDescription);
            p.Add("@DurationMonths", dto.DurationMonths);
            p.Add("@IsActive", dto.IsActive);
            await conn.ExecuteAsync("Academic.SP_Track_Update", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<int> AddIntakeAsync(int managerUserId, CreateIntakeDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ManagerUserID", managerUserId);
            p.Add("@IntakeName", dto.IntakeName);
            p.Add("@IntakeYear", dto.IntakeYear);
            p.Add("@IntakeNumber", dto.IntakeNumber);
            p.Add("@StartDate", dto.StartDate);
            p.Add("@EndDate", dto.EndDate);
            p.Add("@IntakeID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Academic.SP_Intake_Add", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@IntakeID");
        }

        public async Task UpdateIntakeAsync(int managerUserId, int intakeId, UpdateIntakeDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ManagerUserID", managerUserId);
            p.Add("@IntakeID", intakeId);
            p.Add("@IntakeName", dto.IntakeName);
            p.Add("@IntakeYear", dto.IntakeYear);
            p.Add("@IntakeNumber", dto.IntakeNumber);
            p.Add("@StartDate", dto.StartDate);
            p.Add("@EndDate", dto.EndDate);
            p.Add("@IsActive", dto.IsActive);
            await conn.ExecuteAsync("Academic.SP_Intake_Update", p, commandType: CommandType.StoredProcedure);
        }

        // New methods for missing endpoints - Using Stored Procedures
        public async Task<ManagerDashboardDto> GetDashboardAsync()
        {
            using var conn = _connectionFactory.CreateConnection();
            var dashboard = new ManagerDashboardDto();

            // Use SP_GetDashboardStats for basic stats
            var stats = await conn.QueryAsync<dynamic>(
                "Security.SP_GetDashboardStats",
                new { UserID = 0, UserType = "TrainingManager" },
                commandType: CommandType.StoredProcedure);
            
            foreach (var stat in stats)
            {
                switch ((string)stat.StatType)
                {
                    case "TotalStudents": dashboard.TotalStudents = (int)stat.Value; break;
                    case "TotalInstructors": dashboard.TotalInstructors = (int)stat.Value; break;
                    case "TotalCourses": dashboard.TotalCourses = (int)stat.Value; break;
                    case "TotalExams": dashboard.TotalExams = (int)stat.Value; break;
                    case "ActiveExams": dashboard.ActiveExams = (int)stat.Value; break;
                }
            }

            // Get additional stats (branches, tracks, intakes) 
            var additionalSql = @"
                SELECT 
                    (SELECT COUNT(*) FROM Academic.Branch WHERE IsActive = 1) AS TotalBranches,
                    (SELECT COUNT(*) FROM Academic.Track WHERE IsActive = 1) AS TotalTracks,
                    (SELECT COUNT(*) FROM Academic.Intake WHERE IsActive = 1 AND GETDATE() BETWEEN StartDate AND EndDate) AS ActiveIntakes";
            var additional = await conn.QuerySingleAsync<dynamic>(additionalSql);
            dashboard.TotalBranches = additional.TotalBranches;
            dashboard.TotalTracks = additional.TotalTracks;
            dashboard.ActiveIntakes = additional.ActiveIntakes;

            // Branch stats using stored procedure
            dashboard.BranchStats = (await conn.QueryAsync<BranchStatsDto>(
                "Academic.SP_Branch_GetAll", 
                commandType: CommandType.StoredProcedure)).AsList();

            return dashboard;
        }

        public async Task<IEnumerable<InstructorLiteDto>> GetInstructorsAsync()
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"
                SELECT i.InstructorID, 
                       ISNULL(u.FirstName + ' ' + u.LastName, u.Username) AS InstructorName,
                       u.Email, i.Specialization
                FROM Academic.Instructor i
                JOIN Security.[User] u ON i.UserID = u.UserID
                WHERE i.IsActive = 1
                ORDER BY u.FirstName, u.LastName";
            return await conn.QueryAsync<InstructorLiteDto>(sql);
        }

        public async Task<IEnumerable<EnrollmentDto>> GetEnrollmentsAsync(int? courseId = null, int? studentId = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"
                SELECT sc.StudentCourseID AS EnrollmentID, sc.StudentID, 
                       ISNULL(u.FirstName + ' ' + u.LastName, u.Username) AS StudentName,
                       sc.CourseID, c.CourseName, c.CourseCode, sc.EnrollmentDate, sc.FinalGrade, sc.IsPassed
                FROM Academic.StudentCourse sc
                JOIN Academic.Student s ON sc.StudentID = s.StudentID
                JOIN Security.[User] u ON s.UserID = u.UserID
                JOIN Academic.Course c ON sc.CourseID = c.CourseID
                WHERE 1=1";
            
            if (courseId.HasValue) sql += " AND sc.CourseID = @CourseID";
            if (studentId.HasValue) sql += " AND sc.StudentID = @StudentID";
            sql += " ORDER BY sc.EnrollmentDate DESC";

            return await conn.QueryAsync<EnrollmentDto>(sql, new { CourseID = courseId, StudentID = studentId });
        }

        public async Task<int> CreateEnrollmentAsync(int studentId, int courseId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"
                INSERT INTO Academic.StudentCourse (StudentID, CourseID, EnrollmentDate)
                OUTPUT INSERTED.StudentCourseID
                VALUES (@StudentID, @CourseID, GETDATE())";
            return await conn.ExecuteScalarAsync<int>(sql, new { StudentID = studentId, CourseID = courseId });
        }

        public async Task DeleteEnrollmentAsync(int enrollmentId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = "DELETE FROM Academic.StudentCourse WHERE StudentCourseID = @EnrollmentID";
            await conn.ExecuteAsync(sql, new { EnrollmentID = enrollmentId });
        }

        #region Reports
        public async Task<ReportOverviewDto> GetReportOverviewAsync()
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"
                SELECT 
                    (SELECT COUNT(*) FROM Academic.Student WHERE IsActive = 1) AS TotalStudents,
                    (SELECT COUNT(*) FROM Academic.Instructor WHERE IsActive = 1) AS TotalInstructors,
                    (SELECT COUNT(*) FROM Academic.Course WHERE IsActive = 1) AS TotalCourses,
                    (SELECT COUNT(*) FROM Exam.Exam WHERE IsActive = 1) AS TotalExams,
                    (SELECT COUNT(*) FROM Academic.StudentCourse) AS ActiveEnrollments,
                    (SELECT 
                        ISNULL(CAST(SUM(CASE WHEN se.TotalScore >= e.PassMarks THEN 1 ELSE 0 END) AS FLOAT) / 
                        NULLIF(COUNT(*), 0) * 100, 0)
                     FROM Exam.StudentExam se
                     JOIN Exam.Exam e ON se.ExamID = e.ExamID
                     WHERE se.SubmissionTime IS NOT NULL) AS AveragePassRate,
                    (SELECT COUNT(*) 
                     FROM Exam.Exam 
                     WHERE IsActive = 1 
                       AND MONTH(StartDateTime) = MONTH(GETDATE()) 
                       AND YEAR(StartDateTime) = YEAR(GETDATE())) AS ExamsThisMonth,
                    (SELECT COUNT(*) 
                     FROM Academic.Student 
                     WHERE MONTH(EnrollmentDate) = MONTH(GETDATE()) 
                       AND YEAR(EnrollmentDate) = YEAR(GETDATE())) AS NewStudentsThisMonth";

            var result = await conn.QuerySingleAsync<dynamic>(sql);
            return new ReportOverviewDto(
                TotalStudents: (int)result.TotalStudents,
                TotalInstructors: (int)result.TotalInstructors,
                TotalCourses: (int)result.TotalCourses,
                TotalExams: (int)result.TotalExams,
                ActiveEnrollments: (int)result.ActiveEnrollments,
                AveragePassRate: (double)(result.AveragePassRate ?? 0),
                ExamsThisMonth: (int)result.ExamsThisMonth,
                NewStudentsThisMonth: (int)result.NewStudentsThisMonth
            );
        }

        public async Task<IEnumerable<CoursePerformanceReportDto>> GetCoursePerformanceAsync(int? courseId = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"
                SELECT 
                    c.CourseID AS CourseId,
                    c.CourseName,
                    c.CourseCode,
                    COUNT(DISTINCT sc.StudentID) AS TotalStudents,
                    COUNT(DISTINCT CASE WHEN se.SubmissionTime IS NOT NULL THEN se.StudentExamID END) AS CompletedExams,
                    ISNULL(AVG(CAST(se.TotalScore AS FLOAT) / NULLIF(e.TotalMarks, 0) * 100), 0) AS AverageScore,
                    ISNULL(CAST(SUM(CASE WHEN se.TotalScore >= e.PassMarks THEN 1 ELSE 0 END) AS FLOAT) / 
                           NULLIF(COUNT(CASE WHEN se.SubmissionTime IS NOT NULL THEN 1 END), 0) * 100, 0) AS PassRate,
                    ISNULL((
                        SELECT TOP 1 ISNULL(u.FirstName + ' ' + u.LastName, u.Username)
                        FROM Academic.StudentCourse sc2
                        JOIN Academic.Student s ON sc2.StudentID = s.StudentID
                        JOIN Security.[User] u ON s.UserID = u.UserID
                        WHERE sc2.CourseID = c.CourseID
                        ORDER BY sc2.FinalGrade DESC
                    ), 'N/A') AS TopPerformer
                FROM Academic.Course c
                LEFT JOIN Academic.StudentCourse sc ON c.CourseID = sc.CourseID
                LEFT JOIN Exam.Exam e ON c.CourseID = e.CourseID
                LEFT JOIN Exam.StudentExam se ON e.ExamID = se.ExamID
                WHERE c.IsActive = 1" + (courseId.HasValue ? " AND c.CourseID = @CourseID" : "") + @"
                GROUP BY c.CourseID, c.CourseName, c.CourseCode
                ORDER BY c.CourseName";

            return await conn.QueryAsync<CoursePerformanceReportDto>(sql, new { CourseID = courseId });
        }

        public async Task<StudentPerformanceReportDto?> GetStudentPerformanceAsync(int studentId)
        {
            using var conn = _connectionFactory.CreateConnection();
            
            // Get student basic info
            var studentSql = @"
                SELECT s.StudentID AS StudentId,
                       ISNULL(u.FirstName + ' ' + u.LastName, u.Username) AS StudentName,
                       u.Email,
                       COUNT(DISTINCT se.StudentExamID) AS TotalExams,
                       SUM(CASE WHEN se.TotalScore >= e.PassMarks THEN 1 ELSE 0 END) AS PassedExams,
                       ISNULL(AVG(CAST(se.TotalScore AS FLOAT) / NULLIF(e.TotalMarks, 0) * 100), 0) AS AverageScore,
                       CASE WHEN s.IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS Status
                FROM Academic.Student s
                JOIN Security.[User] u ON s.UserID = u.UserID
                LEFT JOIN Exam.StudentExam se ON s.StudentID = se.StudentID
                LEFT JOIN Exam.Exam e ON se.ExamID = e.ExamID
                WHERE s.StudentID = @StudentID
                GROUP BY s.StudentID, u.FirstName, u.LastName, u.Username, u.Email, s.IsActive";
            
            var student = await conn.QueryFirstOrDefaultAsync<dynamic>(studentSql, new { StudentID = studentId });
            if (student == null) return null;

            // Get exam history
            var examHistorySql = @"
                SELECT e.ExamID AS ExamId,
                       e.ExamName,
                       c.CourseName,
                       ISNULL(se.StartTime, e.StartDateTime) AS ExamDate,
                       ISNULL(CAST(se.TotalScore AS FLOAT) / NULLIF(e.TotalMarks, 0) * 100, 0) AS Score,
                       CASE WHEN se.TotalScore >= e.PassMarks THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Passed
                FROM Exam.StudentExam se
                JOIN Exam.Exam e ON se.ExamID = e.ExamID
                JOIN Academic.Course c ON e.CourseID = c.CourseID
                WHERE se.StudentID = @StudentID AND se.SubmissionTime IS NOT NULL
                ORDER BY se.StartTime DESC";

            var examHistory = (await conn.QueryAsync<ExamPerformanceReportDto>(examHistorySql, new { StudentID = studentId })).ToList();

            return new StudentPerformanceReportDto(
                StudentId: (int)student.StudentId,
                StudentName: (string)student.StudentName,
                Email: (string)student.Email,
                TotalExams: (int)(student.TotalExams ?? 0),
                PassedExams: (int)(student.PassedExams ?? 0),
                AverageScore: (double)(student.AverageScore ?? 0),
                AttendanceRate: 100.0, // Would need attendance tracking for real value
                Status: (string)student.Status,
                ExamHistory: examHistory
            );
        }
        #endregion
    }
}
