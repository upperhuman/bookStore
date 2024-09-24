namespace book_store_back.Models
{
    public class Rating
    {
        public int Id { get; set; }
        public int BookId { get; set; }
        public int UserId { get; set; }
        public int Score { get; set; }
        public Book Book { get; set; }
        public User User { get; set; }
    }
}