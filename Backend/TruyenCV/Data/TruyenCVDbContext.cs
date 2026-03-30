using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using TruyenCV.Models;

namespace TruyenCV.Data
{
    public partial class TruyenCVDbContext : IdentityDbContext<ApplicationUser>
    {
        public TruyenCVDbContext(DbContextOptions<TruyenCVDbContext> options)
            : base(options)
        {
        }
        public virtual DbSet<Author> Authors { get; set; } = null!;
        public virtual DbSet<Story> Stories { get; set; } = null!;
        public virtual DbSet<Genre> Genres { get; set; } = null!;
        public virtual DbSet<StoryGenre> StoryGenres { get; set; } = null!;
        public virtual DbSet<Chapter> Chapters { get; set; } = null!;
        public virtual DbSet<Bookmark> Bookmarks { get; set; } = null!;
        public virtual DbSet<Rating> Ratings { get; set; } = null!;
        public virtual DbSet<ReadingHistory> ReadingHistories { get; set; } = null!;
        public virtual DbSet<Comment> Comments { get; set; } = null!;
        public virtual DbSet<FollowStory> FollowStories { get; set; } = null!;
        public virtual DbSet<FollowAuthor> FollowAuthors { get; set; } = null!;
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<StoryGenre>()
                .HasKey(sg => new { sg.StoryId, sg.GenreId });

            modelBuilder.Entity<Story>()
                .HasOne(s => s.PrimaryGenre)
                .WithMany(g => g.PrimaryGenreStories)
                .HasForeignKey(s => s.PrimaryGenreId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Bookmark>()
                .HasKey(b => new { b.ApplicationUserId, b.StoryId });

            // FollowStory: PK ghép
            modelBuilder.Entity<FollowStory>(e =>
            {
                e.HasKey(x => new { x.ApplicationUserId, x.StoryId });

                e.HasOne(x => x.ApplicationUser)
                 .WithMany() // hoặc .WithMany(u => u.FollowStories) nếu có
                 .HasForeignKey(x => x.ApplicationUserId);

                e.HasOne(x => x.Story)
                 .WithMany(s => s.FollowStories) // vì Story.cs có collection này
                 .HasForeignKey(x => x.StoryId);

                e.Property(x => x.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            });

            // FollowAuthor: PK ghép (KHỚP DB)
            modelBuilder.Entity<FollowAuthor>(e =>
            {
                e.HasKey(x => new { x.ApplicationUserId, x.AuthorId });

                e.HasOne(x => x.Follower)
                 .WithMany()
                 .HasForeignKey(x => x.ApplicationUserId);

                e.HasOne(x => x.Author)
                 .WithMany()
                 .HasForeignKey(x => x.AuthorId);

                e.Property(x => x.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            });
        }

    }
}
