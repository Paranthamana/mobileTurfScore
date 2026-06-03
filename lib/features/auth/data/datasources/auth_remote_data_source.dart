import '../../../../core/network/api_interface.dart';
import '../models/login_response.dart';
import '../models/signup_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login({required String email, required String password});
  Future<SignUpResponse> signup({
    required String name,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiInterface apiInterface;

  AuthRemoteDataSourceImpl({required this.apiInterface});

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await apiInterface.post(
      endpoint: '/api/auth/login',
      data: {"email": email, "password": password},
    );

    final status = response?.statusCode ?? 0;
    if (response != null && status >= 200 && status < 300) {
      return LoginResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    throw Exception('Login failed');
  }

  @override
  Future<SignUpResponse> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiInterface.post(
      endpoint: '/api/auth/signup',
      data: {"name": name, "email": email, "password": password},
    );

    final status = response?.statusCode ?? 0;
    if (response != null && status >= 200 && status < 300) {
      return SignUpResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    throw Exception('Signup failed');
  }
}
