using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TruyenCV.Models;

[Table("Bookmarks", Schema = "dbo")]
public class Bookmark
{
    [Required, StringLength(450)]
    [Column("user_id")]
    public string ApplicationUserId { get; set; } = null!;

    [ForeignKey(nameof(ApplicationUserId))]
    public ApplicationUser ApplicationUser { get; set; } = null!;

    [Column("story_id")]
    public int StoryId { get; set; }
    public Story Story { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}
