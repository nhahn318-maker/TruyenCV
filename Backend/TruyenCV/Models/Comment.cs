using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TruyenCV.Models;

[Table("Comments", Schema = "dbo")]
public class Comment
{
    [Key]
    [Column("comment_id")]
    public int CommentId { get; set; }

    [Required, StringLength(450)]
    [Column("user_id")]
    public string ApplicationUserId { get; set; } = null!;

    [ForeignKey(nameof(ApplicationUserId))]
    public ApplicationUser ApplicationUser { get; set; } = null!;

    // Comment 1 trong 2: story OR chapter
    [Column("story_id")]
    public int? StoryId { get; set; }
    public Story? Story { get; set; }

    [Column("chapter_id")]
    public int? ChapterId { get; set; }
    public Chapter? Chapter { get; set; }

    [Required]
    [Column("content")]
    public string Content { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}
