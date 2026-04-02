using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Dtos.Genres;
using TruyenCV.Dtos.Stories;
using TruyenCV.Models;
using TruyenCV.Services.IService;

namespace TruyenCV.Services.Implementation;

public class GenreService : IGenreService
{
    private readonly IGenreRepository _repo;
    public GenreService(IGenreRepository repo) => _repo = repo;

    public async Task<List<GenreListItemDTO>> GetAllAsync()
    {
        var list = await _repo.GetAllAsync();
        return list.Select(g => new GenreListItemDTO
        {
            GenreId = g.GenreId,
            Name = g.Name
        }).ToList();
    }

    public async Task<GenreDTO?> GetByIdAsync(int id)
    {
        var g = await _repo.GetByIdAsync(id);
        return g is null ? null : new GenreDTO { GenreId = g.GenreId, Name = g.Name };
    }

    public async Task<int> CreateAsync(GenreCreateDTO dto)
    {
        var name = (dto.Name ?? "").Trim();

        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Tên thể loại không được để trống.");

        if (name.Length > 100)
            throw new ArgumentException("Tên thể loại tối đa 100 ký tự.");

        if (await _repo.ExistsByNameAsync(name))
            throw new ArgumentException("Tên thể loại đã tồn tại.");

        var entity = new Genre { Name = name };
        return await _repo.CreateAsync(entity);
    }

    public async Task UpdateAsync(int id, GenreUpdateDTO dto)
    {
        var existing = await _repo.GetByIdAsync(id);
        if (existing is null)
            throw new KeyNotFoundException("Không tìm thấy thể loại để cập nhật.");

        var name = (dto.Name ?? "").Trim();

        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Tên thể loại không được để trống.");

        if (name.Length > 100)
            throw new ArgumentException("Tên thể loại tối đa 100 ký tự.");

        if (await _repo.ExistsByNameAsync(name, excludeId: id))
            throw new ArgumentException("Tên thể loại đã tồn tại.");

        var entity = new Genre { GenreId = id, Name = name };
        var ok = await _repo.UpdateAsync(entity);
        if (!ok) throw new KeyNotFoundException("Không tìm thấy thể loại để cập nhật.");
    }

    public async Task DeleteAsync(int id)
    {
        var exists = await _repo.ExistsAsync(id);
        if (!exists)
            throw new KeyNotFoundException("Không tìm thấy thể loại để xóa.");

        if (await _repo.IsInUseAsync(id))
            throw new ArgumentException("Không thể xóa thể loại vì đang được sử dụng trong truyện.");

        var ok = await _repo.DeleteAsync(id);
        if (!ok) throw new KeyNotFoundException("Không tìm thấy thể loại để xóa.");
    }

    public async Task<List<StoryBriefDTO>> GetStoriesAsync(int genreId)
    {
        var exists = await _repo.ExistsAsync(genreId);
        if (!exists) throw new KeyNotFoundException("Không tìm thấy thể loại.");

        var rows = await _repo.GetStoriesByGenreAsync(genreId);
        return rows.Select(s => new StoryBriefDTO
        {
            StoryId = s.StoryId,
            Title = s.Title,
            Status = s.Status,
            UpdatedAt = s.UpdatedAt
        }).ToList();
    }
}
