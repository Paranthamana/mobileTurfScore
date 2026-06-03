import '../../../../core/network/api_interface.dart';
import '../models/create_match_response.dart';
import '../models/live_recent_score_by_ball_response.dart';
import '../models/live_score_resume_response.dart';
import '../models/score_update_response.dart';

abstract class ScoringRemoteDataSource {
  Future<CreateMatchResponse> createMatch(Map<String, dynamic> body);
  Future<ScoreUpdateResponse> submitBall(Map<String, dynamic> body);
  Future<LiveScoreResumeResponse> getLiveScoreResume(int matchId);
  Future<LiveRecentScoreByBallResponse> getRecentScoreByBall(int matchId);
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
}
