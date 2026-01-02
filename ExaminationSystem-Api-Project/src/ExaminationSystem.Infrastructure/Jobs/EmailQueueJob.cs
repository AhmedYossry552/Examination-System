using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using ExaminationSystem.Application.Abstractions;
using Microsoft.Extensions.Logging;
using Quartz;

namespace ExaminationSystem.Infrastructure.Jobs
{
    public class EmailQueueJob : IJob
    {
        private readonly IDbConnectionFactory _connectionFactory;
        private readonly ILogger<EmailQueueJob> _logger;

        public EmailQueueJob(IDbConnectionFactory connectionFactory, ILogger<EmailQueueJob> logger)
        {
            _connectionFactory = connectionFactory;
            _logger = logger;
        }

        public async Task Execute(IJobExecutionContext context)
        {
            try
            {
                using var conn = _connectionFactory.CreateConnection();
                var p = new DynamicParameters();
                p.Add("@BatchSize", 20);

                var emails = await conn.QueryAsync<EmailQueueItem>(
                    "Security.SP_ProcessEmailQueue",
                    p,
                    commandType: CommandType.StoredProcedure);

                foreach (var email in emails)
                {
                    try
                    {
                        // Here we would send via SMTP or provider; for now, log and mark sent
                        _logger.LogInformation("Sending queued email {EmailID} to {ToEmail} - {Subject}", email.EmailID, email.ToEmail, email.Subject);

                        await conn.ExecuteAsync(
                            "Security.SP_MarkEmailAsSent",
                            new { EmailID = email.EmailID },
                            commandType: CommandType.StoredProcedure);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to send email {EmailID}. Will mark as failed.", email.EmailID);
                        await conn.ExecuteAsync(
                            "Security.SP_MarkEmailAsFailed",
                            new { EmailID = email.EmailID, ErrorMessage = ex.Message },
                            commandType: CommandType.StoredProcedure);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "EmailQueueJob run failed");
            }
        }

        private class EmailQueueItem
        {
            public int EmailID { get; set; }
            public string ToEmail { get; set; } = string.Empty;
            public string? ToName { get; set; }
            public string? FromEmail { get; set; }
            public string? FromName { get; set; }
            public string Subject { get; set; } = string.Empty;
            public string Body { get; set; } = string.Empty;
            public string EmailType { get; set; } = string.Empty;
            public string Priority { get; set; } = "Normal";
            public int RetryCount { get; set; }
        }
    }
}