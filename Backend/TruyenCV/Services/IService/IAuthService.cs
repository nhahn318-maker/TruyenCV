using TruyenCV.Dtos.Auth;

namespace TruyenCV.Services.IService;

public interface IAuthService
{
    Task<(bool Success, string Message, AuthResponseDTO? Data)> RegisterAsync(RegisterDTO dto);
    Task<(bool Success, string Message, AuthResponseDTO? Data)> LoginAsync(LoginDTO dto);
}
