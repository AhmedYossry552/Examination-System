using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using ExaminationSystem.Application.Abstractions;

namespace ExaminationSystem.Infrastructure.Data
{
    public class SqlConnectionFactory : IDbConnectionFactory
    {
        private readonly string _connectionString;

        public SqlConnectionFactory(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("Default") ?? string.Empty;
        }

        public IDbConnection CreateConnection()
        {
            return new SqlConnection(_connectionString);
        }
    }
}
