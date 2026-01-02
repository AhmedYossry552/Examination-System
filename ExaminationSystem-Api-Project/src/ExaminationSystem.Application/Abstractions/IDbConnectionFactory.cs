using System.Data;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IDbConnectionFactory
    {
        IDbConnection CreateConnection();
    }
}
