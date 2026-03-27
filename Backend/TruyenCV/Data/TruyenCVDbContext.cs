using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using TruyenCV.Models;

namespace TruyenCV.Data
{
    public partial class TruyenCVDbContext : IdentityDbContext<ApplicationUser>
    {
        public TruyenCVDbContext(DbContextOptions<TruyenCVDbContext> options)
            : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
        }
    }
}
