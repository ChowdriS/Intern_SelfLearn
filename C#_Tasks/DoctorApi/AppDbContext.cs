using System;
using DoctorApi.Models;
namespace DoctorApi.Service;

using Microsoft.EntityFrameworkCore;

public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions options) : base(options) {}

        public DbSet<Patient> Patients => Set<Patient>();
        public DbSet<Appointment> Appointments => Set<Appointment>();
    }
