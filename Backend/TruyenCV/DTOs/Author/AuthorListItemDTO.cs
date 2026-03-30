using System.ComponentModel.DataAnnotations;

namespace TruyenCV.Dtos.Authors;

public class AuthorListItemDTO
{
    public int AuthorId { get; set; }
    public string DisplayName { get; set; } = null!;
    public string? AvatarUrl { get; set; }
    public DateTime CreatedAt { get; set; }
}