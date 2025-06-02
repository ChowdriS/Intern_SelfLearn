namespace DoctorApi.Models
{
    public class Appointment
    {
        public int Id { get; set; }
        public DateTime Date { get; set; }
        public string Reason { get; set; } = string.Empty;

        // Relationships
        public int PatientId { get; set; }
        public Patient? Patient { get; set; }
    }
}
