namespace TruyenCV.Dtos.FollowAuthors;

public class FollowAuthorListItemDTO
{
    public int AuthorId { get; set; }
    public string? AuthorDisplayName { get; set; }
    public string? AuthorBio { get; set; }
    public string? AuthorAvatar { get; set; }
    public int TotalStories { get; set; }
    public DateTime CreatedAt { get; set; }
}
