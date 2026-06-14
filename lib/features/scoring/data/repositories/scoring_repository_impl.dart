import '../../domain/repositories/scoring_repository.dart';
import '../datasources/scoring_remote_data_source.dart';
import '../models/create_match_response.dart';
import '../models/live_recent_score_by_ball_response.dart';
import '../models/live_score_resume_response.dart';
import '../models/match_details_response.dart';
import '../models/new_batsman_response.dart';
import '../models/new_bowler_response.dart';
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
  Future<ScoreUpdateResponse> undoLastBall(int matchId) {
    return remoteDataSource.undoLastBall(matchId);
  }

  @override
  Future<NewBatsmanResponse> createNewBatsman(int matchId, String playerName) {
    return remoteDataSource.createNewBatsman(matchId, playerName);
  }

  @override
  Future<NewBowlerResponse> createNewBowler(int matchId, String playerName) {
    return remoteDataSource.createNewBowler(matchId, playerName);
  }

  @override
  Future<LiveScoreResumeResponse> getLiveScoreResume(int matchId) {
    return remoteDataSource.getLiveScoreResume(matchId);
  }

  @override
  Future<LiveRecentScoreByBallResponse> getRecentScoreByBall(int matchId) {
    return remoteDataSource.getRecentScoreByBall(matchId);
  }

  @override
  Future<MatchDetailsData> getMatchDetails(int matchId) {
    return remoteDataSource.getMatchDetails(matchId);
  }
}
