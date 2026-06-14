import '../../data/models/match_details_response.dart';
import '../repositories/scoring_repository.dart';

class GetMatchDetailsUseCase {
  final ScoringRepository repository;

  GetMatchDetailsUseCase(this.repository);

  Future<MatchDetailsData> call(int matchId) async {
    return await repository.getMatchDetails(matchId);
  }
}
