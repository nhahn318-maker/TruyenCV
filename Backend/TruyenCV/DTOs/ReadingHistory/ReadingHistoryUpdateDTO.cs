using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace TruyenCV.Dtos.ReadingHistory;

public class ReadingHistoryUpdateDTO
{
    [BindingBehavior(BindingBehavior.Optional)]
    public int? LastReadChapterId { get; set; }
}
