using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TruyenCV.Models;

[Table("Chapters", Schema = "dbo")]
public class Chapter
{
    [Key]
    [Column("chapter_id")]
    public int ChapterId { get; set; }

    [Column("story_id")]
    public int StoryId { get; set; }
    public Story Story { get; set; } = null!;

    [Column("chapter_number")]
    public int ChapterNumber { get; set; }

    [StringLength(200)]
    [Column("title")]
    public string? Title { get; set; }

    [Required]
    [Column("content")]
    public string Content { get; set; } = null!;
    [Column("read_cont")]
    public int ReadCont { get; set; } = 0;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    public ICollection<Comment> ChapterComments { get; set; } = new List<Comment>();
}
