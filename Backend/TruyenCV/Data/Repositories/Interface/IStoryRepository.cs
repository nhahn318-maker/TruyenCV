using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Interface;

public interface IStoryRepository
{
    Task<List<Story>> GetAllAsync(int? authorId = null, int? genreId = null, string? q = null);
    Task<List<Story>> GetByGenresAsync(IReadOnlyCollection<int> genreIds);
    Task<Story?> GetByIdAsync(int id);

    // ✅ Lazy loading methods with pagination
    Task<List<Story>> GetLatestAsync(int page = 1, int pageSize = 10);
    Task<List<Story>> GetCompletedAsync(int page = 1, int pageSize = 10);
    Task<List<Story>> GetOngoingAsync(int page = 1, int pageSize = 10);

    Task<bool> AuthorExistsAsync(int authorId);
    Task<bool> GenreExistsAsync(int genreId);
    Task<bool> GenresExistAsync(IReadOnlyCollection<int> genreIds);

    Task<int> CreateAsync(Story story, IReadOnlyCollection<int> genreIds);
    Task<bool> UpdateAsync(Story story, IReadOnlyCollection<int> genreIds);

    Task<bool> DeleteAsync(int id);
}
