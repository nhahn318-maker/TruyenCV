using Microsoft.EntityFrameworkCore;
using TruyenCV.Data;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Implementation;

public class BookmarkRepository : IBookmarkRepository
{
    private readonly TruyenCVDbContext _db;

    public BookmarkRepository(TruyenCVDbContext db) => _db = db;

    public async Task<List<Bookmark>> GetUserBookmarksAsync(string userId, int page = 1, int pageSize = 10)
    {
        var skip = (page - 1) * pageSize;
        return await _db.Bookmarks.AsNoTracking()
            .Where(b => b.ApplicationUserId == userId)
            .OrderByDescending(b => b.CreatedAt)
            .Skip(skip)
            .Take(pageSize)
            .Include(b => b.Story)
            .ThenInclude(s => s.Author)
            .ToListAsync();
    }

    public async Task<int> GetUserBookmarksCountAsync(string userId)
    {
        return await _db.Bookmarks
            .Where(b => b.ApplicationUserId == userId)
            .CountAsync();
    }

    public Task<Bookmark?> GetByUserAndStoryAsync(string userId, int storyId)
    {
        return _db.Bookmarks.AsNoTracking()
            .Include(b => b.Story)
            .ThenInclude(s => s.Author)
            .FirstOrDefaultAsync(b => b.ApplicationUserId == userId && b.StoryId == storyId);
    }

    public Task<bool> UserExistsAsync(string userId)
    {
        return _db.Users.AnyAsync(u => u.Id == userId);
    }

    public Task<bool> StoryExistsAsync(int storyId)
    {
        return _db.Stories.AnyAsync(s => s.StoryId == storyId);
    }

    public Task<bool> BookmarkExistsAsync(string userId, int storyId)
    {
        return _db.Bookmarks.AnyAsync(b => b.ApplicationUserId == userId && b.StoryId == storyId);
    }

    public async Task<bool> CreateAsync(Bookmark bookmark)
    {
        // Check if bookmark already exists
        if (await BookmarkExistsAsync(bookmark.ApplicationUserId, bookmark.StoryId))
            return false;

        _db.Bookmarks.Add(bookmark);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(string userId, int storyId)
    {
        var bookmark = await _db.Bookmarks
            .FirstOrDefaultAsync(b => b.ApplicationUserId == userId && b.StoryId == storyId);
        if (bookmark is null) return false;

        _db.Bookmarks.Remove(bookmark);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAllByUserAsync(string userId)
    {
        var bookmarks = await _db.Bookmarks
            .Where(b => b.ApplicationUserId == userId)
            .ToListAsync();

        if (bookmarks.Count == 0) return false;

        _db.Bookmarks.RemoveRange(bookmarks);
        await _db.SaveChangesAsync();
        return true;
    }
}
