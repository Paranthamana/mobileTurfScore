import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_live_match_response.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<LiveMatchData>> getLiveMatches() async {
    try {
      return await remoteDataSource.getLiveMatches();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CompletedMatchData>> getRecentMatches() async {
    try {
      return await remoteDataSource.getRecentMatches();
    } catch (e) {
      rethrow;
    }
  }
}
