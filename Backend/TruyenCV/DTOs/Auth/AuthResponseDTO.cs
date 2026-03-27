namespace TruyenCV.Dtos.Auth;

public class AuthResponseDTO
{
    public required string UserId { get; set; }
    public required string Email { get; set; }
    public required string FullName { get; set; }
    public required string UserName { get; set; }
    public string? Token { get; set; }
    public IList<string>? Roles { get; set; }
}
