using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Interface;

public interface IRatingRepository
{
    Task<List<Rating>> GetAllAsync();
    Task<Rating?> GetByIdAsync(int id);
    Task<List<Rating>> GetByStoryAsync(int storyId);
    Task<List<Rating>> GetByUserAsync(string userId);
    Task<Rating?> GetByUserAndStoryAsync(string userId, int storyId);
    Task<bool> ExistsAsync(int id);
    Task<bool> StoryExistsAsync(int storyId);
    Task<bool> UserExistsAsync(string userId);
    Task<int> CreateAsync(Rating rating);
    Task<bool> UpdateAsync(Rating rating);
    Task<bool> DeleteAsync(int id);
    Task<double> GetAverageScoreAsync(int storyId);
    Task<int> GetTotalRatingsAsync(int storyId);
}
