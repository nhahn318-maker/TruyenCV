using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TruyenCV.Migrations
{
    /// <inheritdoc />
    public partial class change : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "dbo");

            migrationBuilder.CreateTable(
                name: "Authors",
                schema: "dbo",
                columns: table => new
                {
                    author_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    display_name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    bio = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    avatar_url = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    application_user_id = table.Column<string>(type: "nvarchar(450)", maxLength: 450, nullable: true),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Authors", x => x.author_id);
                    table.ForeignKey(
                        name: "FK_Authors_AspNetUsers_application_user_id",
                        column: x => x.application_user_id,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Genres",
                schema: "dbo",
                columns: table => new
                {
                    genre_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Genres", x => x.genre_id);
                });

            migrationBuilder.CreateTable(
                name: "FollowAuthors",
                schema: "dbo",
                columns: table => new
                {
                    user_id = table.Column<string>(type: "nvarchar(450)", maxLength: 450, nullable: false),
                    author_id = table.Column<int>(type: "int", nullable: false),
                    follow_author_id = table.Column<int>(type: "int", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FollowAuthors", x => new { x.user_id, x.author_id });
                    table.ForeignKey(
                        name: "FK_FollowAuthors_AspNetUsers_user_id",
                        column: x => x.user_id,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_FollowAuthors_Authors_author_id",
                        column: x => x.author_id,
                        principalSchema: "dbo",
                        principalTable: "Authors",
                        principalColumn: "author_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Stories",
                schema: "dbo",
                columns: table => new
                {
                    story_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    author_id = table.Column<int>(type: "int", nullable: false),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    cover_image = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    primary_genre_id = table.Column<int>(type: "int", nullable: true),
                    status = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Stories", x => x.story_id);
                    table.ForeignKey(
                        name: "FK_Stories_Authors_author_id",
                        column: x => x.author_id,
                        principalSchema: "dbo",
                        principalTable: "Authors",
                        principalColumn: "author_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Stories_Genres_primary_genre_id",
                        column: x => x.primary_genre_id,
                        principalSchema: "dbo",
                        principalTable: "Genres",
                        principalColumn: "genre_id");
                });

            migrationBuilder.CreateTable(
                name: "Bookmarks",
                schema: "dbo",
                columns: table => new
                {
                    user_id = table.Column<string>(type: "nvarchar(450)", maxLength: 450, nullable: false),
                    story_id = table.Column<int>(type: "int", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Bookmarks", x => new { x.user_id, x.story_id });
                    table.ForeignKey(
                        name: "FK_Bookmarks_AspNetUsers_user_id",
                        column: x => x.user_id,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Bookmarks_Stories_story_id",
                        column: x => x.story_id,
                        principalSchema: "dbo",
                        principalTable: "Stories",
                        principalColumn: "story_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Chapters",
                schema: "dbo",
                columns: table => new
                {
                    chapter_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    story_id = table.Column<int>(type: "int", nullable: false),
                    chapter_number = table.Column<int>(type: "int", nullable: false),
                    title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Chapters", x => x.chapter_id);
                    table.ForeignKey(
                        name: "FK_Chapters_Stories_story_id",
                        column: x => x.story_id,
                        principalSchema: "dbo",
                        principalTable: "Stories",
                        principalColumn: "story_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "FollowStories",
                schema: "dbo",
                columns: table => new
                {
                    user_id = table.Column<string>(type: "nvarchar(450)", maxLength: 450, nullable: false),
                    story_id = table.Column<int>(type: "int", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FollowStories", x => new { x.user_id, x.story_id });
                    table.ForeignKey(
                        name: "FK_FollowStories_AspNetUsers_user_id",
                        column: x => x.user_id,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_FollowStories_Stories_story_id",
                        column: x => x.story_id,
                        principalSchema: "dbo",
                        principalTable: "Stories",
                        principalColumn: "story_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Ratings",
                schema: "dbo",
                columns: table => new
                {
                    rating_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<string>(type: "nvarchar(450)", maxLength: 450, nullable: false),
                    story_id = table.Column<int>(type: "int", nullable: false),
                    score = table.Column<byte>(type: "tinyint", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Ratings", x => x.rating_id);
                    table.ForeignKey(
                        name: "FK_Ratings_AspNetUsers_user_id",
                        column: x => x.user_id,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Ratings_Stories_story_id",
                        column: x => x.story_id,
                        principalSchema: "dbo",
                        principalTable: "Stories",
                        principalColumn: "story_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "StoryGenres",
                schema: "dbo",
                columns: table => new
                {
                    story_id = table.Column<int>(type: "int", nullable: false),
                    genre_id = table.Column<int>(type: "int", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StoryGenres", x => new { x.story_id, x.genre_id });
                    table.ForeignKey(
                        name: "FK_StoryGenres_Genres_genre_id",
                        column: x => x.genre_id,
                        principalSchema: "dbo",
                        principalTable: "Genres",
                        principalColumn: "genre_id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_StoryGenres_Stories_story_id",
                        column: x => x.story_id,
                        principalSchema: "dbo",
                        principalTable: "Stories",
                        principalColumn: "story_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Comments",
                schema: "dbo",
                columns: table => new
                {
                    comment_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<string>(type: "nvarchar(450)", maxLength: 450, nullable: false),
                    story_id = table.Column<int>(type: "int", nullable: true),
                    chapter_id = table.Column<int>(type: "int", nullable: true),
                    content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Comments", x => x.comment_id);
                    table.ForeignKey(
                        name: "FK_Comments_AspNetUsers_user_id",
                        column: x => x.user_id,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Comments_Chapters_chapter_id",
                        column: x => x.chapter_id,
                        principalSchema: "dbo",
                        principalTable: "Chapters",
                        principalColumn: "chapter_id");
                    table.ForeignKey(
                        name: "FK_Comments_Stories_story_id",
                        column: x => x.story_id,
                        principalSchema: "dbo",
                        principalTable: "Stories",
                        principalColumn: "story_id");
                });

            migrationBuilder.CreateTable(
                name: "ReadingHistory",
                schema: "dbo",
                columns: table => new
                {
                    history_id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    user_id = table.Column<string>(type: "nvarchar(450)", maxLength: 450, nullable: false),
                    story_id = table.Column<int>(type: "int", nullable: false),
                    last_read_chapter_id = table.Column<int>(type: "int", nullable: true),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReadingHistory", x => x.history_id);
                    table.ForeignKey(
                        name: "FK_ReadingHistory_AspNetUsers_user_id",
                        column: x => x.user_id,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ReadingHistory_Chapters_last_read_chapter_id",
                        column: x => x.last_read_chapter_id,
                        principalSchema: "dbo",
                        principalTable: "Chapters",
                        principalColumn: "chapter_id");
                    table.ForeignKey(
                        name: "FK_ReadingHistory_Stories_story_id",
                        column: x => x.story_id,
                        principalSchema: "dbo",
                        principalTable: "Stories",
                        principalColumn: "story_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Authors_application_user_id",
                schema: "dbo",
                table: "Authors",
                column: "application_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_Bookmarks_story_id",
                schema: "dbo",
                table: "Bookmarks",
                column: "story_id");

            migrationBuilder.CreateIndex(
                name: "IX_Chapters_story_id",
                schema: "dbo",
                table: "Chapters",
                column: "story_id");

            migrationBuilder.CreateIndex(
                name: "IX_Comments_chapter_id",
                schema: "dbo",
                table: "Comments",
                column: "chapter_id");

            migrationBuilder.CreateIndex(
                name: "IX_Comments_story_id",
                schema: "dbo",
                table: "Comments",
                column: "story_id");

            migrationBuilder.CreateIndex(
                name: "IX_Comments_user_id",
                schema: "dbo",
                table: "Comments",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_FollowAuthors_author_id",
                schema: "dbo",
                table: "FollowAuthors",
                column: "author_id");

            migrationBuilder.CreateIndex(
                name: "IX_FollowStories_story_id",
                schema: "dbo",
                table: "FollowStories",
                column: "story_id");

            migrationBuilder.CreateIndex(
                name: "IX_Ratings_story_id",
                schema: "dbo",
                table: "Ratings",
                column: "story_id");

            migrationBuilder.CreateIndex(
                name: "IX_Ratings_user_id",
                schema: "dbo",
                table: "Ratings",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_ReadingHistory_last_read_chapter_id",
                schema: "dbo",
                table: "ReadingHistory",
                column: "last_read_chapter_id");

            migrationBuilder.CreateIndex(
                name: "IX_ReadingHistory_story_id",
                schema: "dbo",
                table: "ReadingHistory",
                column: "story_id");

            migrationBuilder.CreateIndex(
                name: "IX_ReadingHistory_user_id",
                schema: "dbo",
                table: "ReadingHistory",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_Stories_author_id",
                schema: "dbo",
                table: "Stories",
                column: "author_id");

            migrationBuilder.CreateIndex(
                name: "IX_Stories_primary_genre_id",
                schema: "dbo",
                table: "Stories",
                column: "primary_genre_id");

            migrationBuilder.CreateIndex(
                name: "IX_StoryGenres_genre_id",
                schema: "dbo",
                table: "StoryGenres",
                column: "genre_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Bookmarks",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Comments",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "FollowAuthors",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "FollowStories",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Ratings",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "ReadingHistory",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "StoryGenres",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Chapters",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Stories",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Authors",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Genres",
                schema: "dbo");
        }
    }
}
