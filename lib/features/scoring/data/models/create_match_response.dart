class CreateMatchResponse {
  final bool success;
  final String message;
  final Data data;

  CreateMatchResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateMatchResponse.fromJson(Map<String, dynamic> json) =>
      CreateMatchResponse(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  final bool success;
  final int matchId;
  final int inningsId;

  Data({
    required this.success,
    required this.matchId,
    required this.inningsId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        success: json["success"],
        matchId: json["match_id"],
        inningsId: json["innings_id"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "match_id": matchId,
        "innings_id": inningsId,
      };
}

