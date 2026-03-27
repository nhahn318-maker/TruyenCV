using Microsoft.AspNetCore.Identity;

namespace TruyenCV.Models
{
    public class ApplicationUser : IdentityUser
    {
        // Bạn có thể thêm các property custom nếu cần, ví dụ:
        public required string FullName { get; set; }
    }
}
