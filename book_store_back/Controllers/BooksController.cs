using book_store_back.Data;
using book_store_back.Models;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.IO;
using System.Threading.Tasks;

namespace book_store_back.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BooksController : ControllerBase
    {
        private readonly BookStoreContext _context;
        private readonly IWebHostEnvironment _environment;

        public BooksController(BookStoreContext context, IWebHostEnvironment environment)
        {
            _context = context;
            _environment = environment;
        }

        // POST: api/Books/upload/{bookId}
        [HttpPost("upload/{bookId}")]
        public async Task<IActionResult> UploadBookImage(int bookId, IFormFile imageFile)
        {
            // Перевіряємо, чи існує книга
            var book = await _context.Books.FindAsync(bookId);
            if (book == null)
            {
                return NotFound("Книга не знайдена");
            }

            // Перевіряємо, чи файл зображення був завантажений
            if (imageFile == null || imageFile.Length == 0)
            {
                return BadRequest("Зображення не завантажено");
            }

            // Створюємо ім'я файлу
            var fileName = $"{Guid.NewGuid()}_{imageFile.FileName}";

            // Створюємо шлях для збереження зображення
            var folderPath = Path.Combine("wwwroot", "images", "books");

            // Рекурсивно створюємо директорії, якщо їх немає
            if (!Directory.Exists(folderPath))
            {
                Directory.CreateDirectory(folderPath); // створює директорії рекурсивно
            }

            var filePath = Path.Combine(folderPath, fileName);

            // Зберігаємо зображення у файлову систему
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await imageFile.CopyToAsync(stream);
            }

            // Оновлюємо поле ImageUrl для книги
            book.ImageUrl = $"/images/books/{fileName}";
            _context.Entry(book).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(new { imageUrl = book.ImageUrl });
        }

        // GET: api/Books/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Book>> GetBook(int id)
        {
            var book = await _context.Books.FindAsync(id);

            if (book == null)
            {
                return NotFound();
            }

            return book;
        }

        // GET: api/Books/image/{imageName}
        [HttpGet("{id}/image")]
        public IActionResult GetBookImage(int id)
        {
            // Знаходимо книгу по її id
            var book = _context.Books.Find(id);
            if (book == null)
            {
                return NotFound("Книга не знайдена");
            }

            // Перевіряємо, чи існує шлях до зображення
            if (string.IsNullOrEmpty(book.ImageUrl))
            {
                return NotFound("Зображення не знайдено для цієї книги");
            }

            // Створюємо фізичний шлях до файлу на сервері
            var imagePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", book.ImageUrl.TrimStart('/'));

            // Перевіряємо, чи файл існує за цим шляхом
            if (!System.IO.File.Exists(imagePath))
            {
                return NotFound("Файл зображення не знайдено");
            }

            // Визначаємо тип контенту для зображення
            var imageFileStream = new FileStream(imagePath, FileMode.Open, FileAccess.Read);
            string mimeType = GetMimeType(imagePath);

            // Повертаємо файл з зображенням
            return File(imageFileStream, mimeType);
        }

        // Допоміжний метод для отримання Mime-типу файлу на основі його розширення
        private string GetMimeType(string path)
        {
            var extension = Path.GetExtension(path).ToLowerInvariant();
            return extension switch
            {
                ".jpg" => "image/jpeg",
                ".jpeg" => "image/jpeg",
                ".png" => "image/png",
                ".gif" => "image/gif",
                ".bmp" => "image/bmp",
                _ => "application/octet-stream",
            };
        }
        [HttpGet("allBooks")]
        public async Task<ActionResult<IEnumerable<Book>>> GetBooks()
        {
            return await _context.Books.ToListAsync();
        }
        // PUT: api/Books/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutBook(int id, [FromBody] UpdateBookDto bookDto)
        {
            // Знаходимо книгу за її ідентифікатором
            var book = await _context.Books.FindAsync(id);
            if (book == null)
            {
                return NotFound();
            }

            // Оновлюємо тільки необхідні поля
            book.Title = bookDto.Title;
            book.Description = bookDto.Description;
            book.Author = bookDto.Author;
            book.Price = bookDto.Price;
            book.Tags = bookDto.Tags;

            // Оновлюємо статус
            _context.Entry(book).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!BookExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/Books
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<Book>> PostBook(Book book)
        {
            book.PublishDate = DateTime.UtcNow;
            _context.Books.Add(book);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetBook", new { id = book.Id }, book);
        }

        // DELETE: api/Books/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteBook(int id)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
            {
                return NotFound();
            }

            _context.Books.Remove(book);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool BookExists(int id)
        {
            return _context.Books.Any(e => e.Id == id);
        }
        public class UpdateBookDto
        {
            public string Title { get; set; }
            public string Description { get; set; }
            public string Author { get; set; }
            public double Price { get; set; }
            public string[] Tags { get; set; }
        }
    }
}

