using TruyenCV.Dtos.Ratings;

namespace TruyenCV.Services.IService;

public interface IRatingService
{
    Task<List<RatingListItemDTO>> GetAllAsync();
    Task<RatingDTO?> GetByIdAsync(int id);
    Task<List<RatingListItemDTO>> GetByStoryAsync(int storyId);
    Task<List<RatingListItemDTO>> GetByUserAsync(string userId);
    Task<RatingDTO?> GetByUserAndStoryAsync(string userId, int storyId);
    Task<int> CreateAsync(string userId, RatingCreateDTO dto);
    Task UpdateAsync(int id, string userId, RatingUpdateDTO dto);
    Task DeleteAsync(int id, string userId);
    Task<RatingSummaryDTO> GetSummaryAsync(int storyId);
}

public class RatingSummaryDTO
{
    public double AverageScore { get; set; }
    public int TotalRatings { get; set; }
}
