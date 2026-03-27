using TruyenCV.Models;

namespace TruyenCV.Services.IService;

public interface IJwtTokenService
{
    string GenerateToken(ApplicationUser user, IList<string> roles);
}
