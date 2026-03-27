using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using TruyenCV.Dtos.Chapters;
using TruyenCV.Services.IService;

namespace TruyenCV.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ChaptersController : ControllerBase
{
    private readonly IChapterService _service;
    public ChaptersController(IChapterService service) => _service = service;

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var dto = await _service.GetByIdAsync(id);
        return dto is null
            ? NotFound(new { status = false, message = "Không tìm thấy chương.", data = (object?)null })
            : Ok(new { status = true, message = "Lấy thông tin chương thành công.", data = dto });
    }

    [HttpGet("by-story/{storyId:int}")]
    public async Task<IActionResult> GetByStory(int storyId)
    {
        try
        {
            var data = await _service.GetChaptersByStoryAsync(storyId);
            return Ok(new { status = true, message = "Lấy danh sách chương theo truyện thành công.", data });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy truyện.", data = (object?)null });
        }
    }

    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] ChapterCreateDTO dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "Dữ liệu không hợp lệ.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var newId = await _service.CreateAsync(dto);
            return StatusCode(201, new { status = true, message = "Tạo chương thành công.", data = new { chapterId = newId } });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpPut("update-{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] ChapterUpdateDTO dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "Dữ liệu không hợp lệ.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            await _service.UpdateAsync(id, dto);
            return Ok(new { status = true, message = "Cập nhật chương thành công.", data = new { chapterId = id } });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy chương để cập nhật.", data = (object?)null });
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
        try
        {
            await _service.DeleteAsync(id);
            return Ok(new { status = true, message = "Xóa chương thành công.", data = new { chapterId = id } });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy chương để xóa.", data = (object?)null });
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
