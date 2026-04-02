using Microsoft.EntityFrameworkCore;
using TruyenCV.Data;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Implementation;

public class ChapterRepository : IChapterRepository
{
    private readonly TruyenCVDbContext _db;
    public ChapterRepository(TruyenCVDbContext db) => _db = db;

    public Task<List<Chapter>> GetAllAsync()
        => _db.Chapters.AsNoTracking()
            .OrderByDescending(c => c.UpdatedAt)
            .ToListAsync();

    public Task<Chapter?> GetByIdAsync(int id)
        => _db.Chapters.AsNoTracking()
            .FirstOrDefaultAsync(c => c.ChapterId == id);

    public Task<List<Chapter>> GetChaptersByStoryAsync(int storyId)
        => _db.Chapters.AsNoTracking()
            .Where(c => c.StoryId == storyId)
            .OrderBy(c => c.ChapterNumber)
            .ToListAsync();

    public Task<Chapter?> GetChapterByNumberAsync(int storyId, int chapterNumber)
        => _db.Chapters.AsNoTracking()
            .FirstOrDefaultAsync(c => c.StoryId == storyId && c.ChapterNumber == chapterNumber);

    public Task<bool> ExistsAsync(int id)
        => _db.Chapters.AnyAsync(c => c.ChapterId == id);

    public Task<bool> StoryExistsAsync(int storyId)
        => _db.Stories.AnyAsync(s => s.StoryId == storyId);

    public async Task<int> CreateAsync(Chapter chapter)
    {
        _db.Chapters.Add(chapter);
        await _db.SaveChangesAsync();
        return chapter.ChapterId;
    }

    public async Task<bool> UpdateAsync(Chapter chapter)
    {
        var exists = await _db.Chapters.AnyAsync(c => c.ChapterId == chapter.ChapterId);
        if (!exists) return false;

        _db.Chapters.Update(chapter);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var chapter = await _db.Chapters.FirstOrDefaultAsync(c => c.ChapterId == id);
        if (chapter is null) return false;

        _db.Chapters.Remove(chapter);
        await _db.SaveChangesAsync();
        return true;
    }
}
