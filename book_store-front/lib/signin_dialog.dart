import 'dart:convert';
import 'dart:io';

import 'package:book_store_front/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';
class SignInDialog extends StatefulWidget {
  const SignInDialog({super.key});

  @override
  State<SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  final usernameController = TextEditingController();
  final userGmailController = TextEditingController();
  final userPasswordController = TextEditingController();

  String error = "";

  void processRegister() async{
    if(usernameController.text.isEmpty){
      setState(() {
        error = "login.dialog.username.can.not.be.empty".tr();
      });
      return;
    }
    if(userGmailController.text.isEmpty){
      setState(() {
        error = "login.dialog.gmail.can.not.be.empty".tr();
      });
      return;
    }
    else if(!userGmailController.text.endsWith('@gmail.com') && !userGmailController.text.endsWith('@nmu.one')){
      setState(() {
        error = "login.dialog.gmail.not.correct".tr();
      });
      return;
    }
    if (userPasswordController.text.isEmpty){
      setState(() {
        error = "login.dialog.password.can.not.be.empty".tr();
      });
      return;
    }
    final username = usernameController.text;
    final password = userPasswordController.text;
    final gmail = userGmailController.text;
    registerUser(username, gmail, password);
    if (!mounted) return;
  }
  Future<void> registerUser(String username, String email, String password) async {
    // API URL для реєстрації
    var url = Uri.parse('${HOST}/api/Users/register'); // Замініть на ваш API URL

    // Тіло запиту
    Map<String, String> requestBody = {
      'name': username,
      'email': email,
      'password': password,
    };
    final basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    // Відправка POST-запиту
    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Вказуємо тип контенту JSON
        },
        body: jsonEncode(requestBody), // Тіло перетворюємо у формат JSON
      );

      if(response.statusCode == HttpStatus.forbidden){
        setState(() {
          error = "login.dialog.not.correct.password.or.username".tr();
        });
      }
      if (response.statusCode == 200 || response.statusCode == 201){
        String body = response.body;
        Map<String, dynamic> map = jsonDecode(body);
        UserDto userDto = UserDto.fromMap(map);
        User user = User.fromDto(userDto);
        currentUserNotifier.value = user;
        credentials = basicAuth;
        Navigator.of(context).pop();
      }
      else if (response.statusCode == 409){
        setState(() {
          error = "email.already.in.use".tr();
        });
      }
    } catch (e) {
      // Обробка помилок запиту
      print('Error during registration: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const ContinuousRectangleBorder(),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              children: [
                Text(
                  'login.dialog.page.signin'.tr(),
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: "login.dialog.username".tr()),
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: [
                    AutofillHints.username
                  ],
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: userGmailController,
                  decoration: InputDecoration(labelText: 'login.dialog.gmail'.tr()),
                  textInputAction: TextInputAction.next,
                  autofillHints: [
                    AutofillHints.email
                  ],
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: userPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'login.dialog.password'.tr()),
                  onEditingComplete: processRegister,
                  autofillHints: [
                    AutofillHints.password
                  ],
                ),
                const SizedBox(height: 20,),
                error.isNotEmpty
                    ? Text(error, style: const TextStyle(color: Colors.redAccent, fontSize: 16),)
                    : const SizedBox.shrink(),
                error.isNotEmpty
                    ? const SizedBox(height: 20,)
                    : const SizedBox.shrink(),
                TextButton(
                    onPressed: processRegister,
                    child: Text('login.dialog.signin'.tr())
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
