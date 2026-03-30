using TruyenCV.Dtos.ReadingHistory;

namespace TruyenCV.Services.IService;

public interface IReadingHistoryService
{
    // Get user's reading history (latest first)
    Task<List<ReadingHistoryListItemDTO>> GetUserReadingHistoryAsync(string userId, int page = 1, int pageSize = 10);
    Task<int> GetUserReadingHistoryCountAsync(string userId);

    // Get specific history
    Task<ReadingHistoryDTO?> GetByIdAsync(int historyId);

    // CRUD
    Task<ReadingHistoryDTO> CreateAsync(string userId, ReadingHistoryCreateDTO dto);
    Task<ReadingHistoryDTO> UpdateAsync(int historyId, string userId, ReadingHistoryUpdateDTO dto);
    Task<bool> DeleteAsync(int historyId, string userId);
}
