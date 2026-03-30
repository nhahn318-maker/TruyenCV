using Microsoft.EntityFrameworkCore;
using TruyenCV.Data;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Implementation;

public class ReadingHistoryRepository : IReadingHistoryRepository
{
    private readonly TruyenCVDbContext _db;

    public ReadingHistoryRepository(TruyenCVDbContext db) => _db = db;

    public async Task<List<ReadingHistory>> GetUserReadingHistoryAsync(string userId, int page = 1, int pageSize = 10)
    {
        var skip = (page - 1) * pageSize;
        return await _db.ReadingHistories.AsNoTracking()
            .Where(rh => rh.ApplicationUserId == userId)
            .OrderByDescending(rh => rh.UpdatedAt)
            .Skip(skip)
            .Take(pageSize)
            .Include(rh => rh.Story)
            .Include(rh => rh.LastReadChapter)
            .ToListAsync();
    }

    public async Task<int> GetUserReadingHistoryCountAsync(string userId)
    {
        return await _db.ReadingHistories
            .Where(rh => rh.ApplicationUserId == userId)
            .CountAsync();
    }

    public Task<ReadingHistory?> GetByIdAsync(int historyId)
    {
        return _db.ReadingHistories.AsNoTracking()
            .Include(rh => rh.Story)
            .Include(rh => rh.LastReadChapter)
            .FirstOrDefaultAsync(rh => rh.HistoryId == historyId);
    }

    public Task<ReadingHistory?> GetByUserAndStoryAsync(string userId, int storyId)
    {
        return _db.ReadingHistories.AsNoTracking()
            .Include(rh => rh.Story)
            .Include(rh => rh.LastReadChapter)
            .FirstOrDefaultAsync(rh => rh.ApplicationUserId == userId && rh.StoryId == storyId);
    }

    public Task<bool> UserExistsAsync(string userId)
    {
        return _db.Users.AnyAsync(u => u.Id == userId);
    }

    public Task<bool> StoryExistsAsync(int storyId)
    {
        return _db.Stories.AnyAsync(s => s.StoryId == storyId);
    }

    public Task<bool> ChapterExistsAsync(int chapterId)
    {
        return _db.Chapters.AnyAsync(c => c.ChapterId == chapterId);
    }

    public Task<bool> HistoryExistsAsync(int historyId)
    {
        return _db.ReadingHistories.AnyAsync(rh => rh.HistoryId == historyId);
    }

    public async Task<int> CreateAsync(ReadingHistory history)
    {
        _db.ReadingHistories.Add(history);
        await _db.SaveChangesAsync();
        return history.HistoryId;
    }

    public async Task<bool> UpdateAsync(ReadingHistory history)
    {
        var exists = await _db.ReadingHistories.AnyAsync(rh => rh.HistoryId == history.HistoryId);
        if (!exists) return false;

        _db.ReadingHistories.Update(history);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var history = await _db.ReadingHistories.FirstOrDefaultAsync(rh => rh.HistoryId == id);
        if (history is null) return false;

        _db.ReadingHistories.Remove(history);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteByUserAndStoryAsync(string userId, int storyId)
    {
        var history = await _db.ReadingHistories
            .FirstOrDefaultAsync(rh => rh.ApplicationUserId == userId && rh.StoryId == storyId);
        if (history is null) return false;

        _db.ReadingHistories.Remove(history);
        await _db.SaveChangesAsync();
        return true;
    }
}
