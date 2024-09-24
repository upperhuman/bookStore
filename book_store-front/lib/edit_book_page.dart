import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:book_store_front/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'book_repository.dart';

class EditBookPage extends StatefulWidget {
  final void Function()? reloadBooksCallback;
  final Book? book;
  const EditBookPage(this.book, this.reloadBooksCallback, {super.key});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  final controllerTitle = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerAuthor = TextEditingController();
  final controllerPrice = TextEditingController();

  Uint8List previewBytes = Uint8List(0);
  List<String> selectedTags = [];
  final List<String> availableTags = [
    "Fantasy",
    "Science Fiction",
    "Dystopian",
    "Adventure",
    "Romance",
    "Detective",
    "Mystery",
    "Thriller",
    "Horror",
    "Historical Fiction",
    "Young Adult",
    "Children's",
    "Classic",
    "Graphic Novel",
    "Memoir",
    "Biography",
    "Self-help",
    "Non-fiction",
    "Science",
    "Philosophy",
    "Psychology",
    "Business",
    "Cooking",
    "Health",
    "True Crime",
    "Travel",
    "Religion",
    "Spirituality",
    "Humor",
    "Poetry",
    "Short Stories",
    "Drama",
    "LGBTQ+",
    "Magical Realism",
    "Steampunk",
    "Cyberpunk",
    "Western",
    "Mythology",
    "Fairy Tale",
    "War",
    "Espionage",
    "Chick Lit",
    "Historical Romance",
    "Paranormal",
    "Urban Fantasy",
    "Epic Fantasy",
    "Post-apocalyptic",
    "Space Opera",
    "Alternate History",
    "Sword and Sorcery",
    "Psychological Thriller",
    "Political Thriller",
    "Legal Thriller",
    "Medical Thriller",
    "Gothic",
    "Literary Fiction",
    "Satire",
    "Environmental",
    "Supernatural",
    "Noir",
    "Romantic Suspense",
    "Religious Fiction",
    "Inspirational",
    "Erotica",
    "Contemporary",
    "Coming of Age",
    "Survival",
    "Sports",
    "Martial Arts",
    "Crime",
    "Techno-thriller",
    "Military Fiction",
    "Alien Invasion",
    "Time Travel",
    "Dark Fantasy",
    "High Fantasy",
    "Low Fantasy",
    "Space Exploration",
    "Hard Science Fiction",
    "Soft Science Fiction",
    "Fables",
    "Folklore",
    "Sword and Planet",
    "Alien Worlds",
    "Post-modern",
    "Existential",
    "Urban Fiction",
    "Afrofuturism",
    "Biopunk",
    "Dieselpunk",
    "Heroic Fantasy",
    "Climate Fiction",
    "New Weird",
    "Slipstream",
    "Weird Fiction",
    "Action",
    "Spy",
    "Courtroom Drama",
    "Ghost Stories",
    "Gothic Romance",
    "Men's Adventure"
  ];

  @override
  void initState() {
    if (widget.book != null) {
      controllerTitle.text = widget.book!.title;
      controllerDescription.text = widget.book!.description;
      controllerAuthor.text = widget.book!.author;
      controllerPrice.text = widget.book!.price.toString();
      selectedTags = List<String>.from(widget.book!.tags);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          previewBytes = widget.book!.preview;
        });
      });
    }
    super.initState();
  }
  Future<void> uploadImage(Uint8List previewBytes, int bookId) async {
    try {
      var uri = Uri.parse('$HOST/api/books/upload/$bookId');

      var request = http.MultipartRequest('POST', uri);

      // Визначаємо MIME-тип файлу (наприклад, image/png або image/jpeg)
      var mimeType = lookupMimeType('', headerBytes: previewBytes);
      var mimeTypeData = mimeType?.split('/') ?? ['image', 'jpeg'];  // Якщо не знайдено тип, встановлюємо значення за замовчуванням

      // Додаємо зображення як файл (multipart)
      request.files.add(
        http.MultipartFile.fromBytes(
          'imageFile',  // Ключ 'imageFile' має співпадати з параметром у вашому ендпоінті
          previewBytes,
          filename: 'preview.${mimeTypeData[1]}',  // Вказуємо ім'я файлу
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),  // Визначаємо тип контенту
        ),
      );

      // Відправляємо запит
      var response = await request.send();

    } catch (e) {
      print('Error uploading image: $e');
    }
  }
  void postBook(String title, String description, String author, String price, List<String> tags) async {
    Map<String, dynamic> map = {
      "title": title,
      "description": description,
      "author": author,
      "price": double.parse(price),
      "tags": tags
    };

    var post = await http.post(Uri.parse('$HOST/api/Books'),
      body: jsonEncode(map),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    await uploadImage(previewBytes, jsonDecode(utf8.decode(post.bodyBytes))['id']);

    if (widget.reloadBooksCallback != null) {
      widget.reloadBooksCallback!();
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void editBook(String title, String description, String author, String price, List<String> tags) async {
    Map<String, dynamic> map = {
      "title": title,
      "description": description,
      "author": author,
      "price": double.parse(price),
      "tags": tags
    };

    var put = await http.put(Uri.parse('$HOST/api/Books/${widget.book!.id}'),
      body: jsonEncode(map),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    await uploadImage(previewBytes, widget.book!.id);

    if (widget.reloadBooksCallback != null) {
      widget.reloadBooksCallback!();
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    controllerTitle.dispose();
    controllerDescription.dispose();
    controllerAuthor.dispose();
    controllerPrice.dispose();
  }

  void uploadImg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        previewBytes = result.files.first.bytes!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("page.edit_book".tr()),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 400,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 50,),
                  TextFormField(
                    controller: controllerTitle,
                    decoration: InputDecoration(
                        labelText: "page.edit_book.enter.name".tr()
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'page.edit_book.enter.text'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    minLines: 3,
                    maxLines: null,
                    controller: controllerDescription,
                    decoration: InputDecoration(
                      labelText: 'page.edit_book.enter.description'.tr(),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'page.edit_book.enter.text'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: controllerAuthor,
                    decoration: InputDecoration(
                      labelText: 'page.edit_book.enter.author'.tr(),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'page.edit_book.enter.text'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10,),
                  TextFormField(
                    controller: controllerPrice,
                    decoration: InputDecoration(
                      labelText: 'page.edit_book.enter.price'.tr(),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'page.edit_book.enter.num'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10,),
                  // Dropdown for tags
                  const Text("Select tags:"),
                  const SizedBox(height: 10,),
                  Wrap(
                    children: availableTags.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FilterChip(
                          label: Text(tag),
                          selected: selectedTags.contains(tag),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedTags.add(tag);
                              } else {
                                selectedTags.remove(tag);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        height: 200,
                        child: previewBytes.isEmpty
                            ? const Center(
                          child: Text(
                            "?",
                            style: TextStyle(fontSize: 30),
                          ),
                        )
                            : Image.memory(previewBytes),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                              onPressed: uploadImg,
                              child: Row(
                                children: [
                                  const Icon(Icons.upload),
                                  const SizedBox(width: 10,),
                                  Text('page.edit_book.upload.preview'.tr())
                                ],
                              )
                          ),
                          const SizedBox(height: 20,),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  previewBytes = Uint8List(0);
                                });
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.close),
                                  const SizedBox(width: 10,),
                                  Text('page.edit_book.clear.preview'.tr())
                                ],
                              )
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  Row(
                    children: [
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final title = controllerTitle.text;
                            final description = controllerDescription.text;
                            final author = controllerAuthor.text;
                            final price = controllerPrice.text;
                            final tags = selectedTags;

                            // If book exists, edit it, otherwise post new one
                            if (widget.book != null) {
                              editBook(title, description, author, price, tags);
                            } else {
                              postBook(title, description, author, price, tags);
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: Text(
                            'submit'.tr(),
                            style: const TextStyle(
                                fontSize: 20
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
