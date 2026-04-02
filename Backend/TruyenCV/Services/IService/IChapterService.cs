using TruyenCV.Dtos.Chapters;

namespace TruyenCV.Services.IService;

public interface IChapterService
{
    Task<List<ChapterListItemDTO>> GetAllAsync();
    Task<ChapterDTO?> GetByIdAsync(int id);
    Task<List<ChapterListItemDTO>> GetChaptersByStoryAsync(int storyId);
    Task<int> CreateAsync(ChapterCreateDTO dto);
    Task UpdateAsync(int id, ChapterUpdateDTO dto);
    Task DeleteAsync(int id);
}
