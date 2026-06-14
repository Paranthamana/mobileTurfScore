import 'package:equatable/equatable.dart';

abstract class ScoringEvent extends Equatable {
  const ScoringEvent();

  @override
  List<Object> get props => [];
}

class ConnectLiveScore extends ScoringEvent {
  final String matchId;
  const ConnectLiveScore(this.matchId);

  @override
  List<Object> get props => [matchId];
}

class DisconnectLiveScore extends ScoringEvent {}

class UpdateScoreEvent extends ScoringEvent {
  final int runs;
  final bool isWicket;
  final bool isWide;
  final bool isNoBall;
  final bool isLegBye;
  final bool isBye;

  const UpdateScoreEvent({
    this.runs = 0,
    this.isWicket = false,
    this.isWide = false,
    this.isNoBall = false,
    this.isLegBye = false,
    this.isBye = false,
  });

  @override
  List<Object> get props => [runs, isWicket, isWide, isNoBall, isLegBye, isBye];
}

class CreateMatchSubmitted extends ScoringEvent {
  final Map<String, dynamic> matchData;
  const CreateMatchSubmitted(this.matchData);

  @override
  List<Object> get props => [matchData];
}

class ResumeScoringRequested extends ScoringEvent {
  final int matchId;

  const ResumeScoringRequested(this.matchId);

  @override
  List<Object> get props => [matchId];
}

class UndoLastBallRequested extends ScoringEvent {
  final int matchId;

  const UndoLastBallRequested(this.matchId);

  @override
  List<Object> get props => [matchId];
}

class NewBatsmanSubmitted extends ScoringEvent {
  final int matchId;
  final String playerName;

  const NewBatsmanSubmitted({
    required this.matchId,
    required this.playerName,
  });

  @override
  List<Object> get props => [matchId, playerName];
}

class NewBowlerSubmitted extends ScoringEvent {
  final int matchId;
  final String playerName;

  const NewBowlerSubmitted({
    required this.matchId,
    required this.playerName,
  });

  @override
  List<Object> get props => [matchId, playerName];
}

class BallSubmitted extends ScoringEvent {
  final int matchId;
  final int runs;
  final bool isWicket;
  final String? extraType;
  final int extraRuns;

  const BallSubmitted({
    required this.matchId,
    required this.runs,
    required this.isWicket,
    required this.extraType,
    required this.extraRuns,
  });

  Map<String, dynamic> toBody() => {
    "match_id": matchId,
    "runs": runs,
    "is_wicket": isWicket,
    "extra_type": extraType,
    "extra_runs": extraRuns,
  };

  @override
  List<Object> get props => [
    matchId,
    runs,
    isWicket,
    extraType ?? '',
    extraRuns,
  ];
}
