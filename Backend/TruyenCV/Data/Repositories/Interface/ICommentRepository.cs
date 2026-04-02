using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Interface;

public interface ICommentRepository
{
    // Get comments by story
    Task<List<Comment>> GetByStoryAsync(int storyId, int page = 1, int pageSize = 10);
    Task<int> GetStoryCommentCountAsync(int storyId);

    // Get comments by chapter
    Task<List<Comment>> GetByChapterAsync(int chapterId, int page = 1, int pageSize = 10);
    Task<int> GetChapterCommentCountAsync(int chapterId);
    Task<int> GetStoryIdByChapterAsync(int chapterId);

    // Get comment by ID
    Task<Comment?> GetByIdAsync(int id);

    // Existence checks
    Task<bool> StoryExistsAsync(int storyId);
    Task<bool> ChapterExistsAsync(int chapterId);
    Task<bool> UserExistsAsync(string userId);
    Task<bool> CommentExistsAsync(int commentId);

    // Create, Update, Delete
    Task<int> CreateAsync(Comment comment);
    Task<bool> UpdateAsync(Comment comment);
    Task<bool> DeleteAsync(int id);
}
