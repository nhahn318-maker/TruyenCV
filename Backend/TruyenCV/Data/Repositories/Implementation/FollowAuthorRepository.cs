using Microsoft.EntityFrameworkCore;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Implementation;

public class FollowAuthorRepository : IFollowAuthorRepository
{
    private readonly TruyenCVDbContext _db;

    public FollowAuthorRepository(TruyenCVDbContext db) => _db = db;

    public async Task<List<FollowAuthor>> GetUserFollowedAuthorsAsync(string userId, int page = 1, int pageSize = 10)
    {
        var skip = (page - 1) * pageSize;
        return await _db.FollowAuthors.AsNoTracking()
            .Where(f => f.ApplicationUserId == userId)
            .OrderByDescending(f => f.CreatedAt)
            .Skip(skip)
            .Take(pageSize)
            .Include(f => f.Author)
            .ToListAsync();
    }

    public async Task<int> GetUserFollowedAuthorsCountAsync(string userId)
    {
        return await _db.FollowAuthors
            .Where(f => f.ApplicationUserId == userId)
            .CountAsync();
    }

    public Task<FollowAuthor?> GetByUserAndAuthorAsync(string userId, int authorId)
    {
        return _db.FollowAuthors.AsNoTracking()
            .Include(f => f.Author)
            .FirstOrDefaultAsync(f => f.ApplicationUserId == userId && f.AuthorId == authorId);
    }

    public Task<bool> UserExistsAsync(string userId)
    {
        return _db.Users.AnyAsync(u => u.Id == userId);
    }

    public Task<bool> AuthorExistsAsync(int authorId)
    {
        return _db.Authors.AnyAsync(a => a.AuthorId == authorId);
    }

    public Task<bool> FollowExistsAsync(string userId, int authorId)
    {
        return _db.FollowAuthors.AnyAsync(f => f.ApplicationUserId == userId && f.AuthorId == authorId);
    }

    public async Task<bool> CreateAsync(FollowAuthor followAuthor)
    {
        // Check if follow already exists
        if (await FollowExistsAsync(followAuthor.ApplicationUserId, followAuthor.AuthorId))
            return false;

        _db.FollowAuthors.Add(followAuthor);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(string userId, int authorId)
    {
        var followAuthor = await _db.FollowAuthors
            .FirstOrDefaultAsync(f => f.ApplicationUserId == userId && f.AuthorId == authorId);
        if (followAuthor is null) return false;

        _db.FollowAuthors.Remove(followAuthor);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAllByUserAsync(string userId)
    {
        var followAuthors = await _db.FollowAuthors
            .Where(f => f.ApplicationUserId == userId)
            .ToListAsync();

        if (followAuthors.Count == 0) return false;

        _db.FollowAuthors.RemoveRange(followAuthors);
        await _db.SaveChangesAsync();
        return true;
    }
}
