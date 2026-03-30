using TruyenCV.Dtos.Genres;
using TruyenCV.Dtos.Stories;

namespace TruyenCV.Services.IService;

public interface IGenreService
{
    Task<List<GenreListItemDTO>> GetAllAsync();
    Task<GenreDTO?> GetByIdAsync(int id);

    Task<int> CreateAsync(GenreCreateDTO dto);
    Task UpdateAsync(int id, GenreUpdateDTO dto);
    Task DeleteAsync(int id);

    Task<List<StoryBriefDTO>> GetStoriesAsync(int genreId);
}
