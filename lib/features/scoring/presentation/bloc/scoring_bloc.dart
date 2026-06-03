import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_service.dart';
import '../../data/models/live_recent_score_by_ball_response.dart'
    as recent_ball;
import '../../data/models/live_score_resume_response.dart';
import '../../domain/repositories/scoring_repository.dart';
import 'scoring_event.dart';
import 'scoring_state.dart';

class ScoringBloc extends Bloc<ScoringEvent, ScoringState> {
  final SocketService socketService;
  final ScoringRepository scoringRepository;

  ScoringBloc({required this.socketService, required this.scoringRepository})
    : super(ScoringInitial()) {
    on<ConnectLiveScore>(_onConnectLiveScore);
    on<DisconnectLiveScore>(_onDisconnectLiveScore);
    on<UpdateScoreEvent>(_onUpdateScore);
    on<CreateMatchSubmitted>(_onCreateMatch);
    on<ResumeScoringRequested>(_onResumeScoringRequested);
    on<BallSubmitted>(_onBallSubmitted);
  }

  void _onConnectLiveScore(ConnectLiveScore event, Emitter<ScoringState> emit) {
    emit(ScoringLoading());
    try {
      socketService.connect();
      socketService.joinRoom(event.matchId);

      emit(ScoringLoaded(_defaultMatchData()));
    } catch (e) {
      emit(ScoringError(e.toString()));
    }
  }

  void _onDisconnectLiveScore(
    DisconnectLiveScore event,
    Emitter<ScoringState> emit,
  ) {
    socketService.disconnect();
    emit(ScoringInitial());
  }

  void _onUpdateScore(UpdateScoreEvent event, Emitter<ScoringState> emit) {
    if (state is ScoringLoaded) {
      final currentState = state as ScoringLoaded;

      // Calculate new score based on event
      int newRuns = currentState.matchData['totalRuns'] + event.runs;
      int newWickets = currentState.matchData['wickets'];
      if (event.isWicket) {
        newWickets += 1;
      }
      if (event.isWide || event.isNoBall) {
        newRuns += 1; // Extra run for wide/noball
      }

      final newData = Map<String, dynamic>.from(currentState.matchData);
      newData['totalRuns'] = newRuns;
      newData['wickets'] = newWickets;

      // In real app, emit update via socket
      // socketService.socket.emit('update_score', newData);

      emit(ScoringLoaded(newData));
    }
  }

  Future<void> _onCreateMatch(
    CreateMatchSubmitted event,
    Emitter<ScoringState> emit,
  ) async {
    emit(ScoringLoading());
    try {
      final response = await scoringRepository.createMatch(event.matchData);
      if (response.success) {
        emit(MatchCreatedSuccess(response));
      } else {
        emit(ScoringError(response.message));
      }
    } catch (e) {
      emit(ScoringError(e.toString()));
    }
  }

  Future<void> _onResumeScoringRequested(
    ResumeScoringRequested event,
    Emitter<ScoringState> emit,
  ) async {
    emit(ScoringLoading());
    try {
      final liveResponse = await scoringRepository.getLiveScoreResume(
        event.matchId,
      );
      final recentResponse = await scoringRepository.getRecentScoreByBall(
        event.matchId,
      );

      if (!liveResponse.success) {
        emit(ScoringError(liveResponse.message));
        return;
      }

      if (!recentResponse.success) {
        emit(ScoringError(recentResponse.message));
        return;
      }

      emit(
        ScoringLoaded(
          _resumeMatchData(
            liveResponse: liveResponse,
            recentResponse: recentResponse,
          ),
        ),
      );
    } catch (e) {
      emit(ScoringError(e.toString()));
    }
  }

  Future<void> _onBallSubmitted(
    BallSubmitted event,
    Emitter<ScoringState> emit,
  ) async {
    final currentData = _currentMatchData(state);

    final optimistic = Map<String, dynamic>.from(currentData);
    final over = List<String>.from(
      optimistic['thisOver'] as List? ?? const <String>[],
    );
    over.add(_ballDisplay(event));
    if (over.length > 6) {
      over.removeRange(0, over.length - 6);
    }
    optimistic['thisOver'] = over;

    if (!event.isWicket && event.extraType == null && (event.runs % 2 == 1)) {
      _swapBatters(optimistic);
    }

    emit(BallUpdateLoading(optimistic));
    try {
      final response = await scoringRepository.submitBall(event.toBody());
      if (response.success) {
        final nextData = Map<String, dynamic>.from(optimistic);
        nextData['totalRuns'] = response.data.totalRuns;
        nextData['wickets'] = response.data.totalWickets;
        nextData['overs'] = _oversToDisplay(response.data.overs);
        nextData['currentRunRate'] = response.data.currentRunRate;
        emit(BallUpdateSuccess(response: response, matchData: nextData));
      } else {
        emit(ScoringError(response.message));
      }
    } catch (e) {
      emit(ScoringError(e.toString()));
    }
  }

  String _ballDisplay(BallSubmitted event) {
    if (event.isWicket) return 'W';
    if (event.extraType == 'wide') return 'Wd';
    if (event.extraType == 'no_ball') return 'Nb';
    if (event.extraType == 'bye') return 'B';
    if (event.extraType == 'leg_bye') return 'Lb';
    return event.runs.toString();
  }

  Map<String, dynamic> _currentMatchData(ScoringState currentState) {
    if (currentState is BallUpdateSuccess) return currentState.matchData;
    if (currentState is BallUpdateLoading) return currentState.matchData;
    if (currentState is ScoringLoaded) return currentState.matchData;
    return _defaultMatchData();
  }

  Map<String, dynamic> _defaultMatchData() {
    return {
      "battingTeamName": "-",
      "bowlingTeamName": "-",
      "inningsNumber": 1,
      "totalRuns": 0,
      "wickets": 0,
      "overs": "0.0",
      "currentRunRate": "0.0",
      "target": 0,
      "requiredRunRate": "0",
      "partnershipRuns": 0,
      "partnershipBalls": 0,
      "runsNeeded": 0,
      "ballsRemaining": 0,
      "thisOver": <String>[],
      "strikerName": "-",
      "strikerRuns": 0,
      "strikerBalls": 0,
      "strikerFours": 0,
      "strikerSixes": 0,
      "strikerStrikeRate": "0.0",
      "strikerIsCurrent": true,
      "nonStrikerName": "-",
      "nonStrikerRuns": 0,
      "nonStrikerBalls": 0,
      "nonStrikerFours": 0,
      "nonStrikerSixes": 0,
      "nonStrikerStrikeRate": "0.0",
      "nonStrikerIsCurrent": false,
      "bowlerName": "-",
      "bowlerOvers": "0.0",
      "bowlerMaidens": 0,
      "bowlerRuns": 0,
      "bowlerWickets": 0,
      "bowlerEconomy": "0.0",
    };
  }

  Map<String, dynamic> _resumeMatchData({
    required LiveScoreResumeResponse liveResponse,
    required recent_ball.LiveRecentScoreByBallResponse recentResponse,
  }) {
    final data = liveResponse.data;
    return {
      "battingTeamName": data.battingTeam.name,
      "bowlingTeamName": data.bowlingTeam.name,
      "inningsNumber": data.inningsNumber,
      "totalRuns": data.totalRuns,
      "wickets": data.totalWickets,
      "overs": data.overs,
      "currentRunRate": data.currentRunRate,
      "target": data.target,
      "requiredRunRate": data.requiredRunRate.toString(),
      "partnershipRuns": data.partnership.runs,
      "partnershipBalls": data.partnership.balls,
      "runsNeeded": data.runsNeeded,
      "ballsRemaining": data.ballsRemaining,
      "thisOver": _recentBallsForCurrentOver(recentResponse.data),
      "strikerName": data.striker.name,
      "strikerRuns": data.striker.runs,
      "strikerBalls": data.striker.balls,
      "strikerFours": data.striker.fours,
      "strikerSixes": data.striker.sixes,
      "strikerStrikeRate": data.striker.strikeRate,
      "strikerIsCurrent": data.striker.isCurrentStriker,
      "nonStrikerName": data.nonStriker.name,
      "nonStrikerRuns": data.nonStriker.runs,
      "nonStrikerBalls": data.nonStriker.balls,
      "nonStrikerFours": data.nonStriker.fours,
      "nonStrikerSixes": data.nonStriker.sixes,
      "nonStrikerStrikeRate": data.nonStriker.strikeRate,
      "nonStrikerIsCurrent": data.nonStriker.isCurrentStriker,
      "bowlerName": data.bowler.name,
      "bowlerOvers": data.bowler.overs,
      "bowlerMaidens": data.bowler.maidens,
      "bowlerRuns": data.bowler.runs,
      "bowlerWickets": data.bowler.wickets,
      "bowlerEconomy": data.bowler.economy,
    };
  }

  List<String> _recentBallsForCurrentOver(List<recent_ball.Datum> recentBalls) {
    if (recentBalls.isEmpty) return <String>[];

    final latestOver = recentBalls
        .map((ball) => int.tryParse(ball.over.split('.').first) ?? 0)
        .fold<int>(0, (maxValue, value) => value > maxValue ? value : maxValue);
    final ballsInCurrentOver =
        recentBalls
            .where(
              (ball) =>
                  (int.tryParse(ball.over.split('.').first) ?? 0) == latestOver,
            )
            .toList();
    ballsInCurrentOver.sort(
      (left, right) =>
          _overBallIndex(left.over).compareTo(_overBallIndex(right.over)),
    );

    final trimmed =
        ballsInCurrentOver.length > 6
            ? ballsInCurrentOver.sublist(ballsInCurrentOver.length - 6)
            : ballsInCurrentOver;

    return trimmed.map(_recentBallDisplay).toList();
  }

  String _recentBallDisplay(recent_ball.Datum ball) {
    if (ball.wicket == 1) return 'W';
    return ball.runs.toString();
  }

  String _oversToDisplay(double overs) {
    if (overs == overs.truncateToDouble()) {
      return overs.toStringAsFixed(1);
    }
    return overs.toString();
  }

  int _overBallIndex(String over) {
    final parts = over.split('.');
    final overNumber = int.tryParse(parts.first) ?? 0;
    final ballNumber = parts.length > 1 ? int.tryParse(parts.last) ?? 0 : 0;
    return (overNumber * 10) + ballNumber;
  }

  void _swapBatters(Map<String, dynamic> matchData) {
    const strikerKeys = <String>[
      'strikerName',
      'strikerRuns',
      'strikerBalls',
      'strikerFours',
      'strikerSixes',
      'strikerStrikeRate',
      'strikerIsCurrent',
    ];
    const nonStrikerKeys = <String>[
      'nonStrikerName',
      'nonStrikerRuns',
      'nonStrikerBalls',
      'nonStrikerFours',
      'nonStrikerSixes',
      'nonStrikerStrikeRate',
      'nonStrikerIsCurrent',
    ];

    final strikerValues = strikerKeys.map((key) => matchData[key]).toList();
    final nonStrikerValues =
        nonStrikerKeys.map((key) => matchData[key]).toList();

    for (var index = 0; index < strikerKeys.length; index++) {
      matchData[strikerKeys[index]] = nonStrikerValues[index];
      matchData[nonStrikerKeys[index]] = strikerValues[index];
    }
  }
}
