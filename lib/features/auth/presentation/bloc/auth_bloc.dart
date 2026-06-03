import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/session_manager.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SessionManager sessionManager;

  AuthBloc({required this.loginUseCase, required this.sessionManager})
      : super(const AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    final token = sessionManager.token;
    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated(token: token));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await loginUseCase(email: event.email, password: event.password);
      if (response.success) {
        emit(AuthAuthenticated(token: response.data.token));
      } else {
        emit(AuthFailure(response.message));
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await sessionManager.clear();
    emit(const AuthUnauthenticated());
  }
}

