using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Interface;

public interface IAuthorRepository
{
    Task<List<Author>> GetAllAsync();
    Task<Author?> GetByIdAsync(int id);
    Task<bool> ExistsAsync(int id);

    Task<int> CreateAsync(Author author);
    Task<bool> UpdateAsync(Author author);
    Task<bool> DeleteAsync(int id);

    Task<List<(int StoryId, string Title, string Status, DateTime UpdatedAt)>> GetStoriesByAuthorAsync(int authorId);
}
