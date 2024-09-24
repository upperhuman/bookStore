using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace book_store_back.Migrations
{
    /// <inheritdoc />
    public partial class renewbookController : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "review",
                table: "Books");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "review",
                table: "Books",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);
        }
    }
}
