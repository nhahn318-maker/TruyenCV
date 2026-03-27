using System.ComponentModel.DataAnnotations;

namespace TruyenCV.Dtos.Chapters;

public class ChapterUpdateDTO
{
    [StringLength(200)]
    public string? Title { get; set; }

    [Required]
    public string Content { get; set; } = null!;
}
