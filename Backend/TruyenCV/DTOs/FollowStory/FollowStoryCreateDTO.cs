using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace TruyenCV.Dtos.FollowStories;

public class FollowStoryCreateDTO
{
    [BindingBehavior(BindingBehavior.Required)]
    public int StoryId { get; set; }
}
