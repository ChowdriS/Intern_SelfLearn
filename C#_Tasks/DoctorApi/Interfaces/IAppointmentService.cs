using DoctorApi.Models;

namespace DoctorApi.Interfaces
{
    public interface IAppointmentService
    {
        Task<IEnumerable<Appointment>> GetAppointmentsAsync();
        Task<Appointment?> GetAppointmentByIdAsync(int id);
        Task AddAppointmentAsync(Appointment appointment);
    }
}