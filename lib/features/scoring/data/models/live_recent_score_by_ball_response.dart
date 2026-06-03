class LiveRecentScoreByBallResponse {
  final bool success;
  final String message;
  final List<Datum> data;

  LiveRecentScoreByBallResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LiveRecentScoreByBallResponse.fromJson(Map<String, dynamic> json) =>
      LiveRecentScoreByBallResponse(
        success: json["success"] as bool,
        message: json["message"] as String,
        data: List<Datum>.from(
          (json["data"] as List).map(
            (item) => Datum.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        ),
      );
}

class Datum {
  final String over;
  final int runs;
  final int wicket;
  final dynamic extraType;

  Datum({
    required this.over,
    required this.runs,
    required this.wicket,
    required this.extraType,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    over: json["over"] as String,
    runs: json["runs"] as int,
    wicket: json["wicket"] as int,
    extraType: json["extra_type"],
  );
}
