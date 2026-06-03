import '../../data/models/dashboard_live_match_response.dart';

abstract class DashboardRepository {
  Future<List<LiveMatchData>> getLiveMatches();
}
