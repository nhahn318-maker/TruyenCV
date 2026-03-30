namespace TruyenCV.Dtos.ReadingHistory;

public class ReadingHistoryDTO
{
    public int HistoryId { get; set; }
    public string ApplicationUserId { get; set; } = null!;
    public int StoryId { get; set; }
    public string StoryTitle { get; set; } = null!;
    public int? LastReadChapterId { get; set; }
    public string? LastReadChapterTitle { get; set; }
    public int? LastReadChapterNumber { get; set; }
    public string? StorycoverImage { get; set; }
    public DateTime UpdatedAt { get; set; }
}
