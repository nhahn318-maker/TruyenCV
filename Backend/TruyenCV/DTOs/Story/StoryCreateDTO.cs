using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace TruyenCV.Dtos.Stories;

public class StoryCreateDTO
{
    [BindingBehavior(BindingBehavior.Optional)]
    public string? Title { get; set; }
    
    [BindingBehavior(BindingBehavior.Optional)]
    public int AuthorId { get; set; }
    
    [BindingBehavior(BindingBehavior.Optional)]
    public string? Description { get; set; }

    // Support both file uploads and URL strings
    [BindingBehavior(BindingBehavior.Optional)]
    public IFormFile? CoverImageFile { get; set; }
    
    [BindingBehavior(BindingBehavior.Optional)]
    public string? CoverImage { get; set; }
    
    [BindingBehavior(BindingBehavior.Optional)]
    public IFormFile? BannerImageFile { get; set; }
    
    [BindingBehavior(BindingBehavior.Optional)]
    public string? BannerImage { get; set; }

    [BindingBehavior(BindingBehavior.Optional)]
    public int? PrimaryGenreId { get; set; }
    
    [BindingBehavior(BindingBehavior.Optional)]
    public string? Status { get; set; }          // "Đang tiến hành" | "Đã hoàn thành"

    [BindingBehavior(BindingBehavior.Optional)]
    public List<int>? GenreIds { get; set; }     // ✅ list thể loại cho StoryGenres
}
