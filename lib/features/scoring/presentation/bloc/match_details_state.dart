import '../../data/models/match_details_response.dart';

abstract class MatchDetailsState {}

class MatchDetailsInitial extends MatchDetailsState {}

class MatchDetailsLoading extends MatchDetailsState {}

class MatchDetailsLoaded extends MatchDetailsState {
  final MatchDetailsData matchDetails;

  MatchDetailsLoaded({required this.matchDetails});
}

class MatchDetailsError extends MatchDetailsState {
  final String message;

  MatchDetailsError({required this.message});
}
