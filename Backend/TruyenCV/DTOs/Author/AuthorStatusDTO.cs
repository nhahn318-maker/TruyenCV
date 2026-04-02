namespace TruyenCV.Dtos.Authors;

public class AuthorStatusDTO
{
    public int AuthorId { get; set; }
    public string DisplayName { get; set; } = null!;
    public string? Bio { get; set; }
    public string? AvatarUrl { get; set; }
    public string Status { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime? ApprovedAt { get; set; }
}
