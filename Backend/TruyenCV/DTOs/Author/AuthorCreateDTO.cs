using System.ComponentModel.DataAnnotations;

namespace TruyenCV.Dtos.Authors;

public class AuthorCreateDTO
{
    [Required, StringLength(150)]
    public string DisplayName { get; set; } = null!;

    public string? Bio { get; set; }

    [StringLength(500)]
    public string? AvatarUrl { get; set; }

    [StringLength(450)]
    public string? ApplicationUserId { get; set; }
}
