using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.Security.Claims;
using TruyenCV.Dtos.Ratings;
using TruyenCV.Services.IService;

namespace TruyenCV.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RatingsController : ControllerBase
{
    private readonly IRatingService _service;
    public RatingsController(IRatingService service) => _service = service;


    [HttpGet("by-story/{storyId:int}")]
    public async Task<IActionResult> GetByStory(int storyId)
    {
        try
        {
            var data = await _service.GetByStoryAsync(storyId);
            return Ok(new { status = true, message = "Lấy danh sách đánh giá theo truyện thành công.", data });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy truyện.", data = (object?)null });
        }
    }

    [HttpGet("summary/{storyId:int}")]
    public async Task<IActionResult> GetSummary(int storyId)
    {
        try
        {
            var data = await _service.GetSummaryAsync(storyId);
            return Ok(new { status = true, message = "Lấy tổng hợp đánh giá thành công.", data });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy truyện.", data = (object?)null });
        }
    }

    [Authorize(Roles = "Employee,Admin")]
    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] RatingCreateDTO dto)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized(new { status = false, message = "Người dùng chưa xác thực.", data = (object?)null });

        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "Dữ liệu không hợp lệ.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var newId = await _service.CreateAsync(userId, dto);
            return StatusCode(201, new { status = true, message = "Tạo đánh giá thành công.", data = new { ratingId = newId } });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [Authorize(Roles = "Employee,Admin")]
    [HttpPut("update-{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] RatingUpdateDTO dto)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized(new { status = false, message = "Người dùng chưa xác thực.", data = (object?)null });

        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "Dữ liệu không hợp lệ.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            await _service.UpdateAsync(id, userId, dto);
            return Ok(new { status = true, message = "Cập nhật đánh giá thành công.", data = new { ratingId = id } });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy đánh giá để cập nhật.", data = (object?)null });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("delete-{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized(new { status = false, message = "Người dùng chưa xác thực.", data = (object?)null });

        try
        {
            await _service.DeleteAsync(id, userId);
            return Ok(new { status = true, message = "Xóa đánh giá thành công.", data = new { ratingId = id } });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy đánh giá để xóa.", data = (object?)null });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
    }

    private static Dictionary<string, string[]> ToErrorDict(ModelStateDictionary modelState)
        => modelState
            .Where(x => x.Value?.Errors.Count > 0)
            .ToDictionary(
                k => k.Key,
                v => v.Value!.Errors
                    .Select(e => string.IsNullOrWhiteSpace(e.ErrorMessage) ? "Dữ liệu không hợp lệ." : e.ErrorMessage)
                    .ToArray()
            );
}
