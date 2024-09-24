
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

class BookRepository {
  static final empty = BookRepository([]);

  final List<Book> books;

  BookRepository(this.books);
}

class Book {
  final int id;
  final String title;
  final String description;
  final String author;
  final double price;
  final List<dynamic> tags;
  final String publishDate;
  final List<Comment>? comments;
  Uint8List preview = Uint8List(0);

  Book(this.id, this.title, this.description, this.author, this.preview, this.price, this.tags, this.publishDate, this.comments);

  Book.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        description = map['description'],
        author = map['author'],
        price = map['price'],
        tags = map['tags'],
        publishDate = map['publishDate'],
        comments = map['comments']
  ;


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'price': price,
      'tags': tags,
      'publishDate': publishDate,
      'comments': comments

    };
  }
}
class Comment{
  late int bookId;
  final String userName;
  final String date;
  final String text;

  Comment(this.userName, this.date, this.text);

  Comment.fromMap(Map<String, dynamic> map)
  : userName = map['userName'],
    date = map['date'],
    text = map['text'],
    bookId = map['bookId']
  ;

  Map<String, dynamic> toMap() {
    return{
      'userName': userName,
      'date': date,
      'text': text,
      'bookId': bookId
    };
  }

}
