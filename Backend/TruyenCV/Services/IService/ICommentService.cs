using TruyenCV.Dtos.Comments;

namespace TruyenCV.Services.IService;

public interface ICommentService
{
    // Get comments by story
    Task<List<CommentListItemDTO>> GetByStoryAsync(int storyId, int page = 1, int pageSize = 10);
    Task<int> GetStoryCommentCountAsync(int storyId);

    // Get comments by chapter
    Task<List<CommentListItemDTO>> GetByChapterAsync(int chapterId, int page = 1, int pageSize = 10);
    Task<int> GetChapterCommentCountAsync(int chapterId);

    // Get story ID by chapter ID
    Task<int> GetStoryIdByChapterAsync(int chapterId);

    // Get comment by ID
    Task<CommentDTO?> GetByIdAsync(int id);

    // CRUD operations
    Task<CommentDTO> CreateAsync(string userId, CommentCreateDTO dto);
    Task<CommentDTO> UpdateAsync(int id, string userId, CommentUpdateDTO dto);
    Task<bool> DeleteAsync(int id, string userId);
}
