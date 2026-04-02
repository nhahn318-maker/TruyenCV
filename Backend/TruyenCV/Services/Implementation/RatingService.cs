using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Dtos.Ratings;
using TruyenCV.Models;
using TruyenCV.Services.IService;

namespace TruyenCV.Services.Implementation;

public class RatingService : IRatingService
{
    private readonly IRatingRepository _repo;
    public RatingService(IRatingRepository repo) => _repo = repo;

    public async Task<List<RatingListItemDTO>> GetAllAsync()
    {
        var list = await _repo.GetAllAsync();
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<RatingDTO?> GetByIdAsync(int id)
    {
        var r = await _repo.GetByIdAsync(id);
        return r is null ? null : MapToDTO(r);
    }

    public async Task<List<RatingListItemDTO>> GetByStoryAsync(int storyId)
    {
        var exists = await _repo.StoryExistsAsync(storyId);
        if (!exists)
            throw new KeyNotFoundException("Không tìm th?y truy?n.");

        var list = await _repo.GetByStoryAsync(storyId);
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<List<RatingListItemDTO>> GetByUserAsync(string userId)
    {
        var exists = await _repo.UserExistsAsync(userId);
        if (!exists)
            throw new KeyNotFoundException("Không tìm th?y ng??i dùng.");

        var list = await _repo.GetByUserAsync(userId);
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<RatingDTO?> GetByUserAndStoryAsync(string userId, int storyId)
    {
        var r = await _repo.GetByUserAndStoryAsync(userId, storyId);
        return r is null ? null : MapToDTO(r);
    }

    public async Task<int> CreateAsync(string userId, RatingCreateDTO dto)
    {
        if (!await _repo.UserExistsAsync(userId))
            throw new ArgumentException("Ng??i dùng không t?n t?i.");

        if (!await _repo.StoryExistsAsync(dto.StoryId))
            throw new ArgumentException("Truy?n không t?n t?i.");

        if (dto.Score < 1 || dto.Score > 5)
            throw new ArgumentException("?i?m ?ánh giá ph?i t? 1 ??n 5.");

        // Check if user already rated this story
        var existing = await _repo.GetByUserAndStoryAsync(userId, dto.StoryId);
        if (existing is not null)
            throw new ArgumentException("B?n ?ã ?ánh giá truy?n này r?i. Hãy c?p nh?t ?ánh giá c?a b?n.");

        var entity = new Rating
        {
            ApplicationUserId = userId,
            StoryId = dto.StoryId,
            Score = dto.Score,
            CreatedAt = DateTime.UtcNow
        };

        return await _repo.CreateAsync(entity);
    }

    public async Task UpdateAsync(int id, string userId, RatingUpdateDTO dto)
    {
        var existing = await _repo.GetByIdAsync(id);
        if (existing is null)
            throw new KeyNotFoundException("Không tìm th?y ?ánh giá ?? c?p nh?t.");

        if (existing.ApplicationUserId != userId)
            throw new UnauthorizedAccessException("B?n không có quy?n c?p nh?t ?ánh giá c?a ng??i khác.");

        if (dto.Score < 1 || dto.Score > 5)
            throw new ArgumentException("?i?m ?ánh giá ph?i t? 1 ??n 5.");

        var entity = new Rating
        {
            RatingId = id,
            ApplicationUserId = existing.ApplicationUserId,
            StoryId = existing.StoryId,
            Score = dto.Score,
            CreatedAt = existing.CreatedAt
        };

        var ok = await _repo.UpdateAsync(entity);
        if (!ok) throw new KeyNotFoundException("Không tìm th?y ?ánh giá ?? c?p nh?t.");
    }

    public async Task DeleteAsync(int id, string userId)
    {
        var existing = await _repo.GetByIdAsync(id);
        if (existing is null)
            throw new KeyNotFoundException("Không tìm th?y ?ánh giá ?? xóa.");

        if (existing.ApplicationUserId != userId)
            throw new UnauthorizedAccessException("B?n không có quy?n xóa ?ánh giá c?a ng??i khác.");

        var ok = await _repo.DeleteAsync(id);
        if (!ok) throw new KeyNotFoundException("Không tìm th?y ?ánh giá ?? xóa.");
    }

    public async Task<RatingSummaryDTO> GetSummaryAsync(int storyId)
    {
        var exists = await _repo.StoryExistsAsync(storyId);
        if (!exists)
            throw new KeyNotFoundException("Không tìm th?y truy?n.");

        var averageScore = await _repo.GetAverageScoreAsync(storyId);
        var totalRatings = await _repo.GetTotalRatingsAsync(storyId);

        return new RatingSummaryDTO
        {
            AverageScore = averageScore,
            TotalRatings = totalRatings
        };
    }

    private static RatingListItemDTO MapToListItemDTO(Rating r) => new()
    {
        RatingId = r.RatingId,
        StoryId = r.StoryId,
        ApplicationUserId = r.ApplicationUserId,
        Score = r.Score,
        CreatedAt = r.CreatedAt
    };

    private static RatingDTO MapToDTO(Rating r) => new()
    {
        RatingId = r.RatingId,
        StoryId = r.StoryId,
        ApplicationUserId = r.ApplicationUserId,
        Score = r.Score,
        CreatedAt = r.CreatedAt
    };
}
