using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace TruyenCV.Dtos.FollowAuthors;

public class FollowAuthorCreateDTO
{
    [BindingBehavior(BindingBehavior.Required)]
    public int AuthorId { get; set; }
}
