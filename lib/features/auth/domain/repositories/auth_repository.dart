import '../../data/models/login_response.dart';
import '../../data/models/signup_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login({required String email, required String password});
  Future<SignUpResponse> signup({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
}
