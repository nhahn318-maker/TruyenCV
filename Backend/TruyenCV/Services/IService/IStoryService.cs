using TruyenCV.Dtos.Stories;

namespace TruyenCV.Services.IService;

public interface IStoryService
{
    Task<List<StoryListItemDTO>> GetAllAsync(string? q = null);
    Task<List<StoryListItemDTO>> GetByAuthorAsync(int authorId);
    Task<List<StoryListItemDTO>> GetByGenreAsync(int genreId);
    Task<List<StoryListItemDTO>> GetByGenresAsync(List<int>? genreIds);
    Task<StoryDTO?> GetByIdAsync(int id);

    // ✅ Updated with page parameter for pagination
    Task<List<StoryListItemDTO>> GetLatestAsync(int page = 1, int pageSize = 10);
    Task<List<StoryListItemDTO>> GetCompletedAsync(int page = 1, int pageSize = 10);
    Task<List<StoryListItemDTO>> GetOngoingAsync(int page = 1, int pageSize = 10);

    Task<StoryDTO> CreateAsync(StoryCreateDTO dto);
    Task<StoryDTO> UpdateAsync(int id, StoryUpdateDTO dto);
    Task<bool> DeleteAsync(int id);
}
