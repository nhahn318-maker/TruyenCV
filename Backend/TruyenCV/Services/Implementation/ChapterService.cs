using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Dtos.Chapters;
using TruyenCV.Models;
using TruyenCV.Services.IService;

namespace TruyenCV.Services.Implementation;

public class ChapterService : IChapterService
{
    private readonly IChapterRepository _repo;
    public ChapterService(IChapterRepository repo) => _repo = repo;

    public async Task<List<ChapterListItemDTO>> GetAllAsync()
    {
        var list = await _repo.GetAllAsync();
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<ChapterDTO?> GetByIdAsync(int id)
    {
        var c = await _repo.GetByIdAsync(id);
        return c is null ? null : MapToDTO(c);
    }

    public async Task<List<ChapterListItemDTO>> GetChaptersByStoryAsync(int storyId)
    {
        var exists = await _repo.StoryExistsAsync(storyId);
        if (!exists)
            throw new KeyNotFoundException("Không tìm th?y truy?n.");

        var list = await _repo.GetChaptersByStoryAsync(storyId);
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<int> CreateAsync(ChapterCreateDTO dto)
    {
        var title = (dto.Title ?? "").Trim();
        var content = (dto.Content ?? "").Trim();

        if (!await _repo.StoryExistsAsync(dto.StoryId))
            throw new ArgumentException("Truy?n không t?n t?i.");

        if (dto.ChapterNumber <= 0)
            throw new ArgumentException("S? ch??ng ph?i l?n h?n 0.");

        if (string.IsNullOrWhiteSpace(content))
            throw new ArgumentException("N?i dung ch??ng không ???c ?? tr?ng.");

        if (content.Length > int.MaxValue)
            throw new ArgumentException("N?i dung ch??ng quá dài.");

        if (title.Length > 200)
            throw new ArgumentException("Tiêu ?? ch??ng t?i ?a 200 ký t?.");

        // Check if chapter with same number already exists
        var existing = await _repo.GetChapterByNumberAsync(dto.StoryId, dto.ChapterNumber);
        if (existing is not null)
            throw new ArgumentException($"Ch??ng {dto.ChapterNumber} ?ã t?n t?i trong truy?n này.");

        var now = DateTime.UtcNow;
        var entity = new Chapter
        {
            StoryId = dto.StoryId,
            ChapterNumber = dto.ChapterNumber,
            Title = string.IsNullOrWhiteSpace(title) ? null : title,
            Content = content,
            ReadCont = 0,
            CreatedAt = now,
            UpdatedAt = now
        };

        return await _repo.CreateAsync(entity);
    }

    public async Task UpdateAsync(int id, ChapterUpdateDTO dto)
    {
        var existing = await _repo.GetByIdAsync(id);
        if (existing is null)
            throw new KeyNotFoundException("Không tìm th?y ch??ng ?? c?p nh?t.");

        var title = (dto.Title ?? "").Trim();
        var content = (dto.Content ?? "").Trim();

        if (string.IsNullOrWhiteSpace(content))
            throw new ArgumentException("N?i dung ch??ng không ???c ?? tr?ng.");

        if (content.Length > int.MaxValue)
            throw new ArgumentException("N?i dung ch??ng quá dài.");

        if (title.Length > 200)
            throw new ArgumentException("Tiêu ?? ch??ng t?i ?a 200 ký t?.");

        var entity = new Chapter
        {
            ChapterId = id,
            StoryId = existing.StoryId,
            ChapterNumber = existing.ChapterNumber,
            Title = string.IsNullOrWhiteSpace(title) ? null : title,
            Content = content,
            ReadCont = existing.ReadCont,
            CreatedAt = existing.CreatedAt,
            UpdatedAt = DateTime.UtcNow
        };

        var ok = await _repo.UpdateAsync(entity);
        if (!ok) throw new KeyNotFoundException("Không tìm th?y ch??ng ?? c?p nh?t.");
    }

    public async Task DeleteAsync(int id)
    {
        var exists = await _repo.ExistsAsync(id);
        if (!exists)
            throw new KeyNotFoundException("Không tìm th?y ch??ng ?? xóa.");

        var ok = await _repo.DeleteAsync(id);
        if (!ok) throw new KeyNotFoundException("Không tìm th?y ch??ng ?? xóa.");
    }

    private static ChapterListItemDTO MapToListItemDTO(Chapter c) => new()
    {
        ChapterId = c.ChapterId,
        StoryId = c.StoryId,
        ChapterNumber = c.ChapterNumber,
        Title = c.Title,
        ReadCont = c.ReadCont,
        CreatedAt = c.CreatedAt,
        UpdatedAt = c.UpdatedAt
    };

    private static ChapterDTO MapToDTO(Chapter c) => new()
    {
        ChapterId = c.ChapterId,
        StoryId = c.StoryId,
        ChapterNumber = c.ChapterNumber,
        Title = c.Title,
        Content = c.Content,
        ReadCont = c.ReadCont,
        CreatedAt = c.CreatedAt,
        UpdatedAt = c.UpdatedAt
    };
}
