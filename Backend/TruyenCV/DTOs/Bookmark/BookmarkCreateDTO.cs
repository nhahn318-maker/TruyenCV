using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace TruyenCV.Dtos.Bookmarks;

public class BookmarkCreateDTO
{
    [BindingBehavior(BindingBehavior.Required)]
    public int StoryId { get; set; }
}
