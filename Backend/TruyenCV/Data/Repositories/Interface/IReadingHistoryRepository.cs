using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Interface;

public interface IReadingHistoryRepository
{
    // Get user's reading history with pagination
    Task<List<ReadingHistory>> GetUserReadingHistoryAsync(string userId, int page = 1, int pageSize = 10);
    Task<int> GetUserReadingHistoryCountAsync(string userId);

    // Get specific reading history
    Task<ReadingHistory?> GetByIdAsync(int historyId);
    Task<ReadingHistory?> GetByUserAndStoryAsync(string userId, int storyId);

    // Existence checks
    Task<bool> UserExistsAsync(string userId);
    Task<bool> StoryExistsAsync(int storyId);
    Task<bool> ChapterExistsAsync(int chapterId);
    Task<bool> HistoryExistsAsync(int historyId);

    // CRUD
    Task<int> CreateAsync(ReadingHistory history);
    Task<bool> UpdateAsync(ReadingHistory history);
    Task<bool> DeleteAsync(int id);
    Task<bool> DeleteByUserAndStoryAsync(string userId, int storyId);
}
