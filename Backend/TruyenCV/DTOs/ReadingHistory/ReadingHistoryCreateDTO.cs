using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace TruyenCV.Dtos.ReadingHistory;

public class ReadingHistoryCreateDTO
{
    [BindingBehavior(BindingBehavior.Required)]
    public int StoryId { get; set; }

    [BindingBehavior(BindingBehavior.Optional)]
    public int? LastReadChapterId { get; set; }
}
