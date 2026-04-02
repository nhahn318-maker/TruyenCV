using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Dtos.Bookmarks;
using TruyenCV.Models;
using TruyenCV.Services.IService;

namespace TruyenCV.Services.Implementation;

public class BookmarkService : IBookmarkService
{
    private readonly IBookmarkRepository _repo;

    public BookmarkService(IBookmarkRepository repo) => _repo = repo;

    public async Task<List<BookmarkListItemDTO>> GetUserBookmarksAsync(string userId, int page = 1, int pageSize = 10)
    {
        if (!await _repo.UserExistsAsync(userId))
            throw new KeyNotFoundException("Không tìm th?y ng??i dùng.");

        var bookmarks = await _repo.GetUserBookmarksAsync(userId, page, pageSize);
        return bookmarks.Select(MapToListItemDTO).ToList();
    }

    public async Task<int> GetUserBookmarksCountAsync(string userId)
    {
        if (!await _repo.UserExistsAsync(userId))
            throw new KeyNotFoundException("Không tìm th?y ng??i dùng.");

        return await _repo.GetUserBookmarksCountAsync(userId);
    }

    public async Task<BookmarkDTO?> GetByUserAndStoryAsync(string userId, int storyId)
    {
        var bookmark = await _repo.GetByUserAndStoryAsync(userId, storyId);
        return bookmark is null ? null : MapToDTO(bookmark);
    }

    public async Task<bool> IsBookmarkedAsync(string userId, int storyId)
    {
        return await _repo.BookmarkExistsAsync(userId, storyId);
    }

    public async Task<BookmarkDTO> CreateAsync(string userId, BookmarkCreateDTO dto)
    {
        // Validate user exists
        if (!await _repo.UserExistsAsync(userId))
            throw new KeyNotFoundException("Không tìm th?y ng??i dùng.");

        // Validate story exists
        if (!await _repo.StoryExistsAsync(dto.StoryId))
            throw new KeyNotFoundException("Không tìm th?y truy?n.");

        // Check if already bookmarked
        if (await _repo.BookmarkExistsAsync(userId, dto.StoryId))
            throw new InvalidOperationException("B?n ?ã l?u truy?n này r?i.");

        var bookmark = new Bookmark
        {
            ApplicationUserId = userId,
            StoryId = dto.StoryId,
            CreatedAt = DateTime.UtcNow
        };

        var ok = await _repo.CreateAsync(bookmark);
        if (!ok)
            throw new InvalidOperationException("L?u truy?n th?t b?i.");

        var created = await _repo.GetByUserAndStoryAsync(userId, dto.StoryId);
        if (created is null)
            throw new InvalidOperationException("L?u truy?n th?t b?i.");

        return MapToDTO(created);
    }

    public async Task<bool> DeleteAsync(string userId, int storyId)
    {
        // Verify user exists
        if (!await _repo.UserExistsAsync(userId))
            throw new KeyNotFoundException("Không tìm th?y ng??i dùng.");

        // Check if bookmark exists
        if (!await _repo.BookmarkExistsAsync(userId, storyId))
            throw new KeyNotFoundException("Không tìm th?y bookmark này.");

        return await _repo.DeleteAsync(userId, storyId);
    }

    // Helpers
    private static BookmarkDTO MapToDTO(Bookmark b) => new()
    {
        ApplicationUserId = b.ApplicationUserId,
        StoryId = b.StoryId,
        StoryTitle = b.Story?.Title ?? "",
        StoryCoverImage = b.Story?.CoverImage,
        StoryDescription = b.Story?.Description,
        AuthorId = b.Story?.AuthorId ?? 0,
        AuthorDisplayName = b.Story?.Author?.DisplayName,
        CreatedAt = b.CreatedAt
    };

    private static BookmarkListItemDTO MapToListItemDTO(Bookmark b) => new()
    {
        StoryId = b.StoryId,
        StoryTitle = b.Story?.Title ?? "",
        StoryCoverImage = b.Story?.CoverImage,
        StoryDescription = b.Story?.Description,
        AuthorId = b.Story?.AuthorId ?? 0,
        AuthorDisplayName = b.Story?.Author?.DisplayName,
        Status = b.Story?.Status ?? "",
        CreatedAt = b.CreatedAt
    };
}
