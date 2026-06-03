import '../../data/models/create_match_response.dart';
import '../../data/models/live_recent_score_by_ball_response.dart';
import '../../data/models/live_score_resume_response.dart';
import '../../data/models/score_update_response.dart';

abstract class ScoringRepository {
  Future<CreateMatchResponse> createMatch(Map<String, dynamic> body);
  Future<ScoreUpdateResponse> submitBall(Map<String, dynamic> body);
  Future<LiveScoreResumeResponse> getLiveScoreResume(int matchId);
  Future<LiveRecentScoreByBallResponse> getRecentScoreByBall(int matchId);
}
