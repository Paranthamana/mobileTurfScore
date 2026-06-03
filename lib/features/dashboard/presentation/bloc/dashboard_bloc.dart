import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../domain/usecases/get_live_matches_usecase.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetLiveMatchesUseCase getLiveMatchesUseCase;

  DashboardBloc({required this.getLiveMatchesUseCase}) : super(DashboardInitial()) {
    on<LoadLiveMatchesEvent>(_onLoadLiveMatches);
  }

  Future<void> _onLoadLiveMatches(LoadLiveMatchesEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final matches = await getLiveMatchesUseCase();
      emit(DashboardLoaded(liveMatches: matches));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
}
