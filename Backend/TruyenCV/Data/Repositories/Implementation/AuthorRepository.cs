using Microsoft.EntityFrameworkCore;
using TruyenCV.Data;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Implementation;

public class AuthorRepository : IAuthorRepository
{
    private readonly TruyenCVDbContext _db;
    public AuthorRepository(TruyenCVDbContext db) => _db = db;

    public Task<List<Author>> GetAllAsync()
        => _db.Authors.AsNoTracking().OrderByDescending(a => a.CreatedAt).ToListAsync();

    public Task<Author?> GetByIdAsync(int id)
        => _db.Authors.AsNoTracking().FirstOrDefaultAsync(a => a.AuthorId == id);

    public Task<bool> ExistsAsync(int id)
        => _db.Authors.AnyAsync(a => a.AuthorId == id);

    public async Task<int> CreateAsync(Author author)
    {
        _db.Authors.Add(author);
        await _db.SaveChangesAsync();
        return author.AuthorId;
    }

    public async Task<bool> UpdateAsync(Author author)
    {
        var exists = await _db.Authors.AnyAsync(a => a.AuthorId == author.AuthorId);
        if (!exists) return false;

        _db.Authors.Update(author);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var author = await _db.Authors.FirstOrDefaultAsync(a => a.AuthorId == id);
        if (author is null) return false;

        _db.Authors.Remove(author);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<List<(int StoryId, string Title, string Status, DateTime UpdatedAt)>> GetStoriesByAuthorAsync(int authorId)
    {
        return await _db.Stories.AsNoTracking()
            .Where(s => s.AuthorId == authorId)
            .OrderByDescending(s => s.UpdatedAt)
            .Select(s => new ValueTuple<int, string, string, DateTime>(s.StoryId, s.Title, s.Status, s.UpdatedAt))
            .ToListAsync();
    }
}
