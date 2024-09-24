using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace book_store_back.Migrations
{
    /// <inheritdoc />
    public partial class corrercting2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Tag",
                table: "Books");

            migrationBuilder.AddColumn<string[]>(
                name: "Tags",
                table: "Books",
                type: "text[]",
                nullable: false,
                defaultValue: new string[0]);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Tags",
                table: "Books");

            migrationBuilder.AddColumn<string>(
                name: "Tag",
                table: "Books",
                type: "text",
                nullable: false,
                defaultValue: "");
        }
    }
}
