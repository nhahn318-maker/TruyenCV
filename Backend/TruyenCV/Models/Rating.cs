using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;


namespace TruyenCV.Models;

[Table("Ratings", Schema = "dbo")]
public class Rating
{
    [Key]
    [Column("rating_id")]
    public int RatingId { get; set; }

    [Required, StringLength(450)]
    [Column("user_id")]
    public string ApplicationUserId { get; set; } = null!;

    [ForeignKey(nameof(ApplicationUserId))]
    public ApplicationUser ApplicationUser { get; set; } = null!;

    [Column("story_id")]
    public int StoryId { get; set; }
    public Story Story { get; set; } = null!;

    [Column("score")]
    public byte Score { get; set; } // 1..5

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}
