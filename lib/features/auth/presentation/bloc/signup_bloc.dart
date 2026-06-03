import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/signup_usecase.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupUseCase signupUseCase;

  SignupBloc({required this.signupUseCase}) : super(const SignupInitial()) {
    on<SignupSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(const SignupLoading());
    try {
      final res = await signupUseCase(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      if (res.success) {
        emit(SignupSuccess(res.message));
      } else {
        emit(SignupFailure(res.message));
      }
    } catch (e) {
      emit(SignupFailure(e.toString()));
    }
  }
}

