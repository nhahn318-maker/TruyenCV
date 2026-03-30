using Microsoft.EntityFrameworkCore;
using TruyenCV.Data;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Implementation;

public class StoryRepository : IStoryRepository
{
    private readonly TruyenCVDbContext _db;
    public StoryRepository(TruyenCVDbContext db) => _db = db;

    public async Task<List<Story>> GetAllAsync(int? authorId = null, int? genreId = null, string? q = null)
    {
        IQueryable<Story> query = _db.Stories.AsNoTracking();

        if (authorId is not null)
            query = query.Where(s => s.AuthorId == authorId.Value);

        // ✅ filter theo thể loại: primary OR storygenres
        if (genreId is not null)
            query = query.Where(s => s.PrimaryGenreId == genreId.Value
                                  || s.StoryGenres.Any(sg => sg.GenreId == genreId.Value));

        if (!string.IsNullOrWhiteSpace(q))
        {
            q = q.Trim();
            query = query.Where(s => s.Title.Contains(q));
        }

        return await query
            .OrderByDescending(s => s.UpdatedAt)
            .ToListAsync();
    }

    public async Task<List<Story>> GetByGenresAsync(IReadOnlyCollection<int> genreIds)
    {
        if (genreIds.Count == 0)
            return new List<Story>();

        var distinctIds = genreIds.Distinct().ToList();

        return await _db.Stories.AsNoTracking()
            .Where(s => s.PrimaryGenreId != null && distinctIds.Contains(s.PrimaryGenreId.Value)
                     || s.StoryGenres.Any(sg => distinctIds.Contains(sg.GenreId)))
            .OrderByDescending(s => s.UpdatedAt)
            .ToListAsync();
    }

    public Task<Story?> GetByIdAsync(int id)
        => _db.Stories.AsNoTracking()
            .Include(s => s.StoryGenres)
            .Include(s => s.Chapters)
            .FirstOrDefaultAsync(s => s.StoryId == id);

    // ✅ Lazy loading methods - chỉ lấy dữ liệu cần thiết từ database
    public async Task<List<Story>> GetLatestAsync(int page = 1, int pageSize = 10)
    {
        var skip = (page - 1) * pageSize;
        return await _db.Stories.AsNoTracking()
            .OrderByDescending(s => s.UpdatedAt)
            .Skip(skip)
            .Take(pageSize)
            .Include(s => s.StoryGenres)
            .Include(s => s.Chapters)
            .ToListAsync();
    }

    public async Task<List<Story>> GetCompletedAsync(int page = 1, int pageSize = 10)
    {
        var skip = (page - 1) * pageSize;
        return await _db.Stories.AsNoTracking()
            .Where(s => s.Status == "Đã hoàn thành")
            .OrderByDescending(s => s.UpdatedAt)
            .Skip(skip)
            .Take(pageSize)
            .Include(s => s.StoryGenres)
            .Include(s => s.Chapters)
            .ToListAsync();
    }

    public async Task<List<Story>> GetOngoingAsync(int page = 1, int pageSize = 10)
    {
        var skip = (page - 1) * pageSize;
        return await _db.Stories.AsNoTracking()
            .Where(s => s.Status == "Đang tiến hành")
            .OrderByDescending(s => s.UpdatedAt)
            .Skip(skip)
            .Take(pageSize)
            .Include(s => s.StoryGenres)
            .Include(s => s.Chapters)
            .ToListAsync();
    }

    public Task<bool> AuthorExistsAsync(int authorId)
        => _db.Authors.AnyAsync(a => a.AuthorId == authorId);

    public Task<bool> GenreExistsAsync(int genreId)
        => _db.Genres.AnyAsync(g => g.GenreId == genreId);

    public async Task<bool> GenresExistAsync(IReadOnlyCollection<int> genreIds)
    {
        if (genreIds.Count == 0) return true;
        var distinct = genreIds.Distinct().ToList();
        var count = await _db.Genres.CountAsync(g => distinct.Contains(g.GenreId));
        return count == distinct.Count;
    }

    public async Task<int> CreateAsync(Story story, IReadOnlyCollection<int> genreIds)
    {
        await using var tx = await _db.Database.BeginTransactionAsync();

        _db.Stories.Add(story);
        await _db.SaveChangesAsync();

        await ReplaceStoryGenresAsync(story.StoryId, genreIds);

        await tx.CommitAsync();
        return story.StoryId;
    }

    public async Task<bool> UpdateAsync(Story story, IReadOnlyCollection<int> genreIds)
    {
        var exists = await _db.Stories.AnyAsync(s => s.StoryId == story.StoryId);
        if (!exists) return false;

        await using var tx = await _db.Database.BeginTransactionAsync();

        _db.Stories.Update(story);
        await _db.SaveChangesAsync();

        await ReplaceStoryGenresAsync(story.StoryId, genreIds);

        await tx.CommitAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Stories.FirstOrDefaultAsync(s => s.StoryId == id);
        if (entity is null) return false;

        _db.Stories.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    private async Task ReplaceStoryGenresAsync(int storyId, IReadOnlyCollection<int> genreIds)
    {
        var old = _db.StoryGenres.Where(x => x.StoryId == storyId);
        _db.StoryGenres.RemoveRange(old);

        var now = DateTime.UtcNow;
        var rows = genreIds
            .Where(x => x > 0)
            .Distinct()
            .Select(gid => new StoryGenre
            {
                StoryId = storyId,
                GenreId = gid,
                CreatedAt = now
            });

        await _db.StoryGenres.AddRangeAsync(rows);
        await _db.SaveChangesAsync();
    }
}
