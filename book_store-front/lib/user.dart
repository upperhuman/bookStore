import 'dart:convert';

class User {
  static final User anonymous = User(null, "", "");
  final int? id;
  final String username;
  final String role;

  User(this.id, this.username, this.role);

  bool isAnonymous(){
    return this == User.anonymous;
  }

  bool isAuthorized() {
    return !isAnonymous();
  }

  bool isAdmin(){
    return role == 'admin';
  }
  bool isUser(){
    return role == 'user';
  }
  isAuthor(){
    return role == 'author';
  }

  UserDto toDto() {
    return UserDto.fromUser(this);
  }

  User.fromDto(UserDto dto)
    : id = dto.id,
      username = dto.username,
      role = dto.role;


  User.fromMap(Map<String, dynamic> map)
      : username = map['name'],
        role = map['role'],
        id = map['userId'];

  User.fromJsonString(String jsonString)
      : this.fromMap(jsonDecode(jsonString));

  Map<String, dynamic> toMap() {
    return {
      'name': username,
      'roles': role
    };
  }

  String toJsonString([JsonEncoder? encoder]) {
    return (encoder ?? JsonEncoder.withIndent('  ')).convert(toMap());
  }
}

class UserDto {
  final int? id;
  final String username;
  final String role;

  UserDto(this.username, this.role, this.id);

  UserDto.fromUser(User user)
      : username = user.username,
        role = user.role,
        id = user.id;

  UserDto.fromMap(Map<String, dynamic> map)
      : username = map['name'],
        role = map['role'],
        id = map['userId'];

  Map<String, dynamic> toMap() {
    return {
      'userId': id,
      'username': username,
      'roles': role
    };
  }

  String toJsonString([JsonEncoder? encoder]) {
    return (encoder ?? JsonEncoder.withIndent('  ')).convert(toMap());
  }
}