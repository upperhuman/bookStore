import 'dart:convert';

import 'package:book_store_front/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'main.dart';
import 'book_repository.dart';

class BookDetailsPage extends StatefulWidget {
  final Book book;
  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  List<Comment> comments = [];
  bool isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  String userName = currentUserNotifier.value.isAnonymous()?"Anonymous":currentUserNotifier.value.username; // Можливо, ім'я користувача буде динамічним

  @override
  void initState() {
    super.initState();
    fetchComments(); // Отримуємо коментарі при ініціалізації сторінки
  }

  // Метод для отримання коментарів з API
  Future<void> fetchComments() async {
    final url = '$HOST/api/Comments/Book/${widget.book.id}'; // Ваш ендпоінт для отримання коментарів
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> commentData = json.decode(response.body)['\$values'];
      setState(() {
        comments = commentData.map((data) => Comment.fromMap(data)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Обробляємо помилку
      print('Failed to load comments');
    }
  }

  // Метод для додавання коментаря через POST-запит
  Future<void> postComment(String text) async {
    final url = '$HOST/api/Comments'; // Ваш ендпоінт для публікації коментарів
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userName': userName,
        'text': text,
        'bookId': widget.book.id,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _commentController.clear();  // Очищаємо поле після успішного посту
      });
      fetchComments();  // Оновлюємо список коментарів
    } else {
      // Обробляємо помилку
      print('Failed to post comment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Прев'ю книги (зображення)
            widget.book.preview.isNotEmpty
                ? Image.memory(widget.book.preview, height: 250, fit: BoxFit.cover)
                : const Placeholder(fallbackHeight: 250),  // Якщо прев'ю немає

            const SizedBox(height: 20),

            // Назва книги
            Text(
              widget.book.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Автор
            Text(
              'Author: ${widget.book.author}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 10),

            // Дата публікації
            Text(
              'Published: ${DateTime.parse(widget.book.publishDate)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 10),

            // Ціна книги
            Text(
              'Price: ${widget.book.price.toStringAsFixed(2)} ₴',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Опис книги
            Text(
              widget.book.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // Теги
            if (widget.book.tags.isNotEmpty) ...[
              const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: widget.book.tags.map((tag) {
                  return Chip(
                    label: Text(tag.toString()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Секція коментарів
            const Text(
              'Comments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Виводимо коментарі
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isNotEmpty
                ? buildCommentsSection(comments)
                : const Text('No comments yet.', style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),

            // Поле для введення нового коментаря
            buildCommentInput(),
          ],
        ),
      ),
    );
  }

  // Метод для створення віджету для коментарів
  Widget buildCommentsSection(List<Comment> comments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: comments.map((comment) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  DateTime.parse(comment.date).toLocal().toString(), // Форматування дати
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(comment.text),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Віджет для вводу коментаря
  Widget buildCommentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add a comment:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your comment here...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (_commentController.text.isNotEmpty) {
              postComment(_commentController.text);
            }
          },
          child: const Text('Post Comment'),
        ),
      ],
    );
  }
}
