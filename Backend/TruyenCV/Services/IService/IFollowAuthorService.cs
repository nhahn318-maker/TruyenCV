using TruyenCV.Dtos.FollowAuthors;

namespace TruyenCV.Services.IService;

public interface IFollowAuthorService
{
    // Get user's followed authors (with pagination)
    Task<List<FollowAuthorListItemDTO>> GetUserFollowedAuthorsAsync(string userId, int page = 1, int pageSize = 10);
    Task<int> GetUserFollowedAuthorsCountAsync(string userId);

    // Get specific follow
    Task<FollowAuthorDTO?> GetByUserAndAuthorAsync(string userId, int authorId);

    // Check if following
    Task<bool> IsFollowingAsync(string userId, int authorId);

    // CRUD
    Task<FollowAuthorDTO> CreateAsync(string userId, FollowAuthorCreateDTO dto);
    Task<bool> DeleteAsync(string userId, int authorId);
}
