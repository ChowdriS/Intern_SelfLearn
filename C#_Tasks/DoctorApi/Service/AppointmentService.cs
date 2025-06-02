using DoctorApi.Interfaces;
using DoctorApi.Models;

namespace DoctorApi.Services
{
    public class AppointmentService : IAppointmentService
    {
        private readonly IAppointmentRepository _repo;

        public AppointmentService(IAppointmentRepository repo)
        {
            _repo = repo;
        }

        public async Task<IEnumerable<Appointment>> GetAppointmentsAsync()
        {
            return await _repo.GetAllAsync();
        }

        public async Task<Appointment?> GetAppointmentByIdAsync(int id)
        {
            return await _repo.GetByIdAsync(id);
        }

        public async Task AddAppointmentAsync(Appointment appointment)
        {
            await _repo.AddAsync(appointment);
            await _repo.SaveChangesAsync();
        }
    }
}
