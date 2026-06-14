class NewBatsmanResponse {
  final bool success;
  final String message;
  final NewBatsmanData data;

  NewBatsmanResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NewBatsmanResponse.fromJson(Map<String, dynamic> json) {
    return NewBatsmanResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: NewBatsmanData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
      ),
    );
  }
}

class NewBatsmanData {
  final int matchId;
  final int inningsId;
  final int teamId;
  final int playerId;
  final String playerName;
  final String role;
  final String updatedField;

  NewBatsmanData({
    required this.matchId,
    required this.inningsId,
    required this.teamId,
    required this.playerId,
    required this.playerName,
    required this.role,
    required this.updatedField,
  });

  factory NewBatsmanData.fromJson(Map<String, dynamic> json) {
    return NewBatsmanData(
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
