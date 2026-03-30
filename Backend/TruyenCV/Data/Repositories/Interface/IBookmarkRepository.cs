using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Interface;

public interface IBookmarkRepository
{
    // Get user's bookmarks with pagination
    Task<List<Bookmark>> GetUserBookmarksAsync(string userId, int page = 1, int pageSize = 10);
    Task<int> GetUserBookmarksCountAsync(string userId);

    // Get specific bookmark
    Task<Bookmark?> GetByUserAndStoryAsync(string userId, int storyId);

    // Existence checks
    Task<bool> UserExistsAsync(string userId);
    Task<bool> StoryExistsAsync(int storyId);
    Task<bool> BookmarkExistsAsync(string userId, int storyId);

    // CRUD
    Task<bool> CreateAsync(Bookmark bookmark);
    Task<bool> DeleteAsync(string userId, int storyId);
    Task<bool> DeleteAllByUserAsync(string userId);
}
