using Microsoft.EntityFrameworkCore;
using TruyenCV.Data;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Implementation;

public class RatingRepository : IRatingRepository
{
    private readonly TruyenCVDbContext _db;
    public RatingRepository(TruyenCVDbContext db) => _db = db;

    public Task<List<Rating>> GetAllAsync()
        => _db.Ratings.AsNoTracking()
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

    public Task<Rating?> GetByIdAsync(int id)
        => _db.Ratings.AsNoTracking()
            .FirstOrDefaultAsync(r => r.RatingId == id);

    public Task<List<Rating>> GetByStoryAsync(int storyId)
        => _db.Ratings.AsNoTracking()
            .Where(r => r.StoryId == storyId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

    public Task<List<Rating>> GetByUserAsync(string userId)
        => _db.Ratings.AsNoTracking()
            .Where(r => r.ApplicationUserId == userId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

    public Task<Rating?> GetByUserAndStoryAsync(string userId, int storyId)
        => _db.Ratings.AsNoTracking()
            .FirstOrDefaultAsync(r => r.ApplicationUserId == userId && r.StoryId == storyId);

    public Task<bool> ExistsAsync(int id)
        => _db.Ratings.AnyAsync(r => r.RatingId == id);

    public Task<bool> StoryExistsAsync(int storyId)
        => _db.Stories.AnyAsync(s => s.StoryId == storyId);

    public Task<bool> UserExistsAsync(string userId)
        => _db.Users.AnyAsync(u => u.Id == userId);

    public async Task<int> CreateAsync(Rating rating)
    {
        _db.Ratings.Add(rating);
        await _db.SaveChangesAsync();
        return rating.RatingId;
    }

    public async Task<bool> UpdateAsync(Rating rating)
    {
        var exists = await _db.Ratings.AnyAsync(r => r.RatingId == rating.RatingId);
        if (!exists) return false;

        _db.Ratings.Update(rating);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var rating = await _db.Ratings.FirstOrDefaultAsync(r => r.RatingId == id);
        if (rating is null) return false;

        _db.Ratings.Remove(rating);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<double> GetAverageScoreAsync(int storyId)
    {
        var ratings = await _db.Ratings.AsNoTracking()
            .Where(r => r.StoryId == storyId)
            .ToListAsync();

        if (ratings.Count == 0) return 0;
        return Math.Round(ratings.Average(r => r.Score), 2);
    }

    public Task<int> GetTotalRatingsAsync(int storyId)
        => _db.Ratings.CountAsync(r => r.StoryId == storyId);
}
