namespace TruyenCV.Dtos.Ratings;

public class RatingDTO
{
    public int RatingId { get; set; }
    public int StoryId { get; set; }
    public string ApplicationUserId { get; set; } = null!;
    public byte Score { get; set; }
    public DateTime CreatedAt { get; set; }
}
