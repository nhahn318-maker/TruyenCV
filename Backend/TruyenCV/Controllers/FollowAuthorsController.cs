using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TruyenCV.Dtos.FollowAuthors;
using TruyenCV.Services.IService;

namespace TruyenCV.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class FollowAuthorsController : ControllerBase
{
    private readonly IFollowAuthorService _followAuthorService;

    public FollowAuthorsController(IFollowAuthorService followAuthorService)
    {
        _followAuthorService = followAuthorService;
    }

    private string GetUserId()
    {
        return User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException("User ID not found");
    }

    /// <summary>
    /// Get current user's followed authors with pagination
    /// </summary>
    [Authorize]
    [HttpGet]
    public async Task<IActionResult> GetMyFollowedAuthors([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        try
        {
            var userId = GetUserId();
            var authors = await _followAuthorService.GetUserFollowedAuthorsAsync(userId, page, pageSize);
            var total = await _followAuthorService.GetUserFollowedAuthorsCountAsync(userId);

            return Ok(new
            {
                data = authors,
                total,
                page,
                pageSize,
                totalPages = (int)Math.Ceiling(total / (double)pageSize)
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error retrieving followed authors", error = ex.Message });
        }
    }

    /// <summary>
    /// Check if current user is following a specific author
    /// </summary>
    [Authorize]
    [HttpGet("check/{authorId}")]
    public async Task<IActionResult> CheckFollowing(int authorId)
    {
        try
        {
            var userId = GetUserId();
            var isFollowing = await _followAuthorService.IsFollowingAsync(userId, authorId);
            return Ok(new { isFollowing });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error checking follow status", error = ex.Message });
        }
    }

    /// <summary>
    /// Get specific follow by author ID
    /// </summary>
    [Authorize]
    [HttpGet("{authorId}")]
    public async Task<IActionResult> GetFollowByAuthorId(int authorId)
    {
        try
        {
            var userId = GetUserId();
            var follow = await _followAuthorService.GetByUserAndAuthorAsync(userId, authorId);
            
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
    /// Follow an author
    /// </summary>
    [Authorize]
    [HttpPost]
    public async Task<IActionResult> FollowAuthor([FromBody] FollowAuthorCreateDTO dto)
    {
        try
        {
            var userId = GetUserId();
            var follow = await _followAuthorService.CreateAsync(userId, dto);
            return CreatedAtAction(nameof(GetFollowByAuthorId), new { authorId = follow.AuthorId }, follow);
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
            return StatusCode(500, new { message = "Error following author", error = ex.Message });
        }
    }

    /// <summary>
    /// Unfollow an author
    /// </summary>
    [Authorize]
    [HttpDelete("{authorId}")]
    public async Task<IActionResult> UnfollowAuthor(int authorId)
    {
        try
        {
            var userId = GetUserId();
            var result = await _followAuthorService.DeleteAsync(userId, authorId);

            if (!result)
                return NotFound(new { message = "Follow not found" });

            return Ok(new { message = "Successfully unfollowed author" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error unfollowing author", error = ex.Message });
        }
    }
}
