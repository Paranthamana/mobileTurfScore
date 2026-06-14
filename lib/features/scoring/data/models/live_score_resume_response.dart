class LiveScoreResumeResponse {
  final bool success;
  final String message;
  final Data data;

  LiveScoreResumeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LiveScoreResumeResponse.fromJson(Map<String, dynamic> json) {
    return LiveScoreResumeResponse(
      success: _parseBool(json['success']),
      message: json['message']?.toString() ?? '',
      data: Data.fromJson(Map<String, dynamic>.from(json['data'] as Map)),
    );
  }
}

class Data {
  final String matchId;
  final int inningsId;
  final int inningsNumber;
  final bool isCompleted;
  final bool isTie;
  final int winnerTeamId;
  final String winnerTeamName;
  final int totalMatchOvers;
  final int totalMatchBalls;
  final String score;
  final int totalRuns;
  final int totalWickets;
  final String overs;
  final int target;
  final String currentRunRate;
  final String requiredRunRate;
  final int runsNeeded;
  final int ballsRemaining;
  final bool awaitingNewBatsman;
  final bool awaitingNewBowler;
  final Striker striker;
  final Striker nonStriker;
  final Bowler bowler;
  final Partnership partnership;
  final IngTeam battingTeam;
  final IngTeam bowlingTeam;

  Data({
    required this.matchId,
    required this.inningsId,
    required this.inningsNumber,
    required this.isCompleted,
    required this.isTie,
    required this.winnerTeamId,
    required this.winnerTeamName,
    required this.totalMatchOvers,
    required this.totalMatchBalls,
    required this.score,
    required this.totalRuns,
    required this.totalWickets,
    required this.overs,
    required this.target,
    required this.currentRunRate,
    required this.requiredRunRate,
    required this.runsNeeded,
    required this.ballsRemaining,
    required this.awaitingNewBatsman,
    required this.awaitingNewBowler,
    required this.striker,
    required this.nonStriker,
    required this.bowler,
    required this.partnership,
    required this.battingTeam,
    required this.bowlingTeam,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      matchId: json['match_id']?.toString() ?? '',
      inningsId: _parseInt(json['innings_id']) ?? 0,
      inningsNumber: _parseInt(json['innings_number']) ?? 0,
      isCompleted: _parseBool(json['is_completed']),
      isTie: _parseBool(json['is_tie']),
      winnerTeamId: _parseInt(json['winner_team_id']) ?? 0,
      winnerTeamName: json['winner_team_name']?.toString() ?? '',
      totalMatchOvers: _parseInt(json['total_match_overs']) ?? 0,
      totalMatchBalls: _parseInt(json['total_match_balls']) ?? 0,
      score: json['score']?.toString() ?? '0/0',
      totalRuns: _parseInt(json['total_runs']) ?? 0,
      totalWickets: _parseInt(json['total_wickets']) ?? 0,
      overs: json['overs']?.toString() ?? '0.0',
      target: _parseInt(json['target']) ?? 0,
      currentRunRate: json['current_run_rate']?.toString() ?? '0.0',
      requiredRunRate: json['required_run_rate']?.toString() ?? '0.0',
      runsNeeded: _parseInt(json['runs_needed']) ?? 0,
      ballsRemaining: _parseInt(json['balls_remaining']) ?? 0,
      awaitingNewBatsman: _parseBool(json['awaiting_new_batsman']),
      awaitingNewBowler: _parseBool(json['awaiting_new_bowler']),
      striker: Striker.fromJson(Map<String, dynamic>.from(json['striker'] as Map)),
      nonStriker: Striker.fromJson(
        Map<String, dynamic>.from(json['non_striker'] as Map),
      ),
      bowler: Bowler.fromJson(Map<String, dynamic>.from(json['bowler'] as Map)),
      partnership: Partnership.fromJson(
        Map<String, dynamic>.from(json['partnership'] as Map),
      ),
      battingTeam: IngTeam.fromJson(
        Map<String, dynamic>.from(json['batting_team'] as Map),
      ),
      bowlingTeam: IngTeam.fromJson(
        Map<String, dynamic>.from(json['bowling_team'] as Map),
      ),
    );
  }
}

class IngTeam {
  final int id;
  final String name;

  IngTeam({required this.id, required this.name});

  factory IngTeam.fromJson(Map<String, dynamic> json) {
    return IngTeam(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class Bowler {
  final int id;
  final String name;
  final String overs;
  final int maidens;
  final int wickets;
  final int runs;
  final String economy;

  Bowler({
    required this.id,
    required this.name,
    required this.overs,
    required this.maidens,
    required this.wickets,
    required this.runs,
    required this.economy,
  });

  factory Bowler.fromJson(Map<String, dynamic> json) {
    return Bowler(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      overs: json['overs']?.toString() ?? '0.0',
      maidens: _parseInt(json['maidens']) ?? 0,
      wickets: _parseInt(json['wickets']) ?? 0,
      runs: _parseInt(json['runs']) ?? 0,
      economy: json['economy']?.toString() ?? '0.0',
    );
  }
}

class Striker {
  final int id;
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final String strikeRate;
  final bool isCurrentStriker;

  Striker({
    required this.id,
    required this.name,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.isCurrentStriker,
  });

  factory Striker.fromJson(Map<String, dynamic> json) {
    return Striker(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      runs: _parseInt(json['runs']) ?? 0,
      balls: _parseInt(json['balls']) ?? 0,
      fours: _parseInt(json['fours']) ?? 0,
      sixes: _parseInt(json['sixes']) ?? 0,
      strikeRate: json['strike_rate']?.toString() ?? '0.0',
      isCurrentStriker: _parseBool(json['is_current_striker']),
    );
  }
}

class Partnership {
  final int runs;
  final int balls;

  Partnership({required this.runs, required this.balls});

  factory Partnership.fromJson(Map<String, dynamic> json) {
    return Partnership(
      runs: _parseInt(json['runs']) ?? 0,
      balls: _parseInt(json['balls']) ?? 0,
    );
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  final normalized = value?.toString().toLowerCase().trim();
  return normalized == 'true' || normalized == '1';
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  final normalized = value.toString().trim();
  if (normalized.isEmpty) return null;
  return int.tryParse(normalized);
}
