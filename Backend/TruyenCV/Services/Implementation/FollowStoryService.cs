using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Dtos.FollowStories;
using TruyenCV.Models;
using TruyenCV.Services.IService;

namespace TruyenCV.Services.Implementation;

public class FollowStoryService : IFollowStoryService
{
    private readonly IFollowStoryRepository _followStoryRepo;

    public FollowStoryService(IFollowStoryRepository followStoryRepo)
    {
        _followStoryRepo = followStoryRepo;
    }

    public async Task<List<FollowStoryListItemDTO>> GetUserFollowedStoriesAsync(string userId, int page = 1, int pageSize = 10)
    {
        var follows = await _followStoryRepo.GetUserFollowedStoriesAsync(userId, page, pageSize);
        return follows.Select(f => new FollowStoryListItemDTO
        {
            StoryId = f.StoryId,
            StoryTitle = f.Story.Title,
            StoryCoverImage = f.Story.CoverImage,
            StoryDescription = f.Story.Description,
            AuthorId = f.Story.AuthorId,
            AuthorDisplayName = f.Story.Author.DisplayName,
            Status = f.Story.Status,
            CreatedAt = f.CreatedAt
        }).ToList();
    }

    public Task<int> GetUserFollowedStoriesCountAsync(string userId)
    {
        return _followStoryRepo.GetUserFollowedStoriesCountAsync(userId);
    }

    public async Task<FollowStoryDTO?> GetByUserAndStoryAsync(string userId, int storyId)
    {
        var follow = await _followStoryRepo.GetByUserAndStoryAsync(userId, storyId);
        if (follow is null) return null;

        return new FollowStoryDTO
        {
            ApplicationUserId = follow.ApplicationUserId,
            StoryId = follow.StoryId,
            StoryTitle = follow.Story.Title,
            StoryCoverImage = follow.Story.CoverImage,
            StoryDescription = follow.Story.Description,
            AuthorId = follow.Story.AuthorId,
            AuthorDisplayName = follow.Story.Author.DisplayName,
            CreatedAt = follow.CreatedAt
        };
    }

    public Task<bool> IsFollowingAsync(string userId, int storyId)
    {
        return _followStoryRepo.FollowExistsAsync(userId, storyId);
    }

    public async Task<FollowStoryDTO> CreateAsync(string userId, FollowStoryCreateDTO dto)
    {
        // Validate user exists
        if (!await _followStoryRepo.UserExistsAsync(userId))
            throw new ArgumentException("User not found");

        // Validate story exists
        if (!await _followStoryRepo.StoryExistsAsync(dto.StoryId))
            throw new ArgumentException("Story not found");

        // Check if already following
        if (await _followStoryRepo.FollowExistsAsync(userId, dto.StoryId))
            throw new InvalidOperationException("Already following this story");

        var followStory = new FollowStory
        {
            ApplicationUserId = userId,
            StoryId = dto.StoryId,
            CreatedAt = DateTime.UtcNow
        };

        await _followStoryRepo.CreateAsync(followStory);

        // Fetch the created follow with related data
        var created = await _followStoryRepo.GetByUserAndStoryAsync(userId, dto.StoryId);
        if (created is null)
            throw new InvalidOperationException("Failed to create follow");

        return new FollowStoryDTO
        {
            ApplicationUserId = created.ApplicationUserId,
            StoryId = created.StoryId,
            StoryTitle = created.Story.Title,
            StoryCoverImage = created.Story.CoverImage,
            StoryDescription = created.Story.Description,
            AuthorId = created.Story.AuthorId,
            AuthorDisplayName = created.Story.Author.DisplayName,
            CreatedAt = created.CreatedAt
        };
    }

    public async Task<bool> DeleteAsync(string userId, int storyId)
    {
        return await _followStoryRepo.DeleteAsync(userId, storyId);
    }
}
