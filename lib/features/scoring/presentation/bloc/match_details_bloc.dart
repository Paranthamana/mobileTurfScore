import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_match_details_usecase.dart';
import 'match_details_event.dart';
import 'match_details_state.dart';

class MatchDetailsBloc extends Bloc<MatchDetailsEvent, MatchDetailsState> {
  final GetMatchDetailsUseCase getMatchDetailsUseCase;

  MatchDetailsBloc({required this.getMatchDetailsUseCase})
    : super(MatchDetailsInitial()) {
    on<LoadMatchDetailsEvent>(_onLoadMatchDetails);
  }

  Future<void> _onLoadMatchDetails(
    LoadMatchDetailsEvent event,
    Emitter<MatchDetailsState> emit,
  ) async {
    if (state is! MatchDetailsLoaded) {
      emit(MatchDetailsLoading());
    }
    try {
      final matchDetails = await getMatchDetailsUseCase(event.matchId);
      emit(MatchDetailsLoaded(matchDetails: matchDetails));
    } catch (e) {
      emit(MatchDetailsError(message: e.toString()));
    }
  }
}
