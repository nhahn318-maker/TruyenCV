using Microsoft.EntityFrameworkCore;
using TruyenCV.Data;
using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Dtos.FollowAuthors;
using TruyenCV.Models;
using TruyenCV.Services.IService;

namespace TruyenCV.Services.Implementation;

public class FollowAuthorService : IFollowAuthorService
{
    private readonly IFollowAuthorRepository _followAuthorRepo;
    private readonly TruyenCVDbContext _db;

    public FollowAuthorService(IFollowAuthorRepository followAuthorRepo, TruyenCVDbContext db)
    {
        _followAuthorRepo = followAuthorRepo;
        _db = db;
    }

    public async Task<List<FollowAuthorListItemDTO>> GetUserFollowedAuthorsAsync(string userId, int page = 1, int pageSize = 10)
    {
        var follows = await _followAuthorRepo.GetUserFollowedAuthorsAsync(userId, page, pageSize);
        
        var result = new List<FollowAuthorListItemDTO>();
        foreach (var f in follows)
        {
            var totalStories = await _db.Stories.CountAsync(s => s.AuthorId == f.AuthorId);
            result.Add(new FollowAuthorListItemDTO
            {
                AuthorId = f.AuthorId,
                AuthorDisplayName = f.Author.DisplayName,
                AuthorBio = f.Author.Bio,
                AuthorAvatar = f.Author.AvatarUrl,
                TotalStories = totalStories,
                CreatedAt = f.CreatedAt
            });
        }
        
        return result;
    }

    public Task<int> GetUserFollowedAuthorsCountAsync(string userId)
    {
        return _followAuthorRepo.GetUserFollowedAuthorsCountAsync(userId);
    }

    public async Task<FollowAuthorDTO?> GetByUserAndAuthorAsync(string userId, int authorId)
    {
        var follow = await _followAuthorRepo.GetByUserAndAuthorAsync(userId, authorId);
        if (follow is null) return null;

        var totalStories = await _db.Stories.CountAsync(s => s.AuthorId == authorId);

        return new FollowAuthorDTO
        {
            ApplicationUserId = follow.ApplicationUserId,
            AuthorId = follow.AuthorId,
            AuthorDisplayName = follow.Author.DisplayName,
            AuthorBio = follow.Author.Bio,
            AuthorAvatar = follow.Author.AvatarUrl,
            TotalStories = totalStories,
            CreatedAt = follow.CreatedAt
        };
    }

    public Task<bool> IsFollowingAsync(string userId, int authorId)
    {
        return _followAuthorRepo.FollowExistsAsync(userId, authorId);
    }

    public async Task<FollowAuthorDTO> CreateAsync(string userId, FollowAuthorCreateDTO dto)
    {
        // Validate user exists
        if (!await _followAuthorRepo.UserExistsAsync(userId))
            throw new ArgumentException("User not found");

        // Validate author exists
        if (!await _followAuthorRepo.AuthorExistsAsync(dto.AuthorId))
            throw new ArgumentException("Author not found");

        // Check if already following
        if (await _followAuthorRepo.FollowExistsAsync(userId, dto.AuthorId))
            throw new InvalidOperationException("Already following this author");

        var followAuthor = new FollowAuthor
        {
            ApplicationUserId = userId,
            AuthorId = dto.AuthorId,
            CreatedAt = DateTime.UtcNow
        };

        await _followAuthorRepo.CreateAsync(followAuthor);

        // Fetch the created follow with related data
        var created = await _followAuthorRepo.GetByUserAndAuthorAsync(userId, dto.AuthorId);
        if (created is null)
            throw new InvalidOperationException("Failed to create follow");

        var totalStories = await _db.Stories.CountAsync(s => s.AuthorId == dto.AuthorId);

        return new FollowAuthorDTO
        {
            ApplicationUserId = created.ApplicationUserId,
            AuthorId = created.AuthorId,
            AuthorDisplayName = created.Author.DisplayName,
            AuthorBio = created.Author.Bio,
            AuthorAvatar = created.Author.AvatarUrl,
            TotalStories = totalStories,
            CreatedAt = created.CreatedAt
        };
    }

    public async Task<bool> DeleteAsync(string userId, int authorId)
    {
        return await _followAuthorRepo.DeleteAsync(userId, authorId);
    }
}
