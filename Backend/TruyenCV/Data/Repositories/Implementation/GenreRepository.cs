using Microsoft.EntityFrameworkCore;
using TruyenCV.Data;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Implementation;

public class GenreRepository : IGenreRepository
{
    private readonly TruyenCVDbContext _db;
    public GenreRepository(TruyenCVDbContext db) => _db = db;

    public Task<List<Genre>> GetAllAsync()
        => _db.Genres.AsNoTracking()
            .OrderBy(g => g.Name)
            .ToListAsync();

    public Task<Genre?> GetByIdAsync(int id)
        => _db.Genres.AsNoTracking()
            .FirstOrDefaultAsync(g => g.GenreId == id);

    public Task<bool> ExistsAsync(int id)
        => _db.Genres.AnyAsync(g => g.GenreId == id);

    public Task<bool> ExistsByNameAsync(string name, int? excludeId = null)
    {
        var q = _db.Genres.AsQueryable();
        if (excludeId is not null)
            q = q.Where(g => g.GenreId != excludeId.Value);

        // so sánh case-insensitive đơn giản
        return q.AnyAsync(g => g.Name.ToLower() == name.ToLower());
    }

    public async Task<int> CreateAsync(Genre genre)
    {
        _db.Genres.Add(genre);
        await _db.SaveChangesAsync();
        return genre.GenreId;
    }

    public async Task<bool> UpdateAsync(Genre genre)
    {
        var exists = await _db.Genres.AnyAsync(g => g.GenreId == genre.GenreId);
        if (!exists) return false;

        _db.Genres.Update(genre);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> IsInUseAsync(int genreId)
    {
        var usedAsPrimary = await _db.Stories.AnyAsync(s => s.PrimaryGenreId == genreId);
        if (usedAsPrimary) return true;

        var usedInLink = await _db.StoryGenres.AnyAsync(sg => sg.GenreId == genreId);
        return usedInLink;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _db.Genres.FirstOrDefaultAsync(g => g.GenreId == id);
        if (entity is null) return false;

        _db.Genres.Remove(entity);
        await _db.SaveChangesAsync();
        return true;
    }

    public Task<List<Story>> GetStoriesByGenreAsync(int genreId)
        => _db.Stories.AsNoTracking()
            .Where(s => s.PrimaryGenreId == genreId || s.StoryGenres.Any(sg => sg.GenreId == genreId))
            .OrderByDescending(s => s.UpdatedAt)
            .ToListAsync();
}
