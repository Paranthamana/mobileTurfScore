abstract class MatchDetailsEvent {}

class LoadMatchDetailsEvent extends MatchDetailsEvent {
  final int matchId;

  LoadMatchDetailsEvent({required this.matchId});
}
