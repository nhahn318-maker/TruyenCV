using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TruyenCV.Migrations
{
    /// <inheritdoc />
    public partial class change_story : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Stories_Genres_primary_genre_id",
                schema: "dbo",
                table: "Stories");

            migrationBuilder.DropColumn(
                name: "follow_author_id",
                schema: "dbo",
                table: "FollowAuthors");

            migrationBuilder.AddColumn<string>(
                name: "Banner_image",
                schema: "dbo",
                table: "Stories",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "created_at",
                schema: "dbo",
                table: "FollowStories",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "GETUTCDATE()",
                oldClrType: typeof(DateTime),
                oldType: "datetime2");

            migrationBuilder.AlterColumn<DateTime>(
                name: "created_at",
                schema: "dbo",
                table: "FollowAuthors",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "GETUTCDATE()",
                oldClrType: typeof(DateTime),
                oldType: "datetime2");

            migrationBuilder.AddColumn<int>(
                name: "read_cont",
                schema: "dbo",
                table: "Chapters",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddForeignKey(
                name: "FK_Stories_Genres_primary_genre_id",
                schema: "dbo",
                table: "Stories",
                column: "primary_genre_id",
                principalSchema: "dbo",
                principalTable: "Genres",
                principalColumn: "genre_id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Stories_Genres_primary_genre_id",
                schema: "dbo",
                table: "Stories");

            migrationBuilder.DropColumn(
                name: "Banner_image",
                schema: "dbo",
                table: "Stories");

            migrationBuilder.DropColumn(
                name: "read_cont",
                schema: "dbo",
                table: "Chapters");

            migrationBuilder.AlterColumn<DateTime>(
                name: "created_at",
                schema: "dbo",
                table: "FollowStories",
                type: "datetime2",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "GETUTCDATE()");

            migrationBuilder.AlterColumn<DateTime>(
                name: "created_at",
                schema: "dbo",
                table: "FollowAuthors",
                type: "datetime2",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "GETUTCDATE()");

            migrationBuilder.AddColumn<int>(
                name: "follow_author_id",
                schema: "dbo",
                table: "FollowAuthors",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddForeignKey(
                name: "FK_Stories_Genres_primary_genre_id",
                schema: "dbo",
                table: "Stories",
                column: "primary_genre_id",
                principalSchema: "dbo",
                principalTable: "Genres",
                principalColumn: "genre_id");
        }
    }
}
