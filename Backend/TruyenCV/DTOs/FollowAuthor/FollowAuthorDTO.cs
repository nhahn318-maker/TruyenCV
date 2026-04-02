namespace TruyenCV.Dtos.FollowAuthors;

public class FollowAuthorDTO
{
    public string ApplicationUserId { get; set; } = null!;
    public int AuthorId { get; set; }
    public string? AuthorDisplayName { get; set; }
    public string? AuthorBio { get; set; }
    public string? AuthorAvatar { get; set; }
    public int TotalStories { get; set; }
    public DateTime CreatedAt { get; set; }
}
