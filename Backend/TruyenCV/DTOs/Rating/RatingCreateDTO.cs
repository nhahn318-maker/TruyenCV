using System.ComponentModel.DataAnnotations;

namespace TruyenCV.Dtos.Ratings;

public class RatingCreateDTO
{
    [Required]
    public int StoryId { get; set; }

    [Required]
    [Range(1, 5, ErrorMessage = "Điểm Đánh giá phải từ 1-5.")]
    public byte Score { get; set; }
}
