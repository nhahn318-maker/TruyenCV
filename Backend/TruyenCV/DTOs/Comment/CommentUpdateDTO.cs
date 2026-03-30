using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace TruyenCV.Dtos.Comments;

public class CommentUpdateDTO
{
    [BindingBehavior(BindingBehavior.Required)]
    public string? Content { get; set; }
}
