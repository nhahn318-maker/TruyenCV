using Microsoft.EntityFrameworkCore;
using TruyenCV.Data;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Models;

namespace TruyenCV.Data.Repositories.Implementation;

public class CommentRepository : ICommentRepository
{
    private readonly TruyenCVDbContext _db;

    public CommentRepository(TruyenCVDbContext db) => _db = db;

    public async Task<List<Comment>> GetByStoryAsync(int storyId, int page = 1, int pageSize = 10)
    {
        var skip = (page - 1) * pageSize;
        return await _db.Comments.AsNoTracking()
            .Include(c => c.ApplicationUser)
            .Where(c => c.StoryId == storyId)
            .OrderByDescending(c => c.CreatedAt)
            .Skip(skip)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task<int> GetStoryCommentCountAsync(int storyId)
    {
        return await _db.Comments
            .Where(c => c.StoryId == storyId)
            .CountAsync();
    }

    public async Task<List<Comment>> GetByChapterAsync(int chapterId, int page = 1, int pageSize = 10)
    {
        var skip = (page - 1) * pageSize;
        return await _db.Comments.AsNoTracking()
            .Include(c => c.ApplicationUser)
            .Where(c => c.ChapterId == chapterId)
            .OrderByDescending(c => c.CreatedAt)
            .Skip(skip)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task<int> GetChapterCommentCountAsync(int chapterId)
    {
        return await _db.Comments
            .Where(c => c.ChapterId == chapterId)
            .CountAsync();
    }

    public async Task<int> GetStoryIdByChapterAsync(int chapterId)
    {
        return await _db.Chapters
            .Where(c => c.ChapterId == chapterId)
            .Select(c => c.StoryId)
            .FirstOrDefaultAsync();
    }

    public Task<Comment?> GetByIdAsync(int id)
    {
        return _db.Comments.AsNoTracking()
            .Include(c => c.ApplicationUser)
            .FirstOrDefaultAsync(c => c.CommentId == id);
    }

    public Task<bool> StoryExistsAsync(int storyId)
    {
        return _db.Stories.AnyAsync(s => s.StoryId == storyId);
    }

    public Task<bool> ChapterExistsAsync(int chapterId)
    {
        return _db.Chapters.AnyAsync(c => c.ChapterId == chapterId);
    }

    public Task<bool> UserExistsAsync(string userId)
    {
        return _db.Users.AnyAsync(u => u.Id == userId);
    }

    public Task<bool> CommentExistsAsync(int commentId)
    {
        return _db.Comments.AnyAsync(c => c.CommentId == commentId);
    }

    public async Task<int> CreateAsync(Comment comment)
    {
        _db.Comments.Add(comment);
        await _db.SaveChangesAsync();
        return comment.CommentId;
    }

    public async Task<bool> UpdateAsync(Comment comment)
    {
        var exists = await _db.Comments.AnyAsync(c => c.CommentId == comment.CommentId);
        if (!exists) return false;

        _db.Comments.Update(comment);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var comment = await _db.Comments.FirstOrDefaultAsync(c => c.CommentId == id);
        if (comment is null) return false;

        _db.Comments.Remove(comment);
        await _db.SaveChangesAsync();
        return true;
    }
}
