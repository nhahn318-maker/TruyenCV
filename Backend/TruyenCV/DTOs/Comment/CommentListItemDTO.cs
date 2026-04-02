namespace TruyenCV.Dtos.Comments;

public class CommentListItemDTO
{
    public int CommentId { get; set; }
    public string ApplicationUserId { get; set; } = null!;
    public string? UserName { get; set; }
    public string Content { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
}
