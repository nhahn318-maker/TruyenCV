using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Interface;

public interface IFollowStoryRepository
{
    // Get user's followed stories with pagination
    Task<List<FollowStory>> GetUserFollowedStoriesAsync(string userId, int page = 1, int pageSize = 10);
    Task<int> GetUserFollowedStoriesCountAsync(string userId);

    // Get specific follow
    Task<FollowStory?> GetByUserAndStoryAsync(string userId, int storyId);

    // Existence checks
    Task<bool> UserExistsAsync(string userId);
    Task<bool> StoryExistsAsync(int storyId);
    Task<bool> FollowExistsAsync(string userId, int storyId);

    // CRUD
    Task<bool> CreateAsync(FollowStory followStory);
    Task<bool> DeleteAsync(string userId, int storyId);
    Task<bool> DeleteAllByUserAsync(string userId);
}
