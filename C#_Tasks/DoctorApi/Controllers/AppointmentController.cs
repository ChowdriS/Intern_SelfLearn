using Microsoft.AspNetCore.Mvc;
using DoctorApi.Interfaces;
using DoctorApi.Models;

namespace DoctorApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AppointmentController : ControllerBase
    {
        private readonly IAppointmentService _service;

        public AppointmentController(IAppointmentService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var appointments = await _service.GetAppointmentsAsync();
            return Ok(appointments);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> Get(int id)
        {
            var appointment = await _service.GetAppointmentByIdAsync(id);
            if (appointment == null)
                return NotFound();
            return Ok(appointment);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Appointment appointment)
        {
            await _service.AddAppointmentAsync(appointment);
            return CreatedAtAction(nameof(Get), new { id = appointment.Id }, appointment);
        }
    }
}
