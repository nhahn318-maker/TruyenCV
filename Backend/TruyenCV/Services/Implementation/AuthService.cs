using Microsoft.AspNetCore.Identity;
using TruyenCV.Dtos.Auth;
using TruyenCV.Models;
using TruyenCV.Services.IService;

namespace TruyenCV.Services.Implementation;

public class AuthService : IAuthService
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly SignInManager<ApplicationUser> _signInManager;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        UserManager<ApplicationUser> userManager,
        SignInManager<ApplicationUser> signInManager,
        IJwtTokenService jwtTokenService,
        ILogger<AuthService> logger)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _jwtTokenService = jwtTokenService;
        _logger = logger;
    }

    public async Task<(bool Success, string Message, AuthResponseDTO? Data)> RegisterAsync(RegisterDTO dto)
    {
        try
        {
            // Validate input
            if (string.IsNullOrWhiteSpace(dto.Email) || string.IsNullOrWhiteSpace(dto.UserName) ||
                string.IsNullOrWhiteSpace(dto.FullName) ||
                string.IsNullOrWhiteSpace(dto.Password) || string.IsNullOrWhiteSpace(dto.ConfirmPassword))
            {
                return (false, "D? li?u không ???c ?? tr?ng.", null);
            }

            if (dto.Password != dto.ConfirmPassword)
            {
                return (false, "M?t kh?u không kh?p.", null);
            }

            if (dto.Password.Length < 6)
            {
                return (false, "M?t kh?u ph?i có ít nh?t 6 ký t?.", null);
            }

            if (dto.UserName.Length < 3 || dto.UserName.Length > 50)
            {
                return (false, "Tên ??ng nh?p ph?i t? 3 ??n 50 ký t?.", null);
            }

            // Check if email already exists
            var existingEmail = await _userManager.FindByEmailAsync(dto.Email);
            if (existingEmail is not null)
            {
                return (false, "Email ?ã ???c ??ng ký.", null);
            }

            // Check if username already exists
            var existingUserName = await _userManager.FindByNameAsync(dto.UserName);
            if (existingUserName is not null)
            {
                return (false, "Tên ??ng nh?p ?ã t?n t?i.", null);
            }

            // Create new user
            var user = new ApplicationUser
            {
                Email = dto.Email.Trim(),
                UserName = dto.UserName.Trim(),
                FullName = dto.FullName.Trim()
            };

            var result = await _userManager.CreateAsync(user, dto.Password);

            if (!result.Succeeded)
            {
                var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                return (false, $"??ng ký th?t b?i: {errors}", null);
            }

            // Assign default role "Customer"
            var roleResult = await _userManager.AddToRoleAsync(user, "Customer");
            if (!roleResult.Succeeded)
            {
                _logger.LogWarning($"Không th? gán role Customer cho user {user.Id}");
            }

            // Get roles
            var roles = await _userManager.GetRolesAsync(user);

            // Generate JWT token
            var token = _jwtTokenService.GenerateToken(user, roles);

            var response = new AuthResponseDTO
            {
                UserId = user.Id,
                Email = user.Email,
                FullName = user.FullName,
                UserName = user.UserName,
                Token = token,
                Roles = roles
            };

            return (true, "??ng ký thành công.", response);
        }
        catch (Exception ex)
        {
            _logger.LogError($"L?i ??ng ký: {ex.Message}");
            return (false, "??ng ký th?t b?i. Vui lòng th? l?i.", null);
        }
    }

    public async Task<(bool Success, string Message, AuthResponseDTO? Data)> LoginAsync(LoginDTO dto)
    {
        try
        {
            // Validate input
            if (string.IsNullOrWhiteSpace(dto.UserName) || string.IsNullOrWhiteSpace(dto.Password))
            {
                return (false, "Tên ??ng nh?p và m?t kh?u không ???c ?? tr?ng.", null);
            }

            // Find user by UserName or Email
            var user = await _userManager.FindByNameAsync(dto.UserName)
                    ?? await _userManager.FindByEmailAsync(dto.UserName);

            if (user is null)
            {
                return (false, "Tên ??ng nh?p ho?c m?t kh?u không ?úng.", null);
            }

            // Check password
            var result = await _signInManager.PasswordSignInAsync(user.UserName, dto.Password, false, false);

            if (!result.Succeeded)
            {
                return (false, "Tên ??ng nh?p ho?c m?t kh?u không ?úng.", null);
            }

            // Get roles
            var roles = await _userManager.GetRolesAsync(user);

            // Generate JWT token
            var token = _jwtTokenService.GenerateToken(user, roles);

            var response = new AuthResponseDTO
            {
                UserId = user.Id,
                Email = user.Email,
                FullName = user.FullName,
                UserName = user.UserName,
                Token = token,
                Roles = roles
            };

            return (true, "??ng nh?p thành công.", response);
        }
        catch (Exception ex)
        {
            _logger.LogError($"L?i ??ng nh?p: {ex.Message}");
            return (false, "??ng nh?p th?t b?i. Vui lòng th? l?i.", null);
        }
    }
}
