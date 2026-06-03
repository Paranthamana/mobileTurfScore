class LoginResponse {
  final bool success;
  final String message;
  final Data data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json["success"] as bool,
        message: json["message"] as String,
        data: Data.fromJson(Map<String, dynamic>.from(json["data"] as Map)),
      );
}

class Data {
  final String token;
  final User user;

  Data({
    required this.token,
    required this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"] as String,
        user: User.fromJson(Map<String, dynamic>.from(json["user"] as Map)),
      );
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] as int,
        name: json["name"] as String,
        email: json["email"] as String,
        role: json["role"] as String,
      );
}

