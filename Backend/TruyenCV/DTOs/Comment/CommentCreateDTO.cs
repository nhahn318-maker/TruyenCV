using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace TruyenCV.Dtos.Comments;

public class CommentCreateDTO
{
    [BindingBehavior(BindingBehavior.Optional)]
    public int? StoryId { get; set; }

    [BindingBehavior(BindingBehavior.Optional)]
    public int? ChapterId { get; set; }

    [BindingBehavior(BindingBehavior.Required)]
    public string? Content { get; set; }
}
