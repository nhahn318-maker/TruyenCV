using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TruyenCV.Dtos.FollowStories;
using TruyenCV.Services.IService;

namespace TruyenCV.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class FollowStoriesController : ControllerBase
{
    private readonly IFollowStoryService _followStoryService;

    public FollowStoriesController(IFollowStoryService followStoryService)
    {
        _followStoryService = followStoryService;
    }

    private string GetUserId()
    {
        return User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException("User ID not found");
    }

    /// <summary>
    /// Get current user's followed stories with pagination
    /// </summary>
    [Authorize]
    [HttpGet]
    public async Task<IActionResult> GetMyFollowedStories([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        try
        {
            var userId = GetUserId();
            var stories = await _followStoryService.GetUserFollowedStoriesAsync(userId, page, pageSize);
            var total = await _followStoryService.GetUserFollowedStoriesCountAsync(userId);

            return Ok(new
            {
                data = stories,
                total,
                page,
                pageSize,
                totalPages = (int)Math.Ceiling(total / (double)pageSize)
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error retrieving followed stories", error = ex.Message });
        }
    }

    /// <summary>
    /// Check if current user is following a specific story
    /// </summary>
    [Authorize]
    [HttpGet("check/{storyId}")]
    public async Task<IActionResult> CheckFollowing(int storyId)
    {
        try
        {
            var userId = GetUserId();
            var isFollowing = await _followStoryService.IsFollowingAsync(userId, storyId);
            return Ok(new { isFollowing });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error checking follow status", error = ex.Message });
        }
    }

    /// <summary>
    /// Get specific follow by story ID
    /// </summary>
    [Authorize]
    [HttpGet("{storyId}")]
    public async Task<IActionResult> GetFollowByStoryId(int storyId)
    {
        try
        {
            var userId = GetUserId();
            var follow = await _followStoryService.GetByUserAndStoryAsync(userId, storyId);
            
            if (follow is null)
                return NotFound(new { message = "Follow not found" });

            return Ok(follow);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error retrieving follow", error = ex.Message });
        }
    }

    /// <summary>
    /// Follow a story
    /// </summary>
    [Authorize]
    [HttpPost]
    public async Task<IActionResult> FollowStory([FromBody] FollowStoryCreateDTO dto)
    {
        try
        {
            var userId = GetUserId();
            var follow = await _followStoryService.CreateAsync(userId, dto);
            return CreatedAtAction(nameof(GetFollowByStoryId), new { storyId = follow.StoryId }, follow);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error following story", error = ex.Message });
        }
    }

    /// <summary>
    /// Unfollow a story
    /// </summary>
    [Authorize]
    [HttpDelete("{storyId}")]
    public async Task<IActionResult> UnfollowStory(int storyId)
    {
        try
        {
            var userId = GetUserId();
            var result = await _followStoryService.DeleteAsync(userId, storyId);

            if (!result)
                return NotFound(new { message = "Follow not found" });

            return Ok(new { message = "Successfully unfollowed story" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error unfollowing story", error = ex.Message });
        }
    }
}
