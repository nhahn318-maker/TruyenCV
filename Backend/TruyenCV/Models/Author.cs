using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TruyenCV.Models;

[Table("Authors", Schema = "dbo")]
public class Author
{
    [Key]
    [Column("author_id")]
    public int AuthorId { get; set; }

    [Required, StringLength(150)]
    [Column("display_name")]
    public string DisplayName { get; set; } = null!;

    [Column("bio")]
    public string? Bio { get; set; }

    [StringLength(500)]
    [Column("avatar_url")]
    public string? AvatarUrl { get; set; }

    // Optional: nếu sau này muốn liên kết tác giả với account login
    [StringLength(450)]
    [Column("application_user_id")]
    public string? ApplicationUserId { get; set; }

    [ForeignKey(nameof(ApplicationUserId))]
    public ApplicationUser? ApplicationUser { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Story> Stories { get; set; } = new List<Story>();
}
