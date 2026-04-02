using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TruyenCV.Models;

[Table("Genres", Schema = "dbo")]
public class Genre
{
    [Key]
    [Column("genre_id")]
    public int GenreId { get; set; }

    [Required, StringLength(100)]
    [Column("name")]
    public string Name { get; set; } = null!;

    public ICollection<StoryGenre> StoryGenres { get; set; } = new List<StoryGenre>();
    public ICollection<Story> PrimaryGenreStories { get; set; } = new List<Story>();
}
