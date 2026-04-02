using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TruyenCV.Migrations
{
    /// <inheritdoc />
    public partial class AddAuthorApprovalFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "approved_at",
                schema: "dbo",
                table: "Authors",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "approved_by",
                schema: "dbo",
                table: "Authors",
                type: "nvarchar(450)",
                maxLength: 450,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "status",
                schema: "dbo",
                table: "Authors",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateIndex(
                name: "IX_Authors_approved_by",
                schema: "dbo",
                table: "Authors",
                column: "approved_by");

            migrationBuilder.AddForeignKey(
                name: "FK_Authors_AspNetUsers_approved_by",
                schema: "dbo",
                table: "Authors",
                column: "approved_by",
                principalTable: "AspNetUsers",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Authors_AspNetUsers_approved_by",
                schema: "dbo",
                table: "Authors");

            migrationBuilder.DropIndex(
                name: "IX_Authors_approved_by",
                schema: "dbo",
                table: "Authors");

            migrationBuilder.DropColumn(
                name: "approved_at",
                schema: "dbo",
                table: "Authors");

            migrationBuilder.DropColumn(
                name: "approved_by",
                schema: "dbo",
                table: "Authors");

            migrationBuilder.DropColumn(
                name: "status",
                schema: "dbo",
                table: "Authors");
        }
    }
}
