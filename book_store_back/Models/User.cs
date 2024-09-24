using System.ComponentModel.DataAnnotations;
namespace book_store_back.Models
{
    public class User
    {
        public int userId { get; set; }
        public string name { get; set; }
        public string email { get; set; } 
        public string password { get; set; }
        public string? Role { get; set; }
        public ICollection<Order>? Orders { get; set; }
        public ICollection<Rating>? Ratings { get; set; }
    }
}
