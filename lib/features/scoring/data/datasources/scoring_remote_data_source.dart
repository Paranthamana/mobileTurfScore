import '../../../../core/network/api_interface.dart';
import '../models/create_match_response.dart';
import '../models/live_recent_score_by_ball_response.dart';
import '../models/live_score_resume_response.dart';
import '../models/match_details_response.dart';
import '../models/new_batsman_response.dart';
import '../models/new_bowler_response.dart';
import '../models/score_update_response.dart';

abstract class ScoringRemoteDataSource {
  Future<CreateMatchResponse> createMatch(Map<String, dynamic> body);
  Future<ScoreUpdateResponse> submitBall(Map<String, dynamic> body);
  Future<ScoreUpdateResponse> undoLastBall(int matchId);
  Future<NewBatsmanResponse> createNewBatsman(int matchId, String playerName);
  Future<NewBowlerResponse> createNewBowler(int matchId, String playerName);
  Future<LiveScoreResumeResponse> getLiveScoreResume(int matchId);
  Future<LiveRecentScoreByBallResponse> getRecentScoreByBall(int matchId);
  Future<MatchDetailsData> getMatchDetails(int matchId);
}

class ScoringRemoteDataSourceImpl implements ScoringRemoteDataSource {
  final ApiInterface apiInterface;

  ScoringRemoteDataSourceImpl({required this.apiInterface});

  @override
  Future<CreateMatchResponse> createMatch(Map<String, dynamic> body) async {
    final response = await apiInterface.post(
      endpoint: '/api/matches',
      data: body,
    );

    final status = response?.statusCode ?? 0;
    if (response != null && status >= 200 && status < 300) {
      return CreateMatchResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    throw Exception('Failed to create match');
  }

  @override
  Future<ScoreUpdateResponse> submitBall(Map<String, dynamic> body) async {
    final response = await apiInterface.post(
      endpoint: '/api/scoring/ball',
      data: body,
    );

    final status = response?.statusCode ?? 0;
    if (response != null && status >= 200 && status < 300) {
      return ScoreUpdateResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    throw Exception('Failed to update score');
  }

  @override
  Future<ScoreUpdateResponse> undoLastBall(int matchId) async {
    final response = await apiInterface.post(
      endpoint: '/api/scoring/undo/$matchId',
    );

    final status = response?.statusCode ?? 0;
    if (response != null && status >= 200 && status < 300) {
      return ScoreUpdateResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    throw Exception('Failed to undo last ball');
  }

  @override
  Future<NewBatsmanResponse> createNewBatsman(
    int matchId,
    String playerName,
  ) async {
    final response = await apiInterface.post(
      endpoint: '/api/scoring/new-batsman',
      data: {"match_id": matchId, "player_name": playerName},
    );

    final status = response?.statusCode ?? 0;
    if (response != null && status >= 200 && status < 300) {
      return NewBatsmanResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    throw Exception('Failed to create new batsman');
  }

  @override
  Future<NewBowlerResponse> createNewBowler(
    int matchId,
    String playerName,
  ) async {
    final response = await apiInterface.post(
      endpoint: '/api/scoring/new-bowler',
      data: {"match_id": matchId, "player_name": playerName},
    );

    final status = response?.statusCode ?? 0;
    if (response != null && status >= 200 && status < 300) {
      return NewBowlerResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    throw Exception('Failed to create new bowler');
  }

  @override
  Future<LiveScoreResumeResponse> getLiveScoreResume(int matchId) async {
    final response = await apiInterface.get(
      endpoint: 'http://192.168.0.109:5000/api/scoring/live/$matchId',
    );

    final status = response?.statusCode ?? 0;
    if (response != null && status >= 200 && status < 300) {
      return LiveScoreResumeResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    throw Exception('Failed to load live score');
  }

  @override
  Future<LiveRecentScoreByBallResponse> getRecentScoreByBall(
    int matchId,
  ) async {
    final response = await apiInterface.get(
      endpoint: 'http://192.168.0.109:5000/api/scoring/recent/$matchId',
    );

    final status = response?.statusCode ?? 0;
    if (response != null && status >= 200 && status < 300) {
      return LiveRecentScoreByBallResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    throw Exception('Failed to load recent balls');
  }

  @override
  Future<MatchDetailsData> getMatchDetails(int matchId) async {
    final response = await apiInterface.get(
      endpoint: '/api/match-details/$matchId',
    );

    final status = response?.statusCode ?? 0;
    if (response != null && status >= 200 && status < 300) {
      final model = MatchDetailsResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      if (model.success) {
        return model.data;
      }
    }

    throw Exception('Failed to load match details');
  }
}
