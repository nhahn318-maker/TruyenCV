using Microsoft.EntityFrameworkCore;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Implementation;

public class FollowStoryRepository : IFollowStoryRepository
{
    private readonly TruyenCVDbContext _db;

    public FollowStoryRepository(TruyenCVDbContext db) => _db = db;

    public async Task<List<FollowStory>> GetUserFollowedStoriesAsync(string userId, int page = 1, int pageSize = 10)
    {
        var skip = (page - 1) * pageSize;
        return await _db.FollowStories.AsNoTracking()
            .Where(f => f.ApplicationUserId == userId)
            .OrderByDescending(f => f.CreatedAt)
            .Skip(skip)
            .Take(pageSize)
            .Include(f => f.Story)
            .ThenInclude(s => s.Author)
            .ToListAsync();
    }

    public async Task<int> GetUserFollowedStoriesCountAsync(string userId)
    {
        return await _db.FollowStories
            .Where(f => f.ApplicationUserId == userId)
            .CountAsync();
    }

    public Task<FollowStory?> GetByUserAndStoryAsync(string userId, int storyId)
    {
        return _db.FollowStories.AsNoTracking()
            .Include(f => f.Story)
            .ThenInclude(s => s.Author)
            .FirstOrDefaultAsync(f => f.ApplicationUserId == userId && f.StoryId == storyId);
    }

    public Task<bool> UserExistsAsync(string userId)
    {
        return _db.Users.AnyAsync(u => u.Id == userId);
    }

    public Task<bool> StoryExistsAsync(int storyId)
    {
        return _db.Stories.AnyAsync(s => s.StoryId == storyId);
    }

    public Task<bool> FollowExistsAsync(string userId, int storyId)
    {
        return _db.FollowStories.AnyAsync(f => f.ApplicationUserId == userId && f.StoryId == storyId);
    }

    public async Task<bool> CreateAsync(FollowStory followStory)
    {
        // Check if follow already exists
        if (await FollowExistsAsync(followStory.ApplicationUserId, followStory.StoryId))
            return false;

        _db.FollowStories.Add(followStory);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(string userId, int storyId)
    {
        var followStory = await _db.FollowStories
            .FirstOrDefaultAsync(f => f.ApplicationUserId == userId && f.StoryId == storyId);
        if (followStory is null) return false;

        _db.FollowStories.Remove(followStory);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAllByUserAsync(string userId)
    {
        var followStories = await _db.FollowStories
            .Where(f => f.ApplicationUserId == userId)
            .ToListAsync();

        if (followStories.Count == 0) return false;

        _db.FollowStories.RemoveRange(followStories);
        await _db.SaveChangesAsync();
        return true;
    }
}
