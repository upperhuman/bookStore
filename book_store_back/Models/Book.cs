namespace book_store_back.Models
{
    public class Book
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Author { get; set; }
        public double Price { get; set; }
        public string? ImageUrl { get; set; }
        public string Description { get; set; }
        public string[] Tags { get; set; }
        public DateTime PublishDate { get; set; }
        public double UserRating
        {
            get
            {
                if (Ratings == null || Ratings.Count == 0) return 0;
                return Ratings.Average(r => r.Score);
            }
        }
        public ICollection<Rating>? Ratings { get; set; }
        public ICollection<Comment>? Comments { get; set; }

    }
}