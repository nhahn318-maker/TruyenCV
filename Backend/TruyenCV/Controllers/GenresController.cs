using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using TruyenCV.Dtos.Genres;
using TruyenCV.Services.IService;

namespace TruyenCV.Controllers;

[ApiController]
[Route("api/[controller]")]
public class GenresController : ControllerBase
{
    private readonly IGenreService _service;
    public GenresController(IGenreService service) => _service = service;

    [HttpGet("all")]
    public async Task<IActionResult> GetAll()
        => Ok(new { status = true, message = "Lấy danh sách thể loại thành công.", data = await _service.GetAllAsync() });

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var dto = await _service.GetByIdAsync(id);
        return dto is null
            ? NotFound(new { status = false, message = "Không tìm thấy thể loại.", data = (object?)null })
            : Ok(new { status = true, message = "Lấy thông tin thể loại thành công.", data = dto });
    }


    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] GenreCreateDTO dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "Dữ liệu không hợp lệ.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var newId = await _service.CreateAsync(dto);
            return StatusCode(201, new { status = true, message = "Tạo thể loại thành công.", data = new { genreId = newId } });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpPut("update-{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] GenreUpdateDTO dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "Dữ liệu không hợp lệ.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            await _service.UpdateAsync(id, dto);
            return Ok(new { status = true, message = "Cập nhật thể loại thành công.", data = new { genreId = id } });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy thể loại để cập nhật.", data = (object?)null });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpDelete("delete-{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        try
        {
            await _service.DeleteAsync(id);
            return Ok(new { status = true, message = "Xóa thể loại thành công.", data = new { genreId = id } });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy thể loại để xóa.", data = (object?)null });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
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
