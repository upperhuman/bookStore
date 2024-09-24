using System;

namespace book_store_back.Models
{
    public class Comment
    {
        public int Id { get; set; }
        public string UserName { get; set; }
        public DateTime Date { get; set; }
        public string Text { get; set; }
        public int BookId { get; set; }

        // Navigation properties
        public Book? Book { get; set; }
    }
}