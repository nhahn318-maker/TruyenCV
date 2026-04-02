using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.Security.Claims;
using TruyenCV.Dtos.Comments;
using TruyenCV.Services.IService;

namespace TruyenCV.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CommentsController : ControllerBase
{
    private readonly ICommentService _service;

    public CommentsController(ICommentService service) => _service = service;

    [HttpGet("by-story/{storyId:int}")]
    public async Task<IActionResult> GetByStory(int storyId, [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        try
        {
            if (page < 1)
                return BadRequest(new { status = false, message = "Trang ph?i t? 1 tr? lên.", data = (object?)null });

            if (pageSize < 1 || pageSize > 100)
                return BadRequest(new { status = false, message = "Kích th??c trang ph?i t? 1 ??n 100.", data = (object?)null });

            var comments = await _service.GetByStoryAsync(storyId, page, pageSize);
            var count = await _service.GetStoryCommentCountAsync(storyId);

            return Ok(new 
            { 
                status = true, 
                message = "L?y danh sách bình lu?n truy?n thành công.", 
                data = new { comments, total = count, page, pageSize }
            });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm th?y truy?n.", data = (object?)null });
        }
    }

    [HttpGet("by-chapter/{chapterId:int}")]
    public async Task<IActionResult> GetByChapter(int chapterId, [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        try
        {
            if (page < 1)
                return BadRequest(new { status = false, message = "Trang ph?i t? 1 tr? lên.", data = (object?)null });

            if (pageSize < 1 || pageSize > 100)
                return BadRequest(new { status = false, message = "Kích th??c trang ph?i t? 1 ??n 100.", data = (object?)null });

            var comments = await _service.GetByChapterAsync(chapterId, page, pageSize);
            var count = await _service.GetChapterCommentCountAsync(chapterId);

            return Ok(new 
            { 
                status = true, 
                message = "L?y danh sách bình lu?n ch??ng thành công.", 
                data = new { comments, total = count, page, pageSize }
            });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm th?y ch??ng.", data = (object?)null });
        }
    }

    [Authorize]
    [HttpPost("create-for-chapter/{chapterId:int}")]
    public async Task<IActionResult> CreateForChapter(int chapterId, [FromBody] CommentCreateDTO dto)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized(new { status = false, message = "Ng??i dùng ch?a xác th?c.", data = (object?)null });

        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "D? li?u không h?p l?.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            dto.ChapterId = chapterId;
            dto.StoryId = null;
            var created = await _service.CreateAsync(userId, dto);
            return StatusCode(201, new { status = true, message = "T?o bình lu?n thành công.", data = created });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { status = false, message = ex.Message, data = (object?)null });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [Authorize]
    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] CommentCreateDTO dto)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized(new { status = false, message = "Ng??i dùng ch?a xác th?c.", data = (object?)null });

        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "D? li?u không h?p l?.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var created = await _service.CreateAsync(userId, dto);
            return StatusCode(201, new { status = true, message = "T?o bình lu?n thành công.", data = created });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { status = false, message = ex.Message, data = (object?)null });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [Authorize]
    [HttpPut("update-{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] CommentUpdateDTO dto)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized(new { status = false, message = "Ng??i dùng ch?a xác th?c.", data = (object?)null });

        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "D? li?u không h?p l?.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var updated = await _service.UpdateAsync(id, userId, dto);
            return Ok(new { status = true, message = "C?p nh?t bình lu?n thành công.", data = updated });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { status = false, message = ex.Message, data = (object?)null });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [Authorize]
    [HttpDelete("delete-{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized(new { status = false, message = "Ng??i dùng ch?a xác th?c.", data = (object?)null });

        try
        {
            var ok = await _service.DeleteAsync(id, userId);
            return ok
                ? Ok(new { status = true, message = "Xóa bình lu?n thành công.", data = new { commentId = id } })
                : NotFound(new { status = false, message = "Không tìm th?y bình lu?n ?? xóa.", data = (object?)null });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { status = false, message = ex.Message, data = (object?)null });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    private static Dictionary<string, string[]> ToErrorDict(ModelStateDictionary modelState)
        => modelState
            .Where(x => x.Value?.Errors.Count > 0)
            .ToDictionary(
                k => k.Key,
                v => v.Value!.Errors.Select(e => string.IsNullOrWhiteSpace(e.ErrorMessage) ? "D? li?u không h?p l?." : e.ErrorMessage).ToArray()
            );
}
