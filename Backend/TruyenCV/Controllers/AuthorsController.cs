using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using TruyenCV.Dtos.Authors;
using TruyenCV.Services;

namespace TruyenCV.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthorsController : ControllerBase
{
    private readonly IAuthorService _service;
    public AuthorsController(IAuthorService service) => _service = service;

    [HttpGet("all")]
    public async Task<IActionResult> GetAll()
        => Ok(new { status = true, message = "Lấy danh sách tác giả thành công.", data = await _service.GetAllAsync() });

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var dto = await _service.GetByIdAsync(id);
        return dto is null
            ? NotFound(new { status = false, message = "Không tìm thấy tác giả.", data = (object?)null })
            : Ok(new { status = true, message = "Lấy thông tin tác giả thành công.", data = dto });
    }

    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] AuthorCreateDTO dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "Dữ liệu không hợp lệ.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var newId = await _service.CreateAsync(dto);
            return StatusCode(201, new { status = true, message = "Tạo tác giả thành công.", data = new { authorId = newId } });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpPut("update-{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] AuthorUpdateDTO dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "Dữ liệu không hợp lệ.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var ok = await _service.UpdateAsync(id, dto);
            return ok
                ? Ok(new { status = true, message = "Cập nhật tác giả thành công.", data = new { authorId = id } })
                : NotFound(new { status = false, message = "Không tìm thấy tác giả để cập nhật.", data = (object?)null });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpDelete("delete-{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var ok = await _service.DeleteAsync(id);
        return ok
            ? Ok(new { status = true, message = "Xóa tác giả thành công.", data = new { authorId = id } })
            : NotFound(new { status = false, message = "Không tìm thấy tác giả để xóa.", data = (object?)null });
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
