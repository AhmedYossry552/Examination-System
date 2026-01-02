using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using ExaminationSystem.Application.Abstractions.Models;

namespace ExaminationSystem.Infrastructure.Repositories
{
    public class ProfileRepository : IProfileRepository
    {
        private readonly IDbConnectionFactory _connectionFactory;
        public ProfileRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<ProfileDto> GetProfileAsync(int userId)
        {
            using var conn = _connectionFactory.CreateConnection();
            const string sql = @"SELECT UserID, Username, Email, FirstName, LastName, PhoneNumber, UserType
                                 FROM Security.[User] WHERE UserID = @UserID";
            var row = await conn.QuerySingleAsync(sql, new { UserID = userId });
            return new ProfileDto
            {
                UserID = (int)row.UserID,
                Username = (string)row.Username,
                Email = (string)row.Email,
                FirstName = (string)row.FirstName,
                LastName = (string)row.LastName,
                PhoneNumber = (string?)row.PhoneNumber,
                UserType = (string)row.UserType
            };
        }

        public async Task UpdateProfileAsync(int userId, ProfileUpdateDto dto)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@Email", dto.Email);
            p.Add("@FirstName", dto.FirstName);
            p.Add("@LastName", dto.LastName);
            p.Add("@PhoneNumber", dto.PhoneNumber);
            p.Add("@IsActive", null);
            await conn.ExecuteAsync("Security.SP_Admin_UpdateUser", p, commandType: System.Data.CommandType.StoredProcedure);
        }

        public async Task ChangePasswordAsync(int userId, string oldPassword, string newPassword)
        {
            using var conn = _connectionFactory.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@UserID", userId);
            p.Add("@OldPassword", oldPassword);
            p.Add("@NewPassword", newPassword);
            await conn.ExecuteAsync("Security.SP_Admin_ChangePassword", p, commandType: System.Data.CommandType.StoredProcedure);
        }
    }
}
