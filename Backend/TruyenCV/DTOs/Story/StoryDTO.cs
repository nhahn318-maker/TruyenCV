namespace TruyenCV.Dtos.Stories;

public class StoryDTO
{
    public int StoryId { get; set; }
    public string Title { get; set; } = null!;
    public int AuthorId { get; set; }

    public int? PrimaryGenreId { get; set; }
    public string Status { get; set; } = "Đang tiến hành";

    public string? Description { get; set; }
    public string? CoverImage { get; set; }
    public string? BannerImage { get; set; }     // ✅ banner

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public List<int> GenreIds { get; set; } = new(); // ✅ from StoryGenres
    public List<object> Chapters { get; set; } = new(); // ✅ danh sách chapter của story
}
