namespace TruyenCV.Dtos.FollowStories;

public class FollowStoryListItemDTO
{
    public int StoryId { get; set; }
    public string StoryTitle { get; set; } = null!;
    public string? StoryCoverImage { get; set; }
    public string? StoryDescription { get; set; }
    public int AuthorId { get; set; }
    public string? AuthorDisplayName { get; set; }
    public string Status { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
}
