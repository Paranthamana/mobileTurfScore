import '../../../../core/network/api_interface.dart';
import '../models/dashboard_live_match_response.dart';

abstract class DashboardRemoteDataSource {
  Future<List<LiveMatchData>> getLiveMatches();
  Future<List<CompletedMatchData>> getRecentMatches();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiInterface apiInterface;

  DashboardRemoteDataSourceImpl({required this.apiInterface});

  @override
  Future<List<LiveMatchData>> getLiveMatches() async {
    final response = await apiInterface.get(
      endpoint: '/api/dashboard/live',
    );
    if (response != null && response.statusCode == 200) {
      final model = DashboardLiveMatchResponse.fromJson(response.data);
      if (model.success) {
        return model.data;
      }
    }
    throw Exception('Failed to load live matches');
  }

  @override
  Future<List<CompletedMatchData>> getRecentMatches() async {
    final response = await apiInterface.get(
      endpoint: '/api/dashboard/recent',
    );
    if (response != null && response.statusCode == 200) {
      final model = DashboardRecentMatchResponse.fromJson(response.data);
      if (model.success) {
        return model.data;
      }
    }
    throw Exception('Failed to load completed matches');
  }
}
