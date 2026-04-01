using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using TruyenCV.Dtos.Stories;
using TruyenCV.Services.IService;

namespace TruyenCV.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StoriesController : ControllerBase
{
    private readonly IStoryService _service;
    public StoriesController(IStoryService service) => _service = service;

    [HttpGet("all")]
    public async Task<IActionResult> GetAll([FromQuery] string? q = null)
    {
        var data = await _service.GetAllAsync(q);
        return Ok(new { status = true, message = "Lấy danh sách truyện thành công.", data });
    }

    [HttpGet("latest")]
    public async Task<IActionResult> GetLatest([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        try
        {
            if (page < 1)
                return BadRequest(new { status = false, message = "Trang phải từ 1 trở lên.", data = (object?)null });
            
            if (pageSize < 1 || pageSize > 100)
                return BadRequest(new { status = false, message = "Kích thước trang phải từ 1 đến 100.", data = (object?)null });

            var data = await _service.GetLatestAsync(page, pageSize);
            return Ok(new { status = true, message = "Lấy danh sách truyện mới nhất thành công.", data });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpGet("completed")]
    public async Task<IActionResult> GetCompleted([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        try
        {
            if (page < 1)
                return BadRequest(new { status = false, message = "Trang phải từ 1 trở lên.", data = (object?)null });
            
            if (pageSize < 1 || pageSize > 100)
                return BadRequest(new { status = false, message = "Kích thước trang phải từ 1 đến 100.", data = (object?)null });

            var data = await _service.GetCompletedAsync(page, pageSize);
            return Ok(new { status = true, message = "Lấy danh sách truyện đã hoàn thành thành công.", data });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpGet("ongoing")]
    public async Task<IActionResult> GetOngoing([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        try
        {
            if (page < 1)
                return BadRequest(new { status = false, message = "Trang phải từ 1 trở lên.", data = (object?)null });
            
            if (pageSize < 1 || pageSize > 100)
                return BadRequest(new { status = false, message = "Kích thước trang phải từ 1 đến 100.", data = (object?)null });

            var data = await _service.GetOngoingAsync(page, pageSize);
            return Ok(new { status = true, message = "Lấy danh sách truyện đang tiến hành thành công.", data });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpGet("by-author/{authorId:int}")]
    public async Task<IActionResult> GetByAuthor(int authorId)
    {
        try
        {
            var data = await _service.GetByAuthorAsync(authorId);
            return Ok(new { status = true, message = "Lấy danh sách truyện theo tác giả thành công.", data });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy tác giả.", data = (object?)null });
        }
    }

    [HttpGet("by-genre/{genreId:int}")]
    public async Task<IActionResult> GetByGenre(int genreId, [FromQuery] List<int>? genreIds = null)
    {
        try
        {
            // Nếu có genreIds query parameter, lọc theo nhiều thể loại
            if (genreIds is not null && genreIds.Count > 0)
            {
                var data = await _service.GetByGenresAsync(genreIds);
                return Ok(new { status = true, message = "Lấy danh sách truyện theo các thể loại thành công.", data });
            }

            // Ngược lại, lọc theo genreId từ route
            var singleData = await _service.GetByGenreAsync(genreId);
            return Ok(new { status = true, message = "Lấy danh sách truyện theo thể loại thành công.", data = singleData });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { status = false, message = "Không tìm thấy thể loại.", data = (object?)null });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var dto = await _service.GetByIdAsync(id);
        return dto is null
            ? NotFound(new { status = false, message = "Không tìm thấy truyện.", data = (object?)null })
            : Ok(new { status = true, message = "Lấy thông tin truyện thành công.", data = dto });
    }

    [HttpPost("create")]
    [Consumes("multipart/form-data", "application/x-www-form-urlencoded")]
    public async Task<IActionResult> Create([FromForm] StoryCreateDTO dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "Dữ liệu không hợp lệ.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var created = await _service.CreateAsync(dto);
            return StatusCode(201, new { status = true, message = "Tạo truyện thành công.", data = created });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
        catch (InvalidOperationException ex)
        {
            return StatusCode(500, new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [HttpPut("update-{id:int}")]
    [Consumes("multipart/form-data", "application/x-www-form-urlencoded")]
    public async Task<IActionResult> Update(int id, [FromForm] StoryUpdateDTO dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(new { status = false, message = "Dữ liệu không hợp lệ.", data = (object?)null, errors = ToErrorDict(ModelState) });

        try
        {
            var updated = await _service.UpdateAsync(id, dto);
            return Ok(new { status = true, message = "Cập nhật truyện thành công.", data = updated });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { status = false, message = ex.Message, data = (object?)null });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { status = false, message = ex.Message, data = (object?)null });
        }
        catch (InvalidOperationException ex)
        {
            return StatusCode(500, new { status = false, message = ex.Message, data = (object?)null });
        }
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("delete-{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var ok = await _service.DeleteAsync(id);
        return ok
            ? Ok(new { status = true, message = "Xóa truyện thành công.", data = new { storyId = id } })
            : NotFound(new { status = false, message = "Không tìm thấy truyện để xóa.", data = (object?)null });
    }

    private static Dictionary<string, string[]> ToErrorDict(ModelStateDictionary modelState)
        => modelState
            .Where(x => x.Value?.Errors.Count > 0)
            .ToDictionary(
                k => k.Key,
                v => v.Value!.Errors.Select(e => string.IsNullOrWhiteSpace(e.ErrorMessage) ? "Dữ liệu không hợp lệ." : e.ErrorMessage).ToArray()
            );
}
