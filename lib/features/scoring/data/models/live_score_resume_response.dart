/* class LiveScoreResumeResponse {
  final bool success;
  final String message;
  final LiveScoreResumeData data;

  LiveScoreResumeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LiveScoreResumeResponse.fromJson(Map<String, dynamic> json) =>
      LiveScoreResumeResponse(
        success: json["success"] as bool,
        message: json["message"] as String,
        data: LiveScoreResumeData.fromJson(
          Map<String, dynamic>.from(json["data"] as Map),
        ),
      );
}

class LiveScoreResumeData {
  final String matchId;
  final int inningsId;
  final int inningsNumber;
  final int totalMatchOvers;
  final int totalMatchBalls;
  final String score;
  final int totalRuns;
  final int totalWickets;
  final String overs;
  final int target;
  final String currentRunRate;
  final int requiredRunRate;
  final int runsNeeded;
  final int ballsRemaining;
  final LiveScorePlayer striker;
  final LiveScorePlayer nonStriker;
  final LiveScoreBowler bowler;
  final LiveScorePartnership partnership;
  final LiveScoreTeam battingTeam;
  final LiveScoreTeam bowlingTeam;

  LiveScoreResumeData({
    required this.matchId,
    required this.inningsId,
    required this.inningsNumber,
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
    required this.striker,
    required this.nonStriker,
    required this.bowler,
    required this.partnership,
    required this.battingTeam,
    required this.bowlingTeam,
  });

  factory LiveScoreResumeData.fromJson(Map<String, dynamic> json) =>
      LiveScoreResumeData(
        matchId: json["match_id"].toString(),
        inningsId: json["innings_id"] as int,
        inningsNumber: json["innings_number"] as int,
        totalMatchOvers: json["total_match_overs"] as int,
        totalMatchBalls: json["total_match_balls"] as int,
        score: json["score"] as String,
        totalRuns: json["total_runs"] as int,
        totalWickets: json["total_wickets"] as int,
        overs: json["overs"] as String,
        target: json["target"] as int,
        currentRunRate: json["current_run_rate"] as String,
        requiredRunRate: json["required_run_rate"] as int,
        runsNeeded: json["runs_needed"] as int,
        ballsRemaining: json["balls_remaining"] as int,
        striker: LiveScorePlayer.fromJson(
          Map<String, dynamic>.from(json["striker"] as Map),
        ),
        nonStriker: LiveScorePlayer.fromJson(
          Map<String, dynamic>.from(json["non_striker"] as Map),
        ),
        bowler: LiveScoreBowler.fromJson(
          Map<String, dynamic>.from(json["bowler"] as Map),
        ),
        partnership: LiveScorePartnership.fromJson(
          Map<String, dynamic>.from(json["partnership"] as Map),
        ),
        battingTeam: LiveScoreTeam.fromJson(
          Map<String, dynamic>.from(json["batting_team"] as Map),
        ),
        bowlingTeam: LiveScoreTeam.fromJson(
          Map<String, dynamic>.from(json["bowling_team"] as Map),
        ),
      );
}

class LiveScoreTeam {
  final int id;
  final String name;

  LiveScoreTeam({required this.id, required this.name});

  factory LiveScoreTeam.fromJson(Map<String, dynamic> json) =>
      LiveScoreTeam(id: json["id"] as int, name: json["name"] as String);
}

class LiveScoreBowler {
  final int id;
  final String name;
  final String overs;
  final int maidens;
  final int wickets;
  final int runs;
  final String economy;

  LiveScoreBowler({
    required this.id,
    required this.name,
    required this.overs,
    required this.maidens,
    required this.wickets,
    required this.runs,
    required this.economy,
  });

  factory LiveScoreBowler.fromJson(Map<String, dynamic> json) =>
      LiveScoreBowler(
        id: json["id"] as int,
        name: json["name"] as String,
        overs: json["overs"] as String,
        maidens: json["maidens"] as int,
        wickets: json["wickets"] as int,
        runs: json["runs"] as int,
        economy: json["economy"] as String,
      );
}

class LiveScorePlayer {
  final int id;
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final String strikeRate;
  final bool isCurrentStriker;

  LiveScorePlayer({
    required this.id,
    required this.name,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.isCurrentStriker,
  });

  factory LiveScorePlayer.fromJson(Map<String, dynamic> json) =>
      LiveScorePlayer(
        id: json["id"] as int,
        name: json["name"] as String,
        runs: json["runs"] as int,
        balls: json["balls"] as int,
        fours: json["fours"] as int,
        sixes: json["sixes"] as int,
        strikeRate: json["strike_rate"] as String,
        isCurrentStriker: json["is_current_striker"] as bool,
      );
}

class LiveScorePartnership {
  final int runs;
  final int balls;

  LiveScorePartnership({required this.runs, required this.balls});

  factory LiveScorePartnership.fromJson(Map<String, dynamic> json) =>
      LiveScorePartnership(
        runs: json["runs"] as int,
        balls: json["balls"] as int,
      );
}
 */

class LiveScoreResumeResponse {
  bool success;
  String message;
  Data data;

  LiveScoreResumeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LiveScoreResumeResponse.fromJson(Map<String, dynamic> json) =>
      LiveScoreResumeResponse(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );
}

class Data {
  String matchId;
  int inningsId;
  int inningsNumber;
  int totalMatchOvers;
  int totalMatchBalls;
  String score;
  int totalRuns;
  int totalWickets;
  String overs;
  int target;
  String currentRunRate;
  int requiredRunRate;
  int runsNeeded;
  int ballsRemaining;
  Striker striker;
  Striker nonStriker;
  Bowler bowler;
  Partnership partnership;
  IngTeam battingTeam;
  IngTeam bowlingTeam;

  Data({
    required this.matchId,
    required this.inningsId,
    required this.inningsNumber,
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
    required this.striker,
    required this.nonStriker,
    required this.bowler,
    required this.partnership,
    required this.battingTeam,
    required this.bowlingTeam,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    matchId: json["match_id"],
    inningsId: json["innings_id"],
    inningsNumber: json["innings_number"],
    totalMatchOvers: json["total_match_overs"],
    totalMatchBalls: json["total_match_balls"],
    score: json["score"],
    totalRuns: json["total_runs"],
    totalWickets: json["total_wickets"],
    overs: json["overs"],
    target: json["target"],
    currentRunRate: json["current_run_rate"],
    requiredRunRate: json["required_run_rate"],
    runsNeeded: json["runs_needed"],
    ballsRemaining: json["balls_remaining"],
    striker: Striker.fromJson(json["striker"]),
    nonStriker: Striker.fromJson(json["non_striker"]),
    bowler: Bowler.fromJson(json["bowler"]),
    partnership: Partnership.fromJson(json["partnership"]),
    battingTeam: IngTeam.fromJson(json["batting_team"]),
    bowlingTeam: IngTeam.fromJson(json["bowling_team"]),
  );
}

class IngTeam {
  int id;
  String name;

  IngTeam({required this.id, required this.name});

  factory IngTeam.fromJson(Map<String, dynamic> json) =>
      IngTeam(id: json["id"], name: json["name"]);
}

class Bowler {
  int id;
  String name;
  String overs;
  int maidens;
  int wickets;
  int runs;
  String economy;

  Bowler({
    required this.id,
    required this.name,
    required this.overs,
    required this.maidens,
    required this.wickets,
    required this.runs,
    required this.economy,
  });

  factory Bowler.fromJson(Map<String, dynamic> json) => Bowler(
    id: json["id"],
    name: json["name"],
    overs: json["overs"],
    maidens: json["maidens"],
    wickets: json["wickets"],
    runs: json["runs"],
    economy: json["economy"],
  );
}

class Striker {
  int id;
  String name;
  int runs;
  int balls;
  int fours;
  int sixes;
  String strikeRate;
  bool isCurrentStriker;

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

  factory Striker.fromJson(Map<String, dynamic> json) => Striker(
    id: json["id"],
    name: json["name"],
    runs: json["runs"],
    balls: json["balls"],
    fours: json["fours"],
    sixes: json["sixes"],
    strikeRate: json["strike_rate"],
    isCurrentStriker: json["is_current_striker"],
  );
}

class Partnership {
  int runs;
  int balls;

  Partnership({required this.runs, required this.balls});

  factory Partnership.fromJson(Map<String, dynamic> json) =>
      Partnership(runs: json["runs"], balls: json["balls"]);
}
