using TruyenCV.Dtos.Bookmarks;

namespace TruyenCV.Services.IService;

public interface IBookmarkService
{
    // Get user's bookmarks (with pagination)
    Task<List<BookmarkListItemDTO>> GetUserBookmarksAsync(string userId, int page = 1, int pageSize = 10);
    Task<int> GetUserBookmarksCountAsync(string userId);

    // Get specific bookmark
    Task<BookmarkDTO?> GetByUserAndStoryAsync(string userId, int storyId);

    // Check if bookmarked
    Task<bool> IsBookmarkedAsync(string userId, int storyId);

    // CRUD
    Task<BookmarkDTO> CreateAsync(string userId, BookmarkCreateDTO dto);
    Task<bool> DeleteAsync(string userId, int storyId);
}
