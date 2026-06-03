import 'package:equatable/equatable.dart';
import '../../data/models/create_match_response.dart';
import '../../data/models/score_update_response.dart';

abstract class ScoringState extends Equatable {
  const ScoringState();

  @override
  List<Object> get props => [];
}

class ScoringInitial extends ScoringState {}

class ScoringLoading extends ScoringState {}

class ScoringLoaded extends ScoringState {
  final Map<String, dynamic> matchData; // Use proper model in production

  const ScoringLoaded(this.matchData);

  @override
  List<Object> get props => [matchData];
}

class BallUpdateLoading extends ScoringState {
  final Map<String, dynamic> matchData;

  const BallUpdateLoading(this.matchData);

  @override
  List<Object> get props => [matchData];
}

class BallUpdateSuccess extends ScoringState {
  final ScoreUpdateResponse response;
  final Map<String, dynamic> matchData;

  const BallUpdateSuccess({required this.response, required this.matchData});

  @override
  List<Object> get props => [response, matchData];
}

class MatchCreatedSuccess extends ScoringState {
  final CreateMatchResponse response;
  const MatchCreatedSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class ScoringError extends ScoringState {
  final String message;
  const ScoringError(this.message);

  @override
  List<Object> get props => [message];
}
