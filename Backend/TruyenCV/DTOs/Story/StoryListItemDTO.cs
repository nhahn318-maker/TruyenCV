namespace TruyenCV.Dtos.Stories;

public class StoryListItemDTO
{
    public int StoryId { get; set; }
    public string Title { get; set; } = null!;
    public int AuthorId { get; set; }
    public int? PrimaryGenreId { get; set; }
    public string Status { get; set; } = null!;
    public string CoverImage { get; set; } = null!;
    public DateTime UpdatedAt { get; set; }
}
