using TruyenCV.Dtos.Authors;
using TruyenCV.Dtos.Stories;

public interface IAuthorService
{
    Task<List<AuthorListItemDTO>> GetAllAsync();
    Task<AuthorDTO?> GetByIdAsync(int id);

    Task<int> CreateAsync(AuthorCreateDTO dto);          // trả newId
    Task<bool> UpdateAsync(int id, AuthorUpdateDTO dto); // true/false (not found)
    Task<bool> DeleteAsync(int id);                      // true/false (not found)

    Task<List<StoryBriefDTO>?> GetStoriesAsync(int authorId); // null = không có author
}
