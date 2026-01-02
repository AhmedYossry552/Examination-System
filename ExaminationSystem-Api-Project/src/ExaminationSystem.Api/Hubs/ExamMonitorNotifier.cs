using System.Threading.Tasks;
using ExaminationSystem.Application.Abstractions;
using Microsoft.AspNetCore.SignalR;

namespace ExaminationSystem.Api.Hubs
{
    public class ExamMonitorNotifier : IExamMonitorNotifier
    {
        private readonly IHubContext<ExamMonitorHub> _hubContext;
        public ExamMonitorNotifier(IHubContext<ExamMonitorHub> hubContext)
        {
            _hubContext = hubContext;
        }

        public Task NotifyAsync(string eventName, object payload)
        {
            return _hubContext.Clients.All.SendAsync(eventName, payload);
        }
    }
}