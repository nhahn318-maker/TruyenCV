using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Interface;

public interface IFollowAuthorRepository
{
    // Get user's followed authors with pagination
    Task<List<FollowAuthor>> GetUserFollowedAuthorsAsync(string userId, int page = 1, int pageSize = 10);
    Task<int> GetUserFollowedAuthorsCountAsync(string userId);

    // Get specific follow
    Task<FollowAuthor?> GetByUserAndAuthorAsync(string userId, int authorId);

    // Existence checks
    Task<bool> UserExistsAsync(string userId);
    Task<bool> AuthorExistsAsync(int authorId);
    Task<bool> FollowExistsAsync(string userId, int authorId);

    // CRUD
    Task<bool> CreateAsync(FollowAuthor followAuthor);
    Task<bool> DeleteAsync(string userId, int authorId);
    Task<bool> DeleteAllByUserAsync(string userId);
}
