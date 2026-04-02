namespace TruyenCV.Dtos.Authors;

public class AuthorPendingListDTO
{
    public int AuthorId { get; set; }
    public string DisplayName { get; set; } = null!;
    public string? Bio { get; set; }
    public string? AvatarUrl { get; set; }
    public string UserEmail { get; set; } = null!;
    public string UserFullName { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
}
