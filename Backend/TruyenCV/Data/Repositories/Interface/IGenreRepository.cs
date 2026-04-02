using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Interface;

public interface IGenreRepository
{
    Task<List<Genre>> GetAllAsync();
    Task<Genre?> GetByIdAsync(int id);

    Task<bool> ExistsAsync(int id);
    Task<bool> ExistsByNameAsync(string name, int? excludeId = null);

    Task<int> CreateAsync(Genre genre);
    Task<bool> UpdateAsync(Genre genre);

    Task<bool> IsInUseAsync(int genreId); // primary hoặc storygenre
    Task<bool> DeleteAsync(int id);

    Task<List<Story>> GetStoriesByGenreAsync(int genreId);
}
