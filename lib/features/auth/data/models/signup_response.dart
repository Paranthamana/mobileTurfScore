class SignUpResponse {
  final bool success;
  final String message;
  final dynamic data;

  SignUpResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) => SignUpResponse(
        success: json["success"] as bool,
        message: json["message"] as String,
        data: json["data"],
      );
}

