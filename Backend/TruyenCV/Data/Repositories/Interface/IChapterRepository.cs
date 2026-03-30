using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Interface;

public interface IChapterRepository
{
    Task<List<Chapter>> GetAllAsync();
    Task<Chapter?> GetByIdAsync(int id);
    Task<List<Chapter>> GetChaptersByStoryAsync(int storyId);
    Task<Chapter?> GetChapterByNumberAsync(int storyId, int chapterNumber);
    Task<bool> ExistsAsync(int id);
    Task<bool> StoryExistsAsync(int storyId);
    Task<int> CreateAsync(Chapter chapter);
    Task<bool> UpdateAsync(Chapter chapter);
    Task<bool> DeleteAsync(int id);
}
