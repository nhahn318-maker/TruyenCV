using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Dtos.Comments;
using TruyenCV.Models;
using TruyenCV.Services.IService;

namespace TruyenCV.Services.Implementation;

public class CommentService : ICommentService
{
    private readonly ICommentRepository _repo;

    public CommentService(ICommentRepository repo) => _repo = repo;

    public async Task<List<CommentListItemDTO>> GetByStoryAsync(int storyId, int page = 1, int pageSize = 10)
    {
        if (!await _repo.StoryExistsAsync(storyId))
            throw new KeyNotFoundException("Không tìm th?y truy?n.");

        var comments = await _repo.GetByStoryAsync(storyId, page, pageSize);
        return comments.Select(MapToListItemDTO).ToList();
    }

    public async Task<int> GetStoryCommentCountAsync(int storyId)
    {
        if (!await _repo.StoryExistsAsync(storyId))
            throw new KeyNotFoundException("Không tìm th?y truy?n.");

        return await _repo.GetStoryCommentCountAsync(storyId);
    }

    public async Task<List<CommentListItemDTO>> GetByChapterAsync(int chapterId, int page = 1, int pageSize = 10)
    {
        if (!await _repo.ChapterExistsAsync(chapterId))
            throw new KeyNotFoundException("Không tìm th?y ch??ng.");

        var comments = await _repo.GetByChapterAsync(chapterId, page, pageSize);
        return comments.Select(MapToListItemDTO).ToList();
    }

    public async Task<int> GetChapterCommentCountAsync(int chapterId)
    {
        if (!await _repo.ChapterExistsAsync(chapterId))
            throw new KeyNotFoundException("Không tìm th?y ch??ng.");

        return await _repo.GetChapterCommentCountAsync(chapterId);
    }

    public async Task<int> GetStoryIdByChapterAsync(int chapterId)
    {
        if (!await _repo.ChapterExistsAsync(chapterId))
            throw new KeyNotFoundException("Không tìm th?y ch??ng.");

        return await _repo.GetStoryIdByChapterAsync(chapterId);
    }

    public async Task<CommentDTO?> GetByIdAsync(int id)
    {
        var comment = await _repo.GetByIdAsync(id);
        return comment is null ? null : MapToDTO(comment);
    }

    public async Task<CommentDTO> CreateAsync(string userId, CommentCreateDTO dto)
    {
        // Normalize
        var content = string.IsNullOrWhiteSpace(dto.Content) ? null : dto.Content.Trim();

        // Validate
        if (string.IsNullOrWhiteSpace(content))
            throw new ArgumentException("N?i dung bình lu?n không ???c ?? tr?ng.");

        if (content.Length > 1000)
            throw new ArgumentException("N?i dung bình lu?n t?i ?a 1000 ký t?.");

        // Either storyId or chapterId must be provided
        if (!dto.StoryId.HasValue && !dto.ChapterId.HasValue)
            throw new ArgumentException("Ph?i cung c?p storyId ho?c chapterId.");

        // Both cannot be provided at the same time UNLESS it's from create-for-chapter endpoint
        if (dto.StoryId.HasValue && dto.ChapterId.HasValue)
        {
            // This is allowed - validate both exist
            if (!await _repo.StoryExistsAsync(dto.StoryId.Value))
                throw new KeyNotFoundException("Không tìm th?y truy?n.");

            if (!await _repo.ChapterExistsAsync(dto.ChapterId.Value))
                throw new KeyNotFoundException("Không tìm th?y ch??ng.");
        }
        else if (dto.StoryId.HasValue)
        {
            // Only storyId provided
            if (!await _repo.StoryExistsAsync(dto.StoryId.Value))
                throw new KeyNotFoundException("Không tìm th?y truy?n.");
        }
        else if (dto.ChapterId.HasValue)
        {
            // Only chapterId provided - validate and fetch storyId
            if (!await _repo.ChapterExistsAsync(dto.ChapterId.Value))
                throw new KeyNotFoundException("Không tìm th?y ch??ng.");

            var storyId = await _repo.GetStoryIdByChapterAsync(dto.ChapterId.Value);
            dto.StoryId = storyId;
        }

        if (!await _repo.UserExistsAsync(userId))
            throw new KeyNotFoundException("Không tìm th?y ng??i dùng.");

        var comment = new Comment
        {
            ApplicationUserId = userId,
            StoryId = dto.StoryId,
            ChapterId = dto.ChapterId,
            Content = content,
            CreatedAt = DateTime.UtcNow
        };

        var id = await _repo.CreateAsync(comment);

        var created = await _repo.GetByIdAsync(id);
        if (created is null)
            throw new InvalidOperationException("T?o bình lu?n th?t b?i.");

        return MapToDTO(created);
    }

    public async Task<CommentDTO> UpdateAsync(int id, string userId, CommentUpdateDTO dto)
    {
        var existing = await _repo.GetByIdAsync(id);
        if (existing is null)
            throw new KeyNotFoundException("Không tìm th?y bình lu?n.");

        // Only the owner can update
        if (existing.ApplicationUserId != userId)
            throw new UnauthorizedAccessException("B?n ch? có th? c?p nh?t bình lu?n c?a mình.");

        // Normalize and validate content
        var content = string.IsNullOrWhiteSpace(dto.Content) ? null : dto.Content.Trim();

        if (string.IsNullOrWhiteSpace(content))
            throw new ArgumentException("N?i dung bình lu?n không ???c ?? tr?ng.");

        if (content.Length > 1000)
            throw new ArgumentException("N?i dung bình lu?n t?i ?a 1000 ký t?.");

        existing.Content = content;

        var ok = await _repo.UpdateAsync(existing);
        if (!ok)
            throw new InvalidOperationException("C?p nh?t bình lu?n th?t b?i.");

        var updated = await _repo.GetByIdAsync(id);
        if (updated is null)
            throw new InvalidOperationException("C?p nh?t bình lu?n th?t b?i.");

        return MapToDTO(updated);
    }

    public async Task<bool> DeleteAsync(int id, string userId)
    {
        var comment = await _repo.GetByIdAsync(id);
        if (comment is null)
            throw new KeyNotFoundException("Không tìm th?y bình lu?n.");

        // Only the owner can delete
        if (comment.ApplicationUserId != userId)
            throw new UnauthorizedAccessException("B?n ch? có th? xóa bình lu?n c?a mình.");

        return await _repo.DeleteAsync(id);
    }

    // Helpers
    private static CommentDTO MapToDTO(Comment c) => new()
    {
        CommentId = c.CommentId,
        ApplicationUserId = c.ApplicationUserId,
        UserName = c.ApplicationUser?.UserName,
        StoryId = c.StoryId,
        ChapterId = c.ChapterId,
        Content = c.Content,
        CreatedAt = c.CreatedAt
    };

    private static CommentListItemDTO MapToListItemDTO(Comment c) => new()
    {
        CommentId = c.CommentId,
        ApplicationUserId = c.ApplicationUserId,
        UserName = c.ApplicationUser?.UserName,
        Content = c.Content,
        CreatedAt = c.CreatedAt
    };
}
