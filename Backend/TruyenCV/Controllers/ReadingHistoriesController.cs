using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.Security.Claims;
using TruyenCV.Dtos.ReadingHistory;
using TruyenCV.Services.IService;

namespace TruyenCV.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ReadingHistoriesController : ControllerBase
{
    private readonly IReadingHistoryService _service;

    public ReadingHistoriesController(IReadingHistoryService service) => _service = service;

    [HttpGet("my-history")]
    public async Task<IActionResult> GetMyReadingHistory([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized(new { status = false, message = "Ng??i dùng ch?a xác th?c.", data = (object?)null });

        try
        {
            if (page < 1)
                return BadRequest(new { status = false, message = "Trang ph?i t? 1 tr? lên.", data = (object?)null });

            if (pageSize < 1 || pageSize > 100)
                return BadRequest(new { status = false, message = "Kích th??c trang ph?i t? 1 ??n 100.", data = (object?)null });

            var histories = await _service.GetUserReadingHistoryAsync(userId, page, pageSize);
            var count = await _service.GetUserReadingHistoryCountAsync(userId);

            return Ok(new
            {
                status = true,
                message = "L?y danh sách l?ch s? ??c thành công.",
                data = new { histories, total = count, page, pageSize }
            });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm th?y ng??i dùng.", data = (object?)null });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] ReadingHistoryCreateDTO dto)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized(new { status = false, message = "Ng??i dùng ch?a xác th?c.", data = (object?)null });

        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "D? li?u không h?p l?.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var created = await _service.CreateAsync(userId, dto);
            return StatusCode(201, new { status = true, message = "L?ch s? ??c ???c t?o thành công.", data = created });
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

    [HttpPut("update-{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] ReadingHistoryUpdateDTO dto)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized(new { status = false, message = "Ng??i dùng ch?a xác th?c.", data = (object?)null });

        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "D? li?u không h?p l?.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var updated = await _service.UpdateAsync(id, userId, dto);
            return Ok(new { status = true, message = "C?p nh?t l?ch s? ??c thành công.", data = updated });
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
                ? Ok(new { status = true, message = "Xóa l?ch s? ??c thành công.", data = new { historyId = id } })
                : NotFound(new { status = false, message = "Không tìm th?y l?ch s? ??c ?? xóa.", data = (object?)null });
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
