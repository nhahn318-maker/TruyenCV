using System.ComponentModel.DataAnnotations.Schema;

namespace TruyenCV.Models;

[Table("StoryGenres", Schema = "dbo")]
public class StoryGenre
{
    [Column("story_id")]
    public int StoryId { get; set; }
    public Story Story { get; set; } = null!;

    [Column("genre_id")]
    public int GenreId { get; set; }
    public Genre Genre { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}
