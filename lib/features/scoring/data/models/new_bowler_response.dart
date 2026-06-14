class NewBowlerResponse {
  final bool success;
  final String message;
  final NewBowlerData data;

  NewBowlerResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NewBowlerResponse.fromJson(Map<String, dynamic> json) {
    return NewBowlerResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: NewBowlerData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
      ),
    );
  }
}

class NewBowlerData {
  final int matchId;
  final int inningsId;
  final int teamId;
  final int playerId;
  final String playerName;
  final String role;
  final String updatedField;

  NewBowlerData({
    required this.matchId,
    required this.inningsId,
    required this.teamId,
    required this.playerId,
    required this.playerName,
    required this.role,
    required this.updatedField,
  });

  factory NewBowlerData.fromJson(Map<String, dynamic> json) {
    return NewBowlerData(
      matchId: _parseInt(json['match_id']) ?? 0,
      inningsId: _parseInt(json['innings_id']) ?? 0,
      teamId: _parseInt(json['team_id']) ?? 0,
      playerId: _parseInt(json['player_id']) ?? 0,
      playerName: json['player_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      updatedField: json['updated_field']?.toString() ?? '',
    );
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
