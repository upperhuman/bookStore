using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using book_store_back.Data;
using book_store_back.Models;

namespace book_store_back.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OrdersController : ControllerBase
    {
        private readonly BookStoreContext _context;

        public OrdersController(BookStoreContext context)
        {
            _context = context;
        }

        // GET: api/Orders
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Order>>> GetOrders()
        {
            return await _context.Orders.ToListAsync();
        }

        // GET: api/Orders/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Order>> GetOrder(int id)
        {
            var order = await _context.Orders.FindAsync(id);

            if (order == null)
            {
                return NotFound();
            }

            return order;
        }

        // PUT: api/Orders/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutOrder(int id, Order order)
        {
            if (id != order.Id)
            {
                return BadRequest();
            }

            _context.Entry(order).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!OrderExists(id))
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

        // POST: api/Orders
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<Order>> PostOrder([FromBody] OrderRequest orderRequest)
        {
            // Перевіряємо чи існує користувач
            var user = await _context.Users.FindAsync(orderRequest.UserId);
            if (user == null)
            {
                return NotFound($"User with ID {orderRequest.UserId} not found.");
            }

            // Створюємо нове замовлення
            var order = new Order
            {
                UserId = orderRequest.UserId,
                OrderDate = DateTime.Now.ToUniversalTime(),
                TotalPrice = 0, // Початково, потім перерахуємо
                OrderItems = new List<OrderItem>()
            };

            // Обробляємо кожну книгу з списку
            foreach (var item in orderRequest.BookOrders)
            {
                var book = await _context.Books.FindAsync(item.BookId);
                if (book == null)
                {
                    return NotFound($"Book with ID {item.BookId} not found.");
                }

                // Створюємо елемент замовлення
                var orderItem = new OrderItem
                {
                    BookId = book.Id,
                    Quantity = item.Quantity,
                    Price = (decimal)book.Price * item.Quantity,
                    Order = order
                };

                // Додаємо елемент у замовлення
                order.OrderItems.Add(orderItem);
                order.TotalPrice += orderItem.Price; // Оновлюємо загальну вартість
            }

            // Додаємо замовлення до бази даних
            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetOrder", new { id = order.Id }, order);
        }

        // DELETE: api/Orders/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteOrder(int id)
        {
            var order = await _context.Orders.FindAsync(id);
            if (order == null)
            {
                return NotFound();
            }

            _context.Orders.Remove(order);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        [HttpGet("user/{userId}")]
        public async Task<ActionResult<IEnumerable<Order>>> GetOrdersByUserId(int userId)
        {
            // Отримуємо всі ордери для даного userId
            var orders = await _context.Orders
                .Where(o => o.UserId == userId)
                .ToListAsync();

            // Перевіряємо, чи є ордери для користувача
            if (orders == null || !orders.Any())
            {
                return NotFound(new { message = "Orders not found for this user." });
            }

            // Повертаємо список ордерів
            return Ok(orders);
        }
        private bool OrderExists(int id)
        {
            return _context.Orders.Any(e => e.Id == id);
        }
        public class OrderRequest
        {
            public int UserId { get; set; }
            public List<BookOrder> BookOrders { get; set; }
        }

        public class BookOrder
        {
            public int BookId { get; set; }
            public int Quantity { get; set; }
        }
    }
}
