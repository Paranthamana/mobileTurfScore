class DashboardLiveMatchResponse {
  bool success;
  List<LiveMatchData> data;

  DashboardLiveMatchResponse({required this.success, required this.data});

  factory DashboardLiveMatchResponse.fromJson(Map<String, dynamic> json) =>
      DashboardLiveMatchResponse(
        success: json["success"] ?? false,
        data:
            json["data"] != null
                ? List<LiveMatchData>.from(
                  json["data"].map((x) => LiveMatchData.fromJson(x)),
                )
                : [],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class LiveMatchData {
  int matchId;
  String matchName;
  int overs;
  int wickets;
  int totalRuns;
  int totalWickets;
  String currentOvers;
  String hostTeam;
  String visitorTeam;
  int? createdByUserId;

  LiveMatchData({
    required this.matchId,
    required this.matchName,
    required this.overs,
    required this.wickets,
    required this.totalRuns,
    required this.totalWickets,
    required this.currentOvers,
    required this.hostTeam,
    required this.visitorTeam,
    this.createdByUserId,
  });

  factory LiveMatchData.fromJson(Map<String, dynamic> json) => LiveMatchData(
    matchId: json["match_id"] ?? 0,

    matchName: json["match_name"] ?? '',

    overs: json["overs"] ?? 0,

    wickets: json["wickets"] ?? 0,

    totalRuns: json["total_runs"] ?? 0,

    totalWickets: json["total_wickets"] ?? 0,

    currentOvers: json["current_overs"]?.toString() ?? '0.0',

    hostTeam: json["host_team"] ?? '',

    visitorTeam: json["visitor_team"] ?? '',

    createdByUserId: _parseNullableInt(
      json["created_by_user_id"] ??
          json["created_by_id"] ??
          json["created_by"] ??
          json["user_id"] ??
          json["owner_id"],
    ),
  );

  Map<String, dynamic> toJson() => {
    "match_id": matchId,
    "match_name": matchName,
    "overs": overs,
    "wickets": wickets,
    "total_runs": totalRuns,
    "total_wickets": totalWickets,
    "current_overs": currentOvers,
    "host_team": hostTeam,
    "visitor_team": visitorTeam,
    "created_by_user_id": createdByUserId,
  };

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }
}
