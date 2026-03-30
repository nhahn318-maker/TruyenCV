namespace TruyenCV.Dtos.Bookmarks;

public class BookmarkDTO
{
    public string ApplicationUserId { get; set; } = null!;
    public int StoryId { get; set; }
    public string StoryTitle { get; set; } = null!;
    public string? StoryCoverImage { get; set; }
    public string? StoryDescription { get; set; }
    public int AuthorId { get; set; }
    public string? AuthorDisplayName { get; set; }
    public DateTime CreatedAt { get; set; }
}
