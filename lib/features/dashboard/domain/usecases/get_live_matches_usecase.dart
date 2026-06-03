import '../repositories/dashboard_repository.dart';
import '../../data/models/dashboard_live_match_response.dart';

class GetLiveMatchesUseCase {
  final DashboardRepository repository;

  GetLiveMatchesUseCase(this.repository);

  Future<List<LiveMatchData>> call() async {
    return await repository.getLiveMatches();
  }
}
