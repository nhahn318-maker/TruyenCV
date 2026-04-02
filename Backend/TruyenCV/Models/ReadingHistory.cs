using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TruyenCV.Models;

[Table("ReadingHistory", Schema = "dbo")]
public class ReadingHistory
{
    [Key]
    [Column("history_id")]
    public int HistoryId { get; set; }

    [Required, StringLength(450)]
    [Column("user_id")]
    public string ApplicationUserId { get; set; } = null!;

    [ForeignKey(nameof(ApplicationUserId))]
    public ApplicationUser ApplicationUser { get; set; } = null!;

    [Column("story_id")]
    public int StoryId { get; set; }
    public Story Story { get; set; } = null!;

    [Column("last_read_chapter_id")]
    public int? LastReadChapterId { get; set; }

    [ForeignKey(nameof(LastReadChapterId))]
    public Chapter? LastReadChapter { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}
