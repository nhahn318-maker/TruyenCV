namespace TruyenCV.Dtos.Stories;

public class StoryTopDTO
{
    public int StoryId { get; set; }
    public string Title { get; set; } = null!;
    public string? CoverImage { get; set; }
    public string AuthorName { get; set; } = null!;
    public int ReadCount { get; set; }
    public int TotalChapters { get; set; }
    public string Status { get; set; } = null!;
}
