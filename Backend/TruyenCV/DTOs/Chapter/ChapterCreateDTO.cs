using System.ComponentModel.DataAnnotations;

namespace TruyenCV.Dtos.Chapters;

public class ChapterCreateDTO
{
    [Required]
    public int StoryId { get; set; }

    [Required]
    public int ChapterNumber { get; set; }

    [StringLength(200)]
    public string? Title { get; set; }

    [Required]
    public string Content { get; set; } = null!;
}
