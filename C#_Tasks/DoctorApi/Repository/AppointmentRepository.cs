using Microsoft.EntityFrameworkCore;
using DoctorApi.Interfaces;
using DoctorApi.Models;
using DoctorApi.Service;

namespace DoctorApi.Repositories
{
    public class AppointmentRepository : IAppointmentRepository
    {
        private readonly AppDbContext _context;
        List<Appointment> _records = new List<Appointment>();


        public AppointmentRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Appointment>> GetAllAsync()
        {
            return _records;
            // return await _context.Appointments.Include(a => a.Patient).ToListAsync();
        }

        public async Task<Appointment?> GetByIdAsync(int id)
        {
            return (Appointment)_records.Where(x => x.Id == id);
            // return await _context.Appointments.Include(a => a.Patient).FirstOrDefaultAsync(a => a.Id == id);
        }

        public async Task AddAsync(Appointment appointment)
        {
            _records.Add(appointment);
            return;
            // await _context.Appointments.AddAsync(appointment);
        }

        public async Task<bool> SaveChangesAsync()
        {
            return (await _context.SaveChangesAsync()) > 0;
        }
    }
}
