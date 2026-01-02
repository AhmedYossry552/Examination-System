using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace ExaminationSystem.Api.Hubs
{
    [Authorize]
    public class ExamMonitorHub : Hub
    {
    }
}
