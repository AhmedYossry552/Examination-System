using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class InstructorRepository : IInstructorRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;
        public InstructorRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<int> GetInstructorIdByUserIdAsync(int userId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = "SELECT InstructorID FROM Academic.Instructor WHERE UserID = @UserID";
            var id = await conn.ExecuteScalarAsync<int?>(sql, new { UserID = userId });
            if (id == null) throw new Exception("Instructor record not found for current user.");
            return id.Value;
        }

        public async Task<int> CreateExamAsync(CreateExamDto dto, int instructorId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@CourseID", dto.CourseID);
            p.Add("@IntakeID", dto.IntakeID);
            p.Add("@BranchID", dto.BranchID);
            p.Add("@TrackID", dto.TrackID);
            p.Add("@ExamName", dto.ExamName);
            p.Add("@ExamYear", dto.ExamYear);
            p.Add("@ExamType", dto.ExamType);
            p.Add("@TotalMarks", dto.TotalMarks);
            p.Add("@PassMarks", dto.PassMarks);
            p.Add("@DurationMinutes", dto.DurationMinutes);
            p.Add("@StartDateTime", dto.StartDateTime);
            p.Add("@EndDateTime", dto.EndDateTime);
            p.Add("@AllowanceOptions", dto.AllowanceOptions);
            p.Add("@ExamID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Exam.SP_Exam_Create", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@ExamID");
        }

        public async Task AddQuestionAsync(int examId, int questionId, int order, int marks)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ExamID", examId);
            p.Add("@QuestionID", questionId);
            p.Add("@QuestionOrder", order);
            p.Add("@QuestionMarks", marks);
            await conn.ExecuteAsync("Exam.SP_Exam_AddQuestion", p, commandType: CommandType.StoredProcedure);
        }

        public async Task GenerateRandomAsync(int examId, GenerateRandomDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ExamID", examId);
            p.Add("@MultipleChoiceCount", dto.MultipleChoiceCount);
            p.Add("@TrueFalseCount", dto.TrueFalseCount);
            p.Add("@TextCount", dto.TextCount);
            p.Add("@MarksPerMC", dto.MarksPerMC);
            p.Add("@MarksPerTF", dto.MarksPerTF);
            p.Add("@MarksPerText", dto.MarksPerText);
            await conn.ExecuteAsync("Exam.SP_Exam_GenerateRandom", p, commandType: CommandType.StoredProcedure);
        }

        public async Task AssignToStudentsAsync(int examId, IEnumerable<int> studentIds)
        {
            using var conn = _connectionFactory.CreateConnection();
            var csv = string.Join(',', studentIds);
            var p = new DynamicParameters();
            p.Add("@ExamID", examId);
            p.Add("@StudentIDs", csv);
            await conn.ExecuteAsync("Exam.SP_Exam_AssignToStudents", p, commandType: CommandType.StoredProcedure);

            // Enqueue assignment emails for each student
            foreach (var sid in studentIds)
            {
                var ep = new DynamicParameters();
                ep.Add("@StudentID", sid);
                ep.Add("@ExamID", examId);
                await conn.ExecuteAsync("Exam.SP_SendExamAssignmentEmail", ep, commandType: CommandType.StoredProcedure);
            }
        }

        public async Task AssignToAllCourseStudentsAsync(int examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ExamID", examId);
            await conn.ExecuteAsync("Exam.SP_Exam_AssignToAllCourseStudents", p, commandType: CommandType.StoredProcedure);

            // Fetch assigned students and enqueue assignment emails
            var students = await conn.QueryAsync<int>(
                "SELECT DISTINCT StudentID FROM Exam.StudentExam WHERE ExamID = @ExamID",
                new { ExamID = examId });
            foreach (var sid in students)
            {
                var ep = new DynamicParameters();
                ep.Add("@StudentID", sid);
                ep.Add("@ExamID", examId);
                await conn.ExecuteAsync("Exam.SP_SendExamAssignmentEmail", ep, commandType: CommandType.StoredProcedure);
            }
        }

        public async Task<IEnumerable<CourseDto>> GetMyCoursesAsync(int instructorId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            return await conn.QueryAsync<CourseDto>("Academic.SP_Instructor_GetMyCourses", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<CourseStudentDto>> GetCourseStudentsAsync(int instructorId, int courseId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@CourseID", courseId);
            return await conn.QueryAsync<CourseStudentDto>("Academic.SP_Instructor_GetCourseStudents", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<ExamToGradeDto>> GetExamsToGradeAsync(int instructorId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            return await conn.QueryAsync<ExamToGradeDto>("Exam.SP_Instructor_GetExamsToGrade", p, commandType: CommandType.StoredProcedure);
        }

        public async Task GradeTextAnswerAsync(int instructorId, int studentAnswerId, decimal marksObtained, string? comments)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@StudentAnswerID", studentAnswerId);
            p.Add("@MarksObtained", marksObtained);
            p.Add("@InstructorComments", comments);
            await conn.ExecuteAsync("Exam.SP_Instructor_GradeTextAnswer", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<ExamStatisticsDto> GetExamStatisticsAsync(int instructorId, int examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@ExamID", examId);
            return await conn.QuerySingleAsync<ExamStatisticsDto>("Exam.SP_Instructor_GetExamStatistics", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<InstructorExamReportDto> GetInstructorExamReportAsync(int instructorId, int examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@ExamID", examId);
            using var multi = await conn.QueryMultipleAsync("Exam.SP_API_GetInstructorExamReport", p, commandType: CommandType.StoredProcedure);
            var overview = await multi.ReadFirstOrDefaultAsync<InstructorExamOverviewDto>();
            var students = (await multi.ReadAsync<InstructorStudentExamResultDto>()).ToList();
            var questions = (await multi.ReadAsync<InstructorQuestionStatDto>()).ToList();
            return new InstructorExamReportDto { Overview = overview ?? new InstructorExamOverviewDto(), Students = students, Questions = questions };
        }

        // Question Pool Methods
        public async Task<int> AddQuestionAsync(int instructorId, CreateQuestionDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@CourseID", dto.CourseID);
            p.Add("@QuestionText", dto.QuestionText);
            p.Add("@QuestionType", dto.QuestionType);
            p.Add("@DifficultyLevel", dto.DifficultyLevel);
            p.Add("@Points", dto.Points);
            p.Add("@QuestionID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Exam.SP_Question_Add", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@QuestionID");
        }

        public async Task UpdateQuestionAsync(int instructorId, int questionId, UpdateQuestionDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@QuestionID", questionId);
            p.Add("@QuestionText", dto.QuestionText);
            p.Add("@DifficultyLevel", dto.DifficultyLevel);
            p.Add("@Points", dto.Points);
            await conn.ExecuteAsync("Exam.SP_Question_Update", p, commandType: CommandType.StoredProcedure);
        }

        public async Task DeleteQuestionAsync(int instructorId, int questionId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@QuestionID", questionId);
            await conn.ExecuteAsync("Exam.SP_Question_Delete", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<QuestionDto>> GetQuestionsByCourseAsync(int instructorId, int courseId, string? questionType = null, string? difficultyLevel = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@CourseID", courseId);
            p.Add("@QuestionType", questionType);
            p.Add("@DifficultyLevel", difficultyLevel);
            return await conn.QueryAsync<QuestionDto>("Exam.SP_Question_GetByCourse", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<QuestionWithOptionsDto?> GetQuestionWithOptionsAsync(int questionId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@QuestionID", questionId);
            using var multi = await conn.QueryMultipleAsync("Exam.SP_Question_GetWithOptions", p, commandType: CommandType.StoredProcedure);
            var question = await multi.ReadFirstOrDefaultAsync<QuestionWithOptionsDto>();
            if (question != null)
            {
                question.Options = (await multi.ReadAsync<QuestionOptionDto>()).ToList();
                question.Answer = await multi.ReadFirstOrDefaultAsync<QuestionAnswerDto>();
            }
            return question;
        }

        public async Task<int> AddQuestionOptionAsync(int questionId, CreateQuestionOptionDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@QuestionID", questionId);
            p.Add("@OptionText", dto.OptionText);
            p.Add("@IsCorrect", dto.IsCorrect);
            p.Add("@OptionOrder", dto.OptionOrder);
            p.Add("@OptionID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Exam.SP_Question_AddOption", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@OptionID");
        }

        public async Task<int> AddQuestionAnswerAsync(int questionId, CreateQuestionAnswerDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@QuestionID", questionId);
            p.Add("@CorrectAnswer", dto.CorrectAnswer);
            p.Add("@AnswerPattern", dto.AnswerPattern);
            p.Add("@CaseSensitive", dto.CaseSensitive);
            p.Add("@AnswerID", dbType: DbType.Int32, direction: ParameterDirection.Output);
            await conn.ExecuteAsync("Exam.SP_Question_AddAnswer", p, commandType: CommandType.StoredProcedure);
            return p.Get<int>("@AnswerID");
        }

        public async Task<QuestionPoolStatisticsDto> GetQuestionPoolStatisticsAsync(int instructorId, int courseId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@CourseID", courseId);
            return await conn.QuerySingleAsync<QuestionPoolStatisticsDto>("Exam.SP_Question_GetStatistics", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<IEnumerable<TextAnswerAnalysisDto>> GetTextAnswersAnalysisAsync(int instructorId, int? examId = null)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@InstructorID", instructorId);
            p.Add("@ExamID", examId);
            return await conn.QueryAsync<TextAnswerAnalysisDto>("Exam.SP_Instructor_GetTextAnswersAnalysis", p, commandType: CommandType.StoredProcedure);
        }

        // New methods for missing endpoints
        public async Task<IEnumerable<ExamLiteDto>> GetMyExamsAsync(int instructorId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"
                SELECT e.ExamID, e.ExamName, c.CourseName, c.CourseCode, e.ExamType,
                       e.TotalMarks, e.PassMarks, e.DurationMinutes, e.StartDateTime, e.EndDateTime,
                       (SELECT COUNT(*) FROM Exam.StudentExam WHERE ExamID = e.ExamID) AS TotalStudents,
                       (SELECT COUNT(*) FROM Exam.StudentExam WHERE ExamID = e.ExamID AND SubmissionTime IS NOT NULL) AS CompletedCount,
                       CASE 
                           WHEN GETDATE() < e.StartDateTime THEN 'Upcoming'
                           WHEN GETDATE() BETWEEN e.StartDateTime AND e.EndDateTime THEN 'Active'
                           ELSE 'Completed'
                       END AS Status,
                       e.IsActive
                FROM Exam.Exam e
                JOIN Academic.Course c ON e.CourseID = c.CourseID
                WHERE e.InstructorID = @InstructorID
                ORDER BY e.StartDateTime DESC";
            return await conn.QueryAsync<ExamLiteDto>(sql, new { InstructorID = instructorId });
        }

        public async Task<ExamDetailDto?> GetExamByIdAsync(int instructorId, int examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = @"
                SELECT e.ExamID, e.ExamName, c.CourseName, c.CourseCode, e.ExamType,
                       e.TotalMarks, e.PassMarks, e.DurationMinutes, e.StartDateTime, e.EndDateTime,
                       e.CourseID, e.IntakeID, e.BranchID, e.TrackID,
                       i.IntakeName, b.BranchName, t.TrackName, e.AllowanceOptions,
                       (SELECT COUNT(*) FROM Exam.StudentExam WHERE ExamID = e.ExamID) AS TotalStudents,
                       (SELECT COUNT(*) FROM Exam.StudentExam WHERE ExamID = e.ExamID AND SubmissionTime IS NOT NULL) AS CompletedCount,
                       CASE 
                           WHEN GETDATE() < e.StartDateTime THEN 'Upcoming'
                           WHEN GETDATE() BETWEEN e.StartDateTime AND e.EndDateTime THEN 'Active'
                           ELSE 'Completed'
                       END AS Status,
                       e.IsActive
                FROM Exam.Exam e
                JOIN Academic.Course c ON e.CourseID = c.CourseID
                JOIN Academic.Intake i ON e.IntakeID = i.IntakeID
                JOIN Academic.Branch b ON e.BranchID = b.BranchID
                JOIN Academic.Track t ON e.TrackID = t.TrackID
                WHERE e.ExamID = @ExamID AND e.InstructorID = @InstructorID";
            var exam = await conn.QuerySingleOrDefaultAsync<ExamDetailDto>(sql, new { ExamID = examId, InstructorID = instructorId });
            if (exam != null)
            {
                var qSql = @"
                    SELECT eq.QuestionID, q.QuestionText, q.QuestionType, eq.QuestionOrder AS [Order], eq.QuestionMarks AS Marks
                    FROM Exam.ExamQuestion eq
                    JOIN Exam.Question q ON eq.QuestionID = q.QuestionID
                    WHERE eq.ExamID = @ExamID
                    ORDER BY eq.QuestionOrder";
                exam.Questions = (await conn.QueryAsync<ExamQuestionSummaryDto>(qSql, new { ExamID = examId })).ToList();
            }
            return exam;
        }

        public async Task UpdateExamAsync(int instructorId, int examId, CreateExamDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ExamID", examId);
            p.Add("@ExamName", dto.ExamName);
            p.Add("@ExamType", dto.ExamType);
            p.Add("@TotalMarks", dto.TotalMarks);
            p.Add("@PassMarks", dto.PassMarks);
            p.Add("@DurationMinutes", dto.DurationMinutes);
            p.Add("@StartDateTime", dto.StartDateTime);
            p.Add("@EndDateTime", dto.EndDateTime);
            p.Add("@AllowanceOptions", dto.AllowanceOptions);
            await conn.ExecuteAsync("Exam.SP_Exam_Update", p, commandType: CommandType.StoredProcedure);
        }

        public async Task DeleteExamAsync(int instructorId, int examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@ExamID", examId);
            await conn.ExecuteAsync("Exam.SP_Exam_Delete", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<InstructorDashboardDto> GetDashboardAsync(int instructorId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var dashboard = new InstructorDashboardDto();

            // Get UserID from InstructorID
            var userId = await conn.QuerySingleOrDefaultAsync<int?>(
                "SELECT UserID FROM Academic.Instructor WHERE InstructorID = @InstructorID",
                new { InstructorID = instructorId });

            if (userId.HasValue)
            {
                // Use SP_GetDashboardStats for basic stats
                var stats = await conn.QueryAsync<dynamic>(
                    "Security.SP_GetDashboardStats",
                    new { UserID = userId.Value, UserType = "Instructor" },
                    commandType: CommandType.StoredProcedure);
                
                foreach (var stat in stats)
                {
                    switch ((string)stat.StatType)
                    {
                        case "MyCourses": dashboard.TotalCourses = (int)stat.Value; break;
                        case "MyExams": dashboard.TotalQuestions = (int)stat.Value; break;
                        case "MyQuestions": dashboard.TotalQuestions = (int)stat.Value; break;
                        case "PendingGrading": dashboard.PendingGrading = (int)stat.Value; break;
                    }
                }
            }

            // Get additional stats
            var additionalSql = @"
                SELECT 
                    (SELECT COUNT(DISTINCT se.StudentID) FROM Exam.StudentExam se 
                     JOIN Exam.Exam e ON se.ExamID = e.ExamID WHERE e.InstructorID = @InstructorID) AS TotalStudents,
                    (SELECT COUNT(*) FROM Exam.Exam WHERE InstructorID = @InstructorID 
                     AND GETDATE() BETWEEN StartDateTime AND EndDateTime) AS ActiveExams,
                    (SELECT COUNT(*) FROM Exam.Exam WHERE InstructorID = @InstructorID 
                     AND MONTH(CreatedDate) = MONTH(GETDATE()) AND YEAR(CreatedDate) = YEAR(GETDATE())) AS ExamsCreatedThisMonth";
            var additional = await conn.QuerySingleAsync<dynamic>(additionalSql, new { InstructorID = instructorId });
            dashboard.TotalStudents = additional.TotalStudents;
            dashboard.ActiveExams = additional.ActiveExams;
            dashboard.ExamsCreatedThisMonth = additional.ExamsCreatedThisMonth;

            // Get recent exams using SP
            var recentSql = @"
                SELECT TOP 5 e.ExamID, e.ExamName, c.CourseName, e.EndDateTime,
                    (SELECT COUNT(*) FROM Exam.StudentExam WHERE ExamID = e.ExamID AND SubmissionTime IS NOT NULL) AS CompletedCount,
                    (SELECT AVG(CAST(TotalScore AS DECIMAL(10,2))) FROM Exam.StudentExam WHERE ExamID = e.ExamID AND SubmissionTime IS NOT NULL) AS AverageScore,
                    (SELECT CAST(SUM(CASE WHEN IsPassed = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) 
                     FROM Exam.StudentExam WHERE ExamID = e.ExamID AND SubmissionTime IS NOT NULL) AS PassRate
                FROM Exam.Exam e
                JOIN Academic.Course c ON e.CourseID = c.CourseID
                WHERE e.InstructorID = @InstructorID AND e.EndDateTime < GETDATE()
                ORDER BY e.EndDateTime DESC";
            dashboard.RecentExams = (await conn.QueryAsync<RecentExamDto>(recentSql, new { InstructorID = instructorId })).ToList();

            // Get upcoming exams
            var upcomingSql = @"
                SELECT TOP 5 e.ExamID, e.ExamName, c.CourseName, e.StartDateTime,
                    (SELECT COUNT(*) FROM Exam.StudentExam WHERE ExamID = e.ExamID) AS AssignedStudents
                FROM Exam.Exam e
                JOIN Academic.Course c ON e.CourseID = c.CourseID
                WHERE e.InstructorID = @InstructorID AND e.StartDateTime > GETDATE()
                ORDER BY e.StartDateTime ASC";
            dashboard.UpcomingExams = (await conn.QueryAsync<UpcomingExamDto>(upcomingSql, new { InstructorID = instructorId })).ToList();

            return dashboard;
        }

        public async Task<IEnumerable<QuestionDto>> GetAllQuestionsAsync(int instructorId)
        {
            using var conn = _connectionFactory.CreateConnection();
            
            // Get all courses for this instructor
            var courses = await conn.QueryAsync<int>(
                "Academic.SP_Instructor_GetMyCourses",
                new { InstructorID = instructorId },
                commandType: CommandType.StoredProcedure);
            
            var questions = new List<QuestionDto>();
            foreach (var courseId in courses.Select(c => c))
            {
                var courseQuestions = await conn.QueryAsync<QuestionDto>(
                    "Exam.SP_Question_GetByCourse",
                    new { CourseID = courseId },
                    commandType: CommandType.StoredProcedure);
                questions.AddRange(courseQuestions);
            }
            
            return questions.OrderByDescending(q => q.CreatedDate);
        }
    }
}
