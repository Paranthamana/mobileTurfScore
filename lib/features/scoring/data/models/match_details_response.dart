class MatchDetailsResponse {
  final bool success;
  final String message;
  final MatchDetailsData data;

  MatchDetailsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MatchDetailsResponse.fromJson(Map<String, dynamic> json) {
    final rawSections =
        (json['data'] as List<dynamic>? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

    return MatchDetailsResponse(
      success: _parseBool(json['success']),
      message: json['message']?.toString() ?? '',
      data: MatchDetailsData.fromSections(rawSections),
    );
  }
}

class MatchDetailsData {
  final MatchOverview overview;
  final List<TeamInfo> teams;
  final List<InningsSummary> inningsSummaries;
  final LiveSummary? liveSummary;
  final LiveBatter? striker;
  final LiveBatter? nonStriker;
  final LiveBowler? bowler;
  final List<ScorecardInnings> scorecards;
  final List<OverByBall> overs;
  final List<CommentaryItem> commentary;

  MatchDetailsData({
    required this.overview,
    required this.teams,
    required this.inningsSummaries,
    required this.liveSummary,
    required this.striker,
    required this.nonStriker,
    required this.bowler,
    required this.scorecards,
    required this.overs,
    required this.commentary,
  });

  factory MatchDetailsData.fromSections(List<Map<String, dynamic>> sections) {
    MatchOverview? overview;
    final teams = <TeamInfo>[];
    final inningsSummaries = <InningsSummary>[];
    LiveSummary? liveSummary;
    LiveBatter? striker;
    LiveBatter? nonStriker;
    LiveBowler? bowler;
    final scorecardBuilders = <int, _ScorecardBuilder>{};
    final overs = <OverByBall>[];
    final commentary = <CommentaryItem>[];

    for (final section in sections) {
      switch (section['section']?.toString()) {
        case 'match_overview':
          overview = MatchOverview.fromJson(section);
          break;
        case 'team_info':
          teams.add(TeamInfo.fromJson(section));
          break;
        case 'innings_summary':
          inningsSummaries.add(InningsSummary.fromJson(section));
          break;
        case 'live_summary':
          liveSummary = LiveSummary.fromJson(section);
          break;
        case 'live_batting':
          final batter = LiveBatter.fromJson(section);
          if (batter.role == 'striker') {
            striker = batter;
          } else if (batter.role == 'non_striker') {
            nonStriker = batter;
          }
          break;
        case 'live_bowling':
          bowler = LiveBowler.fromJson(section);
          break;
        case 'scorecard_innings':
          final scorecard = ScorecardInningsHeader.fromJson(section);
          scorecardBuilders[scorecard.inningsNumber] = _ScorecardBuilder(
            header: scorecard,
          );
          break;
        case 'scorecard_batting':
          final batting = ScorecardBattingEntry.fromJson(section);
          scorecardBuilders
              .putIfAbsent(
                batting.inningsNumber,
                () => _ScorecardBuilder(
                  header: ScorecardInningsHeader.empty(batting.inningsNumber),
                ),
              )
              .batting
              .add(batting);
          break;
        case 'scorecard_bowling':
          final bowling = ScorecardBowlingEntry.fromJson(section);
          scorecardBuilders
              .putIfAbsent(
                bowling.inningsNumber,
                () => _ScorecardBuilder(
                  header: ScorecardInningsHeader.empty(bowling.inningsNumber),
                ),
              )
              .bowling
              .add(bowling);
          break;
        case 'scorecard_fall_of_wickets':
          final fall = FallOfWicketEntry.fromJson(section);
          scorecardBuilders
              .putIfAbsent(
                fall.inningsNumber,
                () => _ScorecardBuilder(
                  header: ScorecardInningsHeader.empty(fall.inningsNumber),
                ),
              )
              .fallOfWickets
              .add(fall);
          break;
        case 'over_by_ball':
          overs.add(OverByBall.fromJson(section));
          break;
        case 'commentary':
          commentary.add(CommentaryItem.fromJson(section));
          break;
      }
    }

    commentary.sort((left, right) => right.sequence.compareTo(left.sequence));
    overs.sort((left, right) => left.overNumber.compareTo(right.overNumber));

    final scorecards =
        scorecardBuilders.values
            .map(
              (builder) => builder.build(
                teams: teams,
                inningsSummaries: inningsSummaries,
              ),
            )
            .toList()
          ..sort(
            (left, right) => left.inningsNumber.compareTo(right.inningsNumber),
          );

    return MatchDetailsData(
      overview: overview ?? MatchOverview.empty(),
      teams: teams,
      inningsSummaries: inningsSummaries,
      liveSummary: liveSummary,
      striker: striker,
      nonStriker: nonStriker,
      bowler: bowler,
      scorecards: scorecards,
      overs: overs,
      commentary: commentary,
    );
  }

  String get hostTeamName {
    final host = _teamByType('host');
    if (host != null) return host.teamName;
    return teams.isNotEmpty ? teams.first.teamName : '';
  }

  String get visitorTeamName {
    final visitor = _teamByType('visitor');
    if (visitor != null) return visitor.teamName;
    return teams.length > 1 ? teams[1].teamName : '';
  }

  String get title {
    final host = hostTeamName.trim();
    final visitor = visitorTeamName.trim();
    if (host.isEmpty && visitor.isEmpty) return 'Match Details';
    if (host.isEmpty) return visitor;
    if (visitor.isEmpty) return host;
    return '$host vs $visitor';
  }

  String get statusLabel {
    if (overview.isCompleted) return 'Completed';
    if (overview.isStarted) return 'Live';
    return 'Upcoming';
  }

  List<CommentaryItem> get highlights {
    final filtered =
        commentary
            .where(
              (item) =>
                  item.isWicket ||
                  item.runs == 4 ||
                  item.runs == 6 ||
                  item.commentaryText.toUpperCase().contains('FOUR') ||
                  item.commentaryText.toUpperCase().contains('SIX') ||
                  item.commentaryText.toUpperCase().contains('OUT'),
            )
            .toList();
    return filtered.isNotEmpty ? filtered : commentary.take(5).toList();
  }

  TeamInfo? _teamByType(String type) {
    for (final team in teams) {
      if (team.teamType.toLowerCase() == type) {
        return team;
      }
    }
    return null;
  }
}

class MatchOverview {
  final int matchId;
  final String matchName;
  final int overs;
  final int wickets;
  final bool isStarted;
  final bool isCompleted;
  final bool isSuperOver;
  final int? winnerTeamId;
  final bool isTie;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MatchOverview({
    required this.matchId,
    required this.matchName,
    required this.overs,
    required this.wickets,
    required this.isStarted,
    required this.isCompleted,
    required this.isSuperOver,
    required this.winnerTeamId,
    required this.isTie,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatchOverview.fromJson(Map<String, dynamic> json) {
    return MatchOverview(
      matchId: _parseInt(json['match_id']) ?? 0,
      matchName: json['match_name']?.toString() ?? '',
      overs: _parseInt(json['overs']) ?? 0,
      wickets: _parseInt(json['wickets']) ?? 0,
      isStarted: _parseBool(json['is_started']),
      isCompleted: _parseBool(json['is_completed']),
      isSuperOver: _parseBool(json['is_super_over']),
      winnerTeamId: _parseInt(json['winner_team_id']),
      isTie: _parseBool(json['is_tie']),
      createdBy: _parseInt(json['created_by']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  factory MatchOverview.empty() {
    return MatchOverview(
      matchId: 0,
      matchName: '',
      overs: 0,
      wickets: 0,
      isStarted: false,
      isCompleted: false,
      isSuperOver: false,
      winnerTeamId: null,
      isTie: false,
      createdBy: null,
      createdAt: null,
      updatedAt: null,
    );
  }
}

class TeamInfo {
  final int teamId;
  final String teamName;
  final String teamType;

  TeamInfo({
    required this.teamId,
    required this.teamName,
    required this.teamType,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      teamId: _parseInt(json['team_id']) ?? 0,
      teamName: json['team_name']?.toString() ?? '',
      teamType: json['team_type']?.toString() ?? '',
    );
  }
}

class InningsSummary {
  final int inningsId;
  final int inningsNumber;
  final int battingTeamId;
  final int bowlingTeamId;
  final int totalRuns;
  final int totalWickets;
  final String overs;
  final int target;
  final bool isCompleted;

  InningsSummary({
    required this.inningsId,
    required this.inningsNumber,
    required this.battingTeamId,
    required this.bowlingTeamId,
    required this.totalRuns,
    required this.totalWickets,
    required this.overs,
    required this.target,
    required this.isCompleted,
  });

  factory InningsSummary.fromJson(Map<String, dynamic> json) {
    return InningsSummary(
      inningsId: _parseInt(json['innings_id']) ?? 0,
      inningsNumber: _parseInt(json['innings_number']) ?? 0,
      battingTeamId: _parseInt(json['batting_team_id']) ?? 0,
      bowlingTeamId: _parseInt(json['bowling_team_id']) ?? 0,
      totalRuns: _parseInt(json['total_runs']) ?? 0,
      totalWickets: _parseInt(json['total_wickets']) ?? 0,
      overs: json['overs']?.toString() ?? '0.0',
      target: _parseInt(json['target']) ?? 0,
      isCompleted: _parseBool(json['is_completed']),
    );
  }
}

class LiveSummary {
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
  final String requiredRunRate;
  final int runsNeeded;
  final int ballsRemaining;
  final int battingTeamId;
  final String battingTeamName;
  final int bowlingTeamId;
  final String bowlingTeamName;
  final int partnershipRuns;
  final int partnershipBalls;

  LiveSummary({
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
    required this.battingTeamId,
    required this.battingTeamName,
    required this.bowlingTeamId,
    required this.bowlingTeamName,
    required this.partnershipRuns,
    required this.partnershipBalls,
  });

  factory LiveSummary.fromJson(Map<String, dynamic> json) {
    return LiveSummary(
      inningsId: _parseInt(json['innings_id']) ?? 0,
      inningsNumber: _parseInt(json['innings_number']) ?? 0,
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
      battingTeamId: _parseInt(json['batting_team_id']) ?? 0,
      battingTeamName: json['batting_team_name']?.toString() ?? '',
      bowlingTeamId: _parseInt(json['bowling_team_id']) ?? 0,
      bowlingTeamName: json['bowling_team_name']?.toString() ?? '',
      partnershipRuns: _parseInt(json['partnership_runs']) ?? 0,
      partnershipBalls: _parseInt(json['partnership_balls']) ?? 0,
    );
  }
}

class LiveBatter {
  final String role;
  final int playerId;
  final String playerName;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final String strikeRate;
  final bool isCurrentStriker;

  LiveBatter({
    required this.role,
    required this.playerId,
    required this.playerName,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.isCurrentStriker,
  });

  factory LiveBatter.fromJson(Map<String, dynamic> json) {
    return LiveBatter(
      role: json['role']?.toString() ?? '',
      playerId: _parseInt(json['player_id']) ?? 0,
      playerName: json['player_name']?.toString() ?? '',
      runs: _parseInt(json['runs']) ?? 0,
      balls: _parseInt(json['balls']) ?? 0,
      fours: _parseInt(json['fours']) ?? 0,
      sixes: _parseInt(json['sixes']) ?? 0,
      strikeRate: json['strike_rate']?.toString() ?? '0.0',
      isCurrentStriker: _parseBool(json['is_current_striker']),
    );
  }
}

class LiveBowler {
  final String role;
  final int playerId;
  final String playerName;
  final String overs;
  final int maidens;
  final int wickets;
  final int runs;
  final String economy;

  LiveBowler({
    required this.role,
    required this.playerId,
    required this.playerName,
    required this.overs,
    required this.maidens,
    required this.wickets,
    required this.runs,
    required this.economy,
  });

  factory LiveBowler.fromJson(Map<String, dynamic> json) {
    return LiveBowler(
      role: json['role']?.toString() ?? '',
      playerId: _parseInt(json['player_id']) ?? 0,
      playerName: json['player_name']?.toString() ?? '',
      overs: json['overs']?.toString() ?? '0.0',
      maidens: _parseInt(json['maidens']) ?? 0,
      wickets: _parseInt(json['wickets']) ?? 0,
      runs: _parseInt(json['runs']) ?? 0,
      economy: json['economy']?.toString() ?? '0.0',
    );
  }
}

class ScorecardInningsHeader {
  final int inningsNumber;
  final int totalRuns;
  final int totalWickets;
  final String overs;
  final int target;

  ScorecardInningsHeader({
    required this.inningsNumber,
    required this.totalRuns,
    required this.totalWickets,
    required this.overs,
    required this.target,
  });

  factory ScorecardInningsHeader.fromJson(Map<String, dynamic> json) {
    return ScorecardInningsHeader(
      inningsNumber: _parseInt(json['innings_number']) ?? 0,
      totalRuns: _parseInt(json['total_runs']) ?? 0,
      totalWickets: _parseInt(json['total_wickets']) ?? 0,
      overs: json['overs']?.toString() ?? '0.0',
      target: _parseInt(json['target']) ?? 0,
    );
  }

  factory ScorecardInningsHeader.empty(int inningsNumber) {
    return ScorecardInningsHeader(
      inningsNumber: inningsNumber,
      totalRuns: 0,
      totalWickets: 0,
      overs: '0.0',
      target: 0,
    );
  }
}

class ScorecardInnings {
  final int inningsNumber;
  final String title;
  final int totalRuns;
  final int totalWickets;
  final String overs;
  final int target;
  final List<ScorecardBattingEntry> batting;
  final List<ScorecardBowlingEntry> bowling;
  final List<FallOfWicketEntry> fallOfWickets;

  ScorecardInnings({
    required this.inningsNumber,
    required this.title,
    required this.totalRuns,
    required this.totalWickets,
    required this.overs,
    required this.target,
    required this.batting,
    required this.bowling,
    required this.fallOfWickets,
  });
}

class ScorecardBattingEntry {
  final int inningsNumber;
  final String playerName;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final String strikeRate;
  final bool isOut;

  ScorecardBattingEntry({
    required this.inningsNumber,
    required this.playerName,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    required this.isOut,
  });

  factory ScorecardBattingEntry.fromJson(Map<String, dynamic> json) {
    return ScorecardBattingEntry(
      inningsNumber: _parseInt(json['innings_number']) ?? 0,
      playerName: json['player_name']?.toString() ?? '',
      runs: _parseInt(json['runs']) ?? 0,
      balls: _parseInt(json['balls']) ?? 0,
      fours: _parseInt(json['fours']) ?? 0,
      sixes: _parseInt(json['sixes']) ?? 0,
      strikeRate: json['strike_rate']?.toString() ?? '0.0',
      isOut: _parseBool(json['is_out']),
    );
  }
}

class ScorecardBowlingEntry {
  final int inningsNumber;
  final String playerName;
  final String overs;
  final int runs;
  final int wickets;
  final String economy;

  ScorecardBowlingEntry({
    required this.inningsNumber,
    required this.playerName,
    required this.overs,
    required this.runs,
    required this.wickets,
    required this.economy,
  });

  factory ScorecardBowlingEntry.fromJson(Map<String, dynamic> json) {
    return ScorecardBowlingEntry(
      inningsNumber: _parseInt(json['innings_number']) ?? 0,
      playerName: json['player_name']?.toString() ?? '',
      overs: json['overs']?.toString() ?? '0.0',
      runs: _parseInt(json['runs']) ?? 0,
      wickets: _parseInt(json['wickets']) ?? 0,
      economy: json['economy']?.toString() ?? '0.0',
    );
  }
}

class FallOfWicketEntry {
  final int inningsNumber;
  final String playerName;
  final int score;
  final String overs;

  FallOfWicketEntry({
    required this.inningsNumber,
    required this.playerName,
    required this.score,
    required this.overs,
  });

  factory FallOfWicketEntry.fromJson(Map<String, dynamic> json) {
    return FallOfWicketEntry(
      inningsNumber: _parseInt(json['innings_number']) ?? 0,
      playerName: json['player_name']?.toString() ?? '',
      score: _parseInt(json['score']) ?? 0,
      overs: json['overs']?.toString() ?? '0.0',
    );
  }
}

class OverByBall {
  final int overNumber;
  final String overLabel;
  final List<String> ballValues;
  final int ballCount;

  OverByBall({
    required this.overNumber,
    required this.overLabel,
    required this.ballValues,
    required this.ballCount,
  });

  factory OverByBall.fromJson(Map<String, dynamic> json) {
    final values =
        (json['ball_values']?.toString() ?? '')
            .split(' ')
            .where((value) => value.trim().isNotEmpty)
            .toList();
    return OverByBall(
      overNumber: _parseInt(json['over_number']) ?? 0,
      overLabel: json['over_label']?.toString() ?? '',
      ballValues: values,
      ballCount: _parseInt(json['ball_count']) ?? values.length,
    );
  }
}

class CommentaryItem {
  final int sequence;
  final String over;
  final int runs;
  final bool isWicket;
  final String extraType;
  final String commentaryText;

  CommentaryItem({
    required this.sequence,
    required this.over,
    required this.runs,
    required this.isWicket,
    required this.extraType,
    required this.commentaryText,
  });

  factory CommentaryItem.fromJson(Map<String, dynamic> json) {
    return CommentaryItem(
      sequence: _parseInt(json['sequence']) ?? 0,
      over: json['over']?.toString() ?? '',
      runs: _parseInt(json['runs']) ?? 0,
      isWicket: _parseBool(json['wicket']),
      extraType: json['extra_type']?.toString() ?? '',
      commentaryText: json['commentary_text']?.toString() ?? '',
    );
  }
}

class _ScorecardBuilder {
  ScorecardInningsHeader header;
  final List<ScorecardBattingEntry> batting = [];
  final List<ScorecardBowlingEntry> bowling = [];
  final List<FallOfWicketEntry> fallOfWickets = [];

  _ScorecardBuilder({required this.header});

  ScorecardInnings build({
    required List<TeamInfo> teams,
    required List<InningsSummary> inningsSummaries,
  }) {
    final summary = inningsSummaries.where((item) {
      return item.inningsNumber == header.inningsNumber;
    }).firstWhere(
      (_) => true,
      orElse:
          () => InningsSummary(
            inningsId: 0,
            inningsNumber: header.inningsNumber,
            battingTeamId: 0,
            bowlingTeamId: 0,
            totalRuns: header.totalRuns,
            totalWickets: header.totalWickets,
            overs: header.overs,
            target: header.target,
            isCompleted: false,
          ),
    );

    String? teamName;
    for (final team in teams) {
      if (team.teamId == summary.battingTeamId) {
        teamName = team.teamName;
        break;
      }
    }

    return ScorecardInnings(
      inningsNumber: header.inningsNumber,
      title:
          teamName != null && teamName.isNotEmpty
              ? '$teamName Innings'
              : 'Innings ${header.inningsNumber}',
      totalRuns: header.totalRuns,
      totalWickets: header.totalWickets,
      overs: header.overs,
      target: header.target,
      batting: batting,
      bowling: bowling,
      fallOfWickets: fallOfWickets,
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

DateTime? _parseDate(dynamic value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
