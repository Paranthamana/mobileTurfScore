import '../../../../core/storage/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_response.dart';
import '../models/signup_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SessionManager sessionManager;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sessionManager,
  });

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(email: email, password: password);
    if (response.success) {
      await sessionManager.saveToken(response.data.token);
      await sessionManager.saveUserId(response.data.user.id);
    }
    return response;
  }

  @override
  Future<SignUpResponse> signup({
    required String name,
    required String email,
    required String password,
  }) {
    return remoteDataSource.signup(name: name, email: email, password: password);
  }

  @override
  Future<void> logout() async {
    await sessionManager.clear();
  }
}
