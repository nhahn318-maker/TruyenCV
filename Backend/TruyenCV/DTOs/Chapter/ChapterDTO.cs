namespace TruyenCV.Dtos.Chapters;

public class ChapterDTO
{
    public int ChapterId { get; set; }
    public int StoryId { get; set; }
    public int ChapterNumber { get; set; }
    public string? Title { get; set; }
    public string Content { get; set; } = null!;
    public int ReadCont { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
