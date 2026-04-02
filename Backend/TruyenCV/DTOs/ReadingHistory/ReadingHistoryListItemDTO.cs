namespace TruyenCV.Dtos.ReadingHistory;

public class ReadingHistoryListItemDTO
{
    public int HistoryId { get; set; }
    public int StoryId { get; set; }
    public string StoryTitle { get; set; } = null!;
    public int? LastReadChapterId { get; set; }
    public int? LastReadChapterNumber { get; set; }
    public string? LastReadChapterTitle { get; set; }
    public string? StoryCoverImage { get; set; }
    public DateTime UpdatedAt { get; set; }
}
