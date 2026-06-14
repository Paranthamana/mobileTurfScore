import '../../data/models/create_match_response.dart';
import '../../data/models/live_recent_score_by_ball_response.dart';
import '../../data/models/live_score_resume_response.dart';
import '../../data/models/match_details_response.dart';
import '../../data/models/new_batsman_response.dart';
import '../../data/models/new_bowler_response.dart';
import '../../data/models/score_update_response.dart';

abstract class ScoringRepository {
  Future<CreateMatchResponse> createMatch(Map<String, dynamic> body);
  Future<ScoreUpdateResponse> submitBall(Map<String, dynamic> body);
  Future<ScoreUpdateResponse> undoLastBall(int matchId);
  Future<NewBatsmanResponse> createNewBatsman(int matchId, String playerName);
  Future<NewBowlerResponse> createNewBowler(int matchId, String playerName);
  Future<LiveScoreResumeResponse> getLiveScoreResume(int matchId);
  Future<LiveRecentScoreByBallResponse> getRecentScoreByBall(int matchId);
  Future<MatchDetailsData> getMatchDetails(int matchId);
}
