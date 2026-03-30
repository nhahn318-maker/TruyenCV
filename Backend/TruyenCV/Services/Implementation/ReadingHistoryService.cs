using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Dtos.ReadingHistory;
using TruyenCV.Models;
using TruyenCV.Services.IService;

namespace TruyenCV.Services.Implementation;

public class ReadingHistoryService : IReadingHistoryService
{
    private readonly IReadingHistoryRepository _repo;

    public ReadingHistoryService(IReadingHistoryRepository repo) => _repo = repo;

    public async Task<List<ReadingHistoryListItemDTO>> GetUserReadingHistoryAsync(string userId, int page = 1, int pageSize = 10)
    {
        if (!await _repo.UserExistsAsync(userId))
            throw new KeyNotFoundException("Không tìm th?y ng??i dùng.");

        var histories = await _repo.GetUserReadingHistoryAsync(userId, page, pageSize);
        return histories.Select(MapToListItemDTO).ToList();
    }

    public async Task<int> GetUserReadingHistoryCountAsync(string userId)
    {
        if (!await _repo.UserExistsAsync(userId))
            throw new KeyNotFoundException("Không tìm th?y ng??i dùng.");

        return await _repo.GetUserReadingHistoryCountAsync(userId);
    }

    public async Task<ReadingHistoryDTO?> GetByIdAsync(int historyId)
    {
        var history = await _repo.GetByIdAsync(historyId);
        return history is null ? null : MapToDTO(history);
    }

    public async Task<ReadingHistoryDTO> CreateAsync(string userId, ReadingHistoryCreateDTO dto)
    {
        // Validate user exists
        if (!await _repo.UserExistsAsync(userId))
            throw new KeyNotFoundException("Không tìm th?y ng??i dùng.");

        // Validate story exists
        if (!await _repo.StoryExistsAsync(dto.StoryId))
            throw new KeyNotFoundException("Không tìm th?y truy?n.");

        // Validate chapter exists if provided
        if (dto.LastReadChapterId.HasValue && !await _repo.ChapterExistsAsync(dto.LastReadChapterId.Value))
            throw new KeyNotFoundException("Không tìm th?y ch??ng.");

        // Check if history already exists for this user and story
        var existing = await _repo.GetByUserAndStoryAsync(userId, dto.StoryId);
        if (existing is not null)
        {
            // Update existing history
            existing.LastReadChapterId = dto.LastReadChapterId;
            existing.UpdatedAt = DateTime.UtcNow;
            await _repo.UpdateAsync(existing);

            var updated = await _repo.GetByIdAsync(existing.HistoryId);
            if (updated is null)
                throw new InvalidOperationException("C?p nh?t l?ch s? ??c th?t b?i.");
            return MapToDTO(updated);
        }

        // Create new history
        var history = new ReadingHistory
        {
            ApplicationUserId = userId,
            StoryId = dto.StoryId,
            LastReadChapterId = dto.LastReadChapterId,
            UpdatedAt = DateTime.UtcNow
        };

        var id = await _repo.CreateAsync(history);

        var created = await _repo.GetByIdAsync(id);
        if (created is null)
            throw new InvalidOperationException("T?o l?ch s? ??c th?t b?i.");

        return MapToDTO(created);
    }

    public async Task<ReadingHistoryDTO> UpdateAsync(int historyId, string userId, ReadingHistoryUpdateDTO dto)
    {
        var existing = await _repo.GetByIdAsync(historyId);
        if (existing is null)
            throw new KeyNotFoundException("Không tìm th?y l?ch s? ??c.");

        // Only the owner can update
        if (existing.ApplicationUserId != userId)
            throw new UnauthorizedAccessException("B?n ch? có th? c?p nh?t l?ch s? ??c c?a mình.");

        // Validate chapter exists if provided
        if (dto.LastReadChapterId.HasValue && !await _repo.ChapterExistsAsync(dto.LastReadChapterId.Value))
            throw new KeyNotFoundException("Không tìm th?y ch??ng.");

        existing.LastReadChapterId = dto.LastReadChapterId;
        existing.UpdatedAt = DateTime.UtcNow;

        var ok = await _repo.UpdateAsync(existing);
        if (!ok)
            throw new InvalidOperationException("C?p nh?t l?ch s? ??c th?t b?i.");

        var updated = await _repo.GetByIdAsync(historyId);
        if (updated is null)
            throw new InvalidOperationException("C?p nh?t l?ch s? ??c th?t b?i.");

        return MapToDTO(updated);
    }

    public async Task<bool> DeleteAsync(int historyId, string userId)
    {
        var history = await _repo.GetByIdAsync(historyId);
        if (history is null)
            throw new KeyNotFoundException("Không tìm th?y l?ch s? ??c.");

        // Only the owner can delete
        if (history.ApplicationUserId != userId)
            throw new UnauthorizedAccessException("B?n ch? có th? xóa l?ch s? ??c c?a mình.");

        return await _repo.DeleteAsync(historyId);
    }

    // Helpers
    private static ReadingHistoryDTO MapToDTO(ReadingHistory rh) => new()
    {
        HistoryId = rh.HistoryId,
        ApplicationUserId = rh.ApplicationUserId,
        StoryId = rh.StoryId,
        StoryTitle = rh.Story?.Title ?? "",
        LastReadChapterId = rh.LastReadChapterId,
        LastReadChapterTitle = rh.LastReadChapter?.Title,
        LastReadChapterNumber = rh.LastReadChapter?.ChapterNumber,
        StorycoverImage = rh.Story?.CoverImage,
        UpdatedAt = rh.UpdatedAt
    };

    private static ReadingHistoryListItemDTO MapToListItemDTO(ReadingHistory rh) => new()
    {
        HistoryId = rh.HistoryId,
        StoryId = rh.StoryId,
        StoryTitle = rh.Story?.Title ?? "",
        LastReadChapterId = rh.LastReadChapterId,
        LastReadChapterNumber = rh.LastReadChapter?.ChapterNumber,
        LastReadChapterTitle = rh.LastReadChapter?.Title,
        StoryCoverImage = rh.Story?.CoverImage,
        UpdatedAt = rh.UpdatedAt
    };
}
