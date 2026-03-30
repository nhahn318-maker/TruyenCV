namespace TruyenCV.Dtos.Stories;

public class StoryBriefDTO
{
    public int StoryId { get; set; }
    public string Title { get; set; } = null!;
    public string Status { get; set; } = null!;
    public DateTime UpdatedAt { get; set; }
}
