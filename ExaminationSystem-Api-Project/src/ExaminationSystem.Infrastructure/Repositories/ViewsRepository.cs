using System.Collections.Generic;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    /// <summary>
    /// Repository implementation for database views
    /// </summary>
    public class ViewsRepository : IViewsRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;

        public ViewsRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        #region Security Views

        public async Task<IEnumerable<UserDetailsViewDto>> GetUserDetailsAsync(int? userId = null, string? userType = null, bool? isActive = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Security.VW_UserDetails
                        WHERE (@UserID IS NULL OR UserID = @UserID)
                          AND (@UserType IS NULL OR UserType = @UserType)
                          AND (@IsActive IS NULL OR IsActive = @IsActive)
                        ORDER BY UserID";

            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@UserType", userType);
            p.Add("@IsActive", isActive);

            return await conn.QueryAsync<UserDetailsViewDto>(sql, p);
        }

        #endregion

        #region Academic Views

        public async Task<IEnumerable<StudentDetailsViewDto>> GetStudentDetailsAsync(int? studentId = null, int? branchId = null, int? trackId = null, int? intakeId = null, bool? isActive = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Academic.VW_StudentDetails
                        WHERE (@StudentID IS NULL OR StudentID = @StudentID)
                          AND (@BranchID IS NULL OR BranchID = @BranchID)
                          AND (@TrackID IS NULL OR TrackID = @TrackID)
                          AND (@IntakeID IS NULL OR IntakeID = @IntakeID)
                          AND (@IsActive IS NULL OR IsActive = @IsActive)
                        ORDER BY StudentID";

            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            p.Add("@BranchID", branchId);
            p.Add("@TrackID", trackId);
            p.Add("@IntakeID", intakeId);
            p.Add("@IsActive", isActive);

            return await conn.QueryAsync<StudentDetailsViewDto>(sql, p);
        }

        public async Task<IEnumerable<InstructorDetailsViewDto>> GetInstructorDetailsAsync(int? instructorId = null, bool? isTrainingManager = null, bool? isActive = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Academic.VW_InstructorDetails
                        WHERE (@InstructorID IS NULL OR InstructorID = @InstructorID)
                          AND (@IsTrainingManager IS NULL OR IsTrainingManager = @IsTrainingManager)
                          AND (@IsActive IS NULL OR IsActive = @IsActive)
                        ORDER BY InstructorID";

            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@IsTrainingManager", isTrainingManager);
            p.Add("@IsActive", isActive);

            return await conn.QueryAsync<InstructorDetailsViewDto>(sql, p);
        }

        public async Task<IEnumerable<CourseDetailsViewDto>> GetCourseDetailsAsync(int? courseId = null, bool? isActive = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Academic.VW_CourseDetails
                        WHERE (@CourseID IS NULL OR CourseID = @CourseID)
                          AND (@IsActive IS NULL OR IsActive = @IsActive)
                        ORDER BY CourseID";

            var p = new DynamicParameters();
            p.Add("@CourseID", courseId);
            p.Add("@IsActive", isActive);

            return await conn.QueryAsync<CourseDetailsViewDto>(sql, p);
        }

        public async Task<IEnumerable<CourseEnrollmentViewDto>> GetCourseEnrollmentAsync(int? studentId = null, int? courseId = null, bool? isPassed = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Academic.VW_CourseEnrollment
                        WHERE (@StudentID IS NULL OR StudentID = @StudentID)
                          AND (@CourseID IS NULL OR CourseID = @CourseID)
                          AND (@IsPassed IS NULL OR IsPassed = @IsPassed)
                        ORDER BY StudentCourseID";

            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            p.Add("@CourseID", courseId);
            p.Add("@IsPassed", isPassed);

            return await conn.QueryAsync<CourseEnrollmentViewDto>(sql, p);
        }

        public async Task<IEnumerable<InstructorCourseAssignmentViewDto>> GetInstructorCourseAssignmentAsync(int? instructorId = null, int? courseId = null, int? intakeId = null, bool? isActive = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Academic.VW_InstructorCourseAssignment
                        WHERE (@InstructorID IS NULL OR InstructorID = @InstructorID)
                          AND (@CourseID IS NULL OR CourseID = @CourseID)
                          AND (@IntakeID IS NULL OR IntakeID = @IntakeID)
                          AND (@IsActive IS NULL OR IsActive = @IsActive)
                        ORDER BY CourseInstructorID";

            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@CourseID", courseId);
            p.Add("@IntakeID", intakeId);
            p.Add("@IsActive", isActive);

            return await conn.QueryAsync<InstructorCourseAssignmentViewDto>(sql, p);
        }

        #endregion

        #region Exam Views

        public async Task<IEnumerable<ExamDetailsViewDto>> GetExamDetailsAsync(int? examId = null, int? courseId = null, int? instructorId = null, string? examStatus = null, bool? isActive = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Exam.VW_ExamDetails
                        WHERE (@ExamID IS NULL OR ExamID = @ExamID)
                          AND (@CourseID IS NULL OR CourseID = @CourseID)
                          AND (@InstructorID IS NULL OR InstructorID = @InstructorID)
                          AND (@ExamStatus IS NULL OR ExamStatus = @ExamStatus)
                          AND (@IsActive IS NULL OR IsActive = @IsActive)
                        ORDER BY ExamID";

            var p = new DynamicParameters();
            p.Add("@ExamID", examId);
            p.Add("@CourseID", courseId);
            p.Add("@InstructorID", instructorId);
            p.Add("@ExamStatus", examStatus);
            p.Add("@IsActive", isActive);

            return await conn.QueryAsync<ExamDetailsViewDto>(sql, p);
        }

        public async Task<IEnumerable<QuestionPoolViewDto>> GetQuestionPoolAsync(int? questionId = null, int? courseId = null, int? instructorId = null, string? questionType = null, string? difficultyLevel = null, bool? isActive = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Exam.VW_QuestionPool
                        WHERE (@QuestionID IS NULL OR QuestionID = @QuestionID)
                          AND (@CourseID IS NULL OR CourseID = @CourseID)
                          AND (@InstructorID IS NULL OR InstructorID = @InstructorID)
                          AND (@QuestionType IS NULL OR QuestionType = @QuestionType)
                          AND (@DifficultyLevel IS NULL OR DifficultyLevel = @DifficultyLevel)
                          AND (@IsActive IS NULL OR IsActive = @IsActive)
                        ORDER BY QuestionID";

            var p = new DynamicParameters();
            p.Add("@QuestionID", questionId);
            p.Add("@CourseID", courseId);
            p.Add("@InstructorID", instructorId);
            p.Add("@QuestionType", questionType);
            p.Add("@DifficultyLevel", difficultyLevel);
            p.Add("@IsActive", isActive);

            return await conn.QueryAsync<QuestionPoolViewDto>(sql, p);
        }

        public async Task<IEnumerable<StudentExamResultsViewDto>> GetStudentExamResultsAsync(int? studentId = null, int? examId = null, int? courseId = null, bool? isPassed = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Exam.VW_StudentExamResults
                        WHERE (@StudentID IS NULL OR StudentID = @StudentID)
                          AND (@ExamID IS NULL OR ExamID = @ExamID)
                          AND (@IsPassed IS NULL OR IsPassed = @IsPassed)
                        ORDER BY StudentExamID";

            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            p.Add("@ExamID", examId);
            p.Add("@IsPassed", isPassed);

            return await conn.QueryAsync<StudentExamResultsViewDto>(sql, p);
        }

        public async Task<IEnumerable<StudentAnswerDetailsViewDto>> GetStudentAnswerDetailsAsync(int? studentExamId = null, int? studentId = null, int? examId = null, bool? needsManualGrading = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Exam.VW_StudentAnswerDetails
                        WHERE (@StudentExamID IS NULL OR StudentExamID = @StudentExamID)
                          AND (@StudentID IS NULL OR StudentID = @StudentID)
                          AND (@ExamID IS NULL OR ExamID = @ExamID)
                          AND (@NeedsManualGrading IS NULL OR NeedsManualGrading = @NeedsManualGrading)
                        ORDER BY StudentAnswerID";

            var p = new DynamicParameters();
            p.Add("@StudentExamID", studentExamId);
            p.Add("@StudentID", studentId);
            p.Add("@ExamID", examId);
            p.Add("@NeedsManualGrading", needsManualGrading);

            return await conn.QueryAsync<StudentAnswerDetailsViewDto>(sql, p);
        }

        public async Task<IEnumerable<PendingGradingViewDto>> GetPendingGradingAsync(int? instructorId = null, int? examId = null, int? studentId = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Exam.VW_PendingGrading
                        WHERE (@InstructorID IS NULL OR InstructorID = @InstructorID)
                          AND (@ExamID IS NULL OR ExamID = @ExamID)
                          AND (@StudentID IS NULL OR StudentID = @StudentID)
                        ORDER BY AnsweredDate";

            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@ExamID", examId);
            p.Add("@StudentID", studentId);

            return await conn.QueryAsync<PendingGradingViewDto>(sql, p);
        }

        public async Task<IEnumerable<ExamStatisticsViewDto>> GetExamStatisticsAsync(int? examId = null, int? courseId = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Exam.VW_ExamStatistics
                        WHERE (@ExamID IS NULL OR ExamID = @ExamID)
                        ORDER BY ExamID";

            var p = new DynamicParameters();
            p.Add("@ExamID", examId);

            return await conn.QueryAsync<ExamStatisticsViewDto>(sql, p);
        }

        public async Task<IEnumerable<TextAnswersAnalysisViewDto>> GetTextAnswersAnalysisAsync(int? examId = null, int? studentId = null, int? instructorId = null, string? answerClassification = null, bool? isPendingGrading = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"SELECT * FROM Exam.VW_TextAnswersAnalysis
                        WHERE (@ExamID IS NULL OR ExamID = @ExamID)
                          AND (@StudentID IS NULL OR StudentID = @StudentID)
                          AND (@InstructorID IS NULL OR InstructorID = @InstructorID)
                          AND (@AnswerClassification IS NULL OR AnswerClassification = @AnswerClassification)
                          AND (@IsPendingGrading IS NULL OR IsPendingGrading = @IsPendingGrading)
                        ORDER BY GradingPriorityScore DESC, AnsweredDate";

            var p = new DynamicParameters();
            p.Add("@ExamID", examId);
            p.Add("@StudentID", studentId);
            p.Add("@InstructorID", instructorId);
            p.Add("@AnswerClassification", answerClassification);
            p.Add("@IsPendingGrading", isPendingGrading.HasValue && isPendingGrading.Value ? 1 : (int?)null);

            return await conn.QueryAsync<TextAnswersAnalysisViewDto>(sql, p);
        }

        #endregion
    }
}
