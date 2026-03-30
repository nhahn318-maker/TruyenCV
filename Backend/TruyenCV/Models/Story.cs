using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TruyenCV.Models;

[Table("Stories", Schema = "dbo")]
public class Story
{
    [Key]
    [Column("story_id")]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int StoryId { get; set; }


    [Required, StringLength(200)]
    [Column("title")]
    public string Title { get; set; } = null!;

    // FK -> Authors.author_id
    [Column("author_id")]
    public int AuthorId { get; set; }

    [ForeignKey(nameof(AuthorId))]
    public Author Author { get; set; } = null!;

    [Column("description")]
    public string? Description { get; set; }

    [StringLength(500)]
    [Column("cover_image")]
    public string? CoverImage { get; set; }
    [StringLength(500)]
    [Column("Banner_image")]
    public string? BannerImage { get; set; }

    [Column("primary_genre_id")]
    public int? PrimaryGenreId { get; set; }

    [ForeignKey(nameof(PrimaryGenreId))]
    public Genre? PrimaryGenre { get; set; }

    [Required, StringLength(20)]
    [Column("status")]
    public string Status { get; set; } = "ongoing"; // ongoing | completed

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    public ICollection<StoryGenre> StoryGenres { get; set; } = new List<StoryGenre>();
    public ICollection<Chapter> Chapters { get; set; } = new List<Chapter>();

    public ICollection<Bookmark> Bookmarks { get; set; } = new List<Bookmark>();
    public ICollection<Rating> Ratings { get; set; } = new List<Rating>();
    public ICollection<ReadingHistory> ReadingHistories { get; set; } = new List<ReadingHistory>();

    public ICollection<Comment> StoryComments { get; set; } = new List<Comment>();
    public ICollection<FollowStory> FollowStories { get; set; } = new List<FollowStory>();
}
