using TruyenCV.Dtos.FollowStories;

namespace TruyenCV.Services.IService;

public interface IFollowStoryService
{
    // Get user's followed stories (with pagination)
    Task<List<FollowStoryListItemDTO>> GetUserFollowedStoriesAsync(string userId, int page = 1, int pageSize = 10);
    Task<int> GetUserFollowedStoriesCountAsync(string userId);

    // Get specific follow
    Task<FollowStoryDTO?> GetByUserAndStoryAsync(string userId, int storyId);

    // Check if following
    Task<bool> IsFollowingAsync(string userId, int storyId);

    // CRUD
    Task<FollowStoryDTO> CreateAsync(string userId, FollowStoryCreateDTO dto);
    Task<bool> DeleteAsync(string userId, int storyId);
}
