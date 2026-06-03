class ScoreUpdateResponse {
  final bool success;
  final String message;
  final Data data;

  ScoreUpdateResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ScoreUpdateResponse.fromJson(Map<String, dynamic> json) =>
      ScoreUpdateResponse(
        success: json["success"] as bool,
        message: json["message"] as String,
        data: Data.fromJson(Map<String, dynamic>.from(json["data"] as Map)),
      );
}

class Data {
  final int totalRuns;
  final int totalWickets;
  final double overs;
  final String currentRunRate;

  Data({
    required this.totalRuns,
    required this.totalWickets,
    required this.overs,
    required this.currentRunRate,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalRuns: json["total_runs"] as int,
        totalWickets: json["total_wickets"] as int,
        overs: (json["overs"] as num?)?.toDouble() ?? 0.0,
        currentRunRate: json["current_run_rate"] as String,
      );
}

