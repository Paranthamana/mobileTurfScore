import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../domain/usecases/get_live_matches_usecase.dart';
import '../../domain/usecases/get_recent_matches_usecase.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetLiveMatchesUseCase getLiveMatchesUseCase;
  final GetRecentMatchesUseCase getRecentMatchesUseCase;

  DashboardBloc({
    required this.getLiveMatchesUseCase,
    required this.getRecentMatchesUseCase,
  }) : super(DashboardInitial()) {
    on<LoadLiveMatchesEvent>(_onLoadLiveMatches);
  }

  Future<void> _onLoadLiveMatches(LoadLiveMatchesEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final matches = await getLiveMatchesUseCase();
      final recentMatches = await getRecentMatchesUseCase();
      emit(
        DashboardLoaded(
          liveMatches: matches,
          recentMatches: recentMatches,
        ),
      );
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
}
