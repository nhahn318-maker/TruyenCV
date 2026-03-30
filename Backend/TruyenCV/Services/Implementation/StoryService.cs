using TruyenCV.Data.Repositories.Interface;
using TruyenCV.Dtos.Stories;
using TruyenCV.Models;
using TruyenCV.Services.IService;

namespace TruyenCV.Services.Implementation;

public class StoryService : IStoryService
{
    private readonly IStoryRepository _repo;
    
    public StoryService(IStoryRepository repo)
    {
        _repo = repo;
    }

    public async Task<List<StoryListItemDTO>> GetAllAsync(string? q = null)
    {
        var list = await _repo.GetAllAsync(authorId: null, genreId: null, q);
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<List<StoryListItemDTO>> GetByAuthorAsync(int authorId)
    {
        if (!await _repo.AuthorExistsAsync(authorId))
            throw new KeyNotFoundException("Không tìm th?y tác gi?.");

        var list = await _repo.GetAllAsync(authorId, genreId: null, q: null);
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<List<StoryListItemDTO>> GetByGenreAsync(int genreId)
    {
        if (!await _repo.GenreExistsAsync(genreId))
            throw new KeyNotFoundException("Không tìm th?y th? lo?i.");

        var list = await _repo.GetAllAsync(authorId: null, genreId, q: null);
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<List<StoryListItemDTO>> GetByGenresAsync(List<int>? genreIds)
    {
        if (genreIds is null || genreIds.Count == 0)
            throw new ArgumentException("Danh sách th? lo?i không ???c ?? tr?ng.");

        var distinctIds = genreIds.Where(x => x > 0).Distinct().ToList();
        if (distinctIds.Count == 0)
            throw new ArgumentException("Danh sách th? lo?i không h?p l?.");

        if (!await _repo.GenresExistAsync(distinctIds))
            throw new KeyNotFoundException("Có th? lo?i không t?n t?i.");

        var list = await _repo.GetByGenresAsync(distinctIds);
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<StoryDTO?> GetByIdAsync(int id)
    {
        var s = await _repo.GetByIdAsync(id);
        return s is null ? null : MapToDTO(s);
    }

    public async Task<List<StoryListItemDTO>> GetLatestAsync(int page = 1, int pageSize = 10)
    {
        var list = await _repo.GetLatestAsync(page, pageSize);
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<List<StoryListItemDTO>> GetCompletedAsync(int page = 1, int pageSize = 10)
    {
        var list = await _repo.GetCompletedAsync(page, pageSize);
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<List<StoryListItemDTO>> GetOngoingAsync(int page = 1, int pageSize = 10)
    {
        var list = await _repo.GetOngoingAsync(page, pageSize);
        return list.Select(MapToListItemDTO).ToList();
    }

    public async Task<StoryDTO> CreateAsync(StoryCreateDTO dto)
    {
        var n = Normalize(dto);
        await ValidateAsync(n);

        var now = DateTime.UtcNow;

        var entity = new Story
        {
            Title = n.Title,
            AuthorId = n.AuthorId,
            Description = n.Description,
            CoverImage = n.CoverImage,
            BannerImage = n.BannerImage,
            PrimaryGenreId = n.PrimaryGenreId,
            Status = n.Status,
            CreatedAt = now,
            UpdatedAt = now
        };

        var id = await _repo.CreateAsync(entity, n.GenreIds);

        var created = await _repo.GetByIdAsync(id);
        if (created is null) throw new InvalidOperationException("T?o truy?n th?t b?i. Vui lòng th? l?i.");

        return MapToDTO(created);
    }

    public async Task<StoryDTO> UpdateAsync(int id, StoryUpdateDTO dto)
    {
        var existing = await _repo.GetByIdAsync(id);
        if (existing is null) throw new KeyNotFoundException("Không tìm th?y truy?n ?? c?p nh?t.");

        var n = Normalize(dto);
        await ValidateAsync(n);

        var entity = new Story
        {
            StoryId = id,
            Title = n.Title,
            AuthorId = n.AuthorId,
            Description = n.Description,
            CoverImage = n.CoverImage,
            BannerImage = n.BannerImage,
            PrimaryGenreId = n.PrimaryGenreId,
            Status = n.Status,
            CreatedAt = existing.CreatedAt,
            UpdatedAt = DateTime.UtcNow
        };

        var ok = await _repo.UpdateAsync(entity, n.GenreIds);
        if (!ok) throw new KeyNotFoundException("Không tìm th?y truy?n ?? c?p nh?t.");

        var updated = await _repo.GetByIdAsync(id);
        if (updated is null) throw new InvalidOperationException("C?p nh?t truy?n th?t b?i. Vui lòng th? l?i.");

        return MapToDTO(updated);
    }

    public Task<bool> DeleteAsync(int id) => _repo.DeleteAsync(id);

    // ---------- helpers ----------

    private static NormalizedStory Normalize(StoryCreateDTO dto)
        => NormalizeCore(
            dto.Title, dto.AuthorId, dto.Description,
            dto.CoverImage, dto.BannerImage,
            dto.PrimaryGenreId, dto.Status, dto.GenreIds
        );

    private static NormalizedStory Normalize(StoryUpdateDTO dto)
        => NormalizeCore(
            dto.Title, dto.AuthorId, dto.Description,
            dto.CoverImage, dto.BannerImage,
            dto.PrimaryGenreId, dto.Status, dto.GenreIds
        );

    private static NormalizedStory NormalizeCore(
        string? title, int authorId, string? description,
        string? coverImage, string? bannerImage,
        int? primaryGenreId, string? status, List<int>? genreIds
    )
    {
        var st = string.IsNullOrWhiteSpace(status) ? "?ang ti?n hành" : status.Trim();

        var ids = (genreIds ?? new List<int>())
            .Where(x => x > 0)
            .Distinct()
            .ToList();

        if (primaryGenreId is not null)
            ids = ids.Append(primaryGenreId.Value).Distinct().ToList();

        return new NormalizedStory(
            Title: (title ?? "").Trim(),
            AuthorId: authorId,
            Description: string.IsNullOrWhiteSpace(description) ? null : description.Trim(),
            CoverImage: string.IsNullOrWhiteSpace(coverImage) ? null : coverImage.Trim(),
            BannerImage: string.IsNullOrWhiteSpace(bannerImage) ? null : bannerImage.Trim(),
            PrimaryGenreId: primaryGenreId,
            Status: st,
            GenreIds: ids
        );
    }

    private async Task ValidateAsync(NormalizedStory n)
    {
        if (string.IsNullOrWhiteSpace(n.Title))
            throw new ArgumentException("Tiêu ?? truy?n không ???c ?? tr?ng.");

        if (n.Title.Length > 200)
            throw new ArgumentException("Tiêu ?? truy?n t?i ?a 200 ký t?.");

        if (n.Status is not ("?ang ti?n hành" or "?ã hoàn thành"))
            throw new ArgumentException("Tr?ng thái không h?p l?. Ch? ch?p nh?n: '?ang ti?n hành' ho?c '?ã hoàn thành'.");

        if (!await _repo.AuthorExistsAsync(n.AuthorId))
            throw new ArgumentException("Tác gi? không t?n t?i.");

        if (n.PrimaryGenreId is not null && !await _repo.GenreExistsAsync(n.PrimaryGenreId.Value))
            throw new ArgumentException("Th? lo?i chính không t?n t?i.");

        if (n.GenreIds.Count > 0 && !await _repo.GenresExistAsync(n.GenreIds))
            throw new ArgumentException("Có th? lo?i không t?n t?i.");

        if (n.CoverImage is not null && n.CoverImage.Length > 500)
            throw new ArgumentException("???ng d?n ?nh bìa t?i ?a 500 ký t?.");

        if (n.BannerImage is not null && n.BannerImage.Length > 500)
            throw new ArgumentException("???ng d?n banner t?i ?a 500 ký t?.");
    }

    private readonly record struct NormalizedStory(
        string Title,
        int AuthorId,
        string? Description,
        string? CoverImage,
        string? BannerImage,
        int? PrimaryGenreId,
        string Status,
        List<int> GenreIds
    );

    private static StoryListItemDTO MapToListItemDTO(Story s) => new()
    {
        StoryId = s.StoryId,
        Title = s.Title,
        AuthorId = s.AuthorId,
        PrimaryGenreId = s.PrimaryGenreId,
        Status = s.Status,
        CoverImage = s.CoverImage ?? "",
        UpdatedAt = s.UpdatedAt
    };

    private static StoryDTO MapToDTO(Story s) => new()
    {
        StoryId = s.StoryId,
        Title = s.Title,
        AuthorId = s.AuthorId,
        PrimaryGenreId = s.PrimaryGenreId,
        Status = s.Status,
        Description = s.Description,
        CoverImage = s.CoverImage,
        BannerImage = s.BannerImage,
        CreatedAt = s.CreatedAt,
        UpdatedAt = s.UpdatedAt,
        GenreIds = s.StoryGenres.Select(x => x.GenreId).Distinct().ToList(),
        Chapters = s.Chapters
            .OrderBy(c => c.ChapterNumber)
            .Select(c => new
            {
                c.ChapterId,
                c.ChapterNumber,
                c.Title,
                c.ReadCont,
                c.CreatedAt,
                c.UpdatedAt
            })
            .Cast<object>()
            .ToList()
    };
}
