import '../repositories/dashboard_repository.dart';
import '../../data/models/dashboard_live_match_response.dart';

class GetRecentMatchesUseCase {
  final DashboardRepository repository;

  GetRecentMatchesUseCase(this.repository);

  Future<List<CompletedMatchData>> call() async {
    return await repository.getRecentMatches();
  }
}
