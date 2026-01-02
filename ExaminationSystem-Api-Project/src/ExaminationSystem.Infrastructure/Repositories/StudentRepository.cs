using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class StudentRepository : IStudentRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;
        public StudentRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<int> GetStudentIdByUserIdAsync(int userId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = "SELECT StudentID FROM Academic.Student WHERE UserID = @UserID";
            var id = await conn.ExecuteScalarAsync<int?>(sql, new { UserID = userId });
            if (id == null)
                throw new System.Exception("Student record not found for current user.");
            return id.Value;
        }

        public async Task<IEnumerable<AvailableExamDto>> GetAvailableExamsAsync(int studentId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            var list = await conn.QueryAsync<AvailableExamDto>("Exam.SP_Student_GetAvailableExams", p, commandType: CommandType.StoredProcedure);
            return list;
        }

        public async Task StartExamAsync(int studentId, int examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            p.Add("@ExamID", examId);
            await conn.ExecuteAsync("Exam.SP_Student_StartExam", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<int?> GetStudentExamIdAsync(int studentId, int examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var sql = "SELECT StudentExamID FROM Exam.StudentExam WHERE StudentID = @StudentID AND ExamID = @ExamID";
            return await conn.ExecuteScalarAsync<int?>(sql, new { StudentID = studentId, ExamID = examId });
        }

        public async Task SubmitAnswerAsync(int studentExamId, int questionId, string? answerText, int? selectedOptionId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@StudentExamID", studentExamId);
            p.Add("@QuestionID", questionId);
            p.Add("@StudentAnswerText", answerText);
            p.Add("@SelectedOptionID", selectedOptionId);
            await conn.ExecuteAsync("Exam.SP_Student_SubmitAnswer", p, commandType: CommandType.StoredProcedure);
        }

        public async Task SubmitExamAsync(int studentExamId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@StudentExamID", studentExamId);
            await conn.ExecuteAsync("Exam.SP_Student_SubmitExam", p, commandType: CommandType.StoredProcedure);
        }

        public async Task<StudentExamWithQuestionsDto> GetExamWithQuestionsAsync(int studentId, int examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            p.Add("@ExamID", examId);
            using var multi = await conn.QueryMultipleAsync("Exam.SP_API_GetStudentExamWithQuestions", p, commandType: CommandType.StoredProcedure);

            var header = await multi.ReadFirstOrDefaultAsync<ExamHeaderDto>();
            var questions = (await multi.ReadAsync<ExamQuestionDto>()).ToList();
            var options = (await multi.ReadAsync<OptionDto>()).ToList();

            // attach options to questions
            var lookup = options.GroupBy(o => o.QuestionID).ToDictionary(g => g.Key, g => g.ToList());
            foreach (var q in questions)
            {
                if (lookup.TryGetValue(q.QuestionID, out var opts))
                    q.Options = opts;
            }

            return new StudentExamWithQuestionsDto
            {
                Exam = header ?? new ExamHeaderDto(),
                Questions = questions
            };
        }

        public async Task<StudentExamResultsDto> GetExamResultsAsync(int studentId, int examId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            p.Add("@ExamID", examId);
            using var multi = await conn.QueryMultipleAsync("Exam.SP_API_GetExamResults", p, commandType: CommandType.StoredProcedure);

            var header = await multi.ReadFirstOrDefaultAsync<ExamResultsHeaderDto>();
            var questions = (await multi.ReadAsync<QuestionResultDto>()).ToList();

            return new StudentExamResultsDto
            {
                Exam = header ?? new ExamResultsHeaderDto(),
                Questions = questions
            };
        }

        public async Task<StudentProgressDto> GetStudentProgressAsync(int studentId)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@StudentID", studentId);
            using var multi = await conn.QueryMultipleAsync("Academic.SP_API_GetStudentProgress", p, commandType: CommandType.StoredProcedure);

            var overview = await multi.ReadFirstOrDefaultAsync<StudentProgressOverviewDto>();
            var courses = (await multi.ReadAsync<StudentCourseProgressDto>()).ToList();
            var recent = (await multi.ReadAsync<RecentExamResultDto>()).ToList();

            return new StudentProgressDto
            {
                Overview = overview ?? new StudentProgressOverviewDto(),
                Courses = courses,
                RecentExams = recent
            };
        }
    }
}
