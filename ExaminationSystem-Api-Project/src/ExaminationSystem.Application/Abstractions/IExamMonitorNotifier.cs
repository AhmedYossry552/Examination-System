using System.Threading.Tasks;

namespace ExaminationSystem.Application.Abstractions
{
    public interface IExamMonitorNotifier
    {
        Task NotifyAsync(string eventName, object payload);
    }
}