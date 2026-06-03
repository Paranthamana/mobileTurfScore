import '../../domain/repositories/scoring_repository.dart';
import '../datasources/scoring_remote_data_source.dart';
import '../models/create_match_response.dart';
import '../models/live_recent_score_by_ball_response.dart';
import '../models/live_score_resume_response.dart';
import '../models/score_update_response.dart';

class ScoringRepositoryImpl implements ScoringRepository {
  final ScoringRemoteDataSource remoteDataSource;

  ScoringRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CreateMatchResponse> createMatch(Map<String, dynamic> body) {
    return remoteDataSource.createMatch(body);
  }

  @override
  Future<ScoreUpdateResponse> submitBall(Map<String, dynamic> body) {
    return remoteDataSource.submitBall(body);
  }

  @override
  Future<LiveScoreResumeResponse> getLiveScoreResume(int matchId) {
    return remoteDataSource.getLiveScoreResume(matchId);
  }

  @override
  Future<LiveRecentScoreByBallResponse> getRecentScoreByBall(int matchId) {
    return remoteDataSource.getRecentScoreByBall(matchId);
  }
}
