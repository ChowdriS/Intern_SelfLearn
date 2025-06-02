using DoctorApi.Models;

namespace DoctorApi.Interfaces
{
    public interface IAppointmentRepository
    {
        Task<IEnumerable<Appointment>> GetAllAsync();
        Task<Appointment?> GetByIdAsync(int id);
        Task AddAsync(Appointment appointment);
        Task<bool> SaveChangesAsync();
    }
}
