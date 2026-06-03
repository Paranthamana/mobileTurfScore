import '../../data/models/dashboard_live_match_response.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<LiveMatchData> liveMatches;

  DashboardLoaded({required this.liveMatches});
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError({required this.message});
}
