import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/dio_client.dart';
import 'core/network/socket_service.dart';
import 'core/network/api_interface.dart';
import 'core/storage/session_manager.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/signup_bloc.dart';
import 'features/scoring/presentation/bloc/scoring_bloc.dart';
import 'features/scoring/data/datasources/scoring_remote_data_source.dart';
import 'features/scoring/data/repositories/scoring_repository_impl.dart';
import 'features/scoring/domain/repositories/scoring_repository.dart';
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_live_matches_usecase.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();

  // Core
  sl.registerLazySingleton(() => prefs);
  sl.registerLazySingleton(() => SessionManager(prefs: sl()));
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton(() => SocketService());
  sl.registerLazySingleton(() => ApiInterface(sessionManager: sl()));

  // Auth Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiInterface: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), sessionManager: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));

  // Dashboard Feature
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiInterface: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetLiveMatchesUseCase(sl()));

  // Scoring Feature
  sl.registerLazySingleton<ScoringRemoteDataSource>(
    () => ScoringRemoteDataSourceImpl(apiInterface: sl()),
  );
  sl.registerLazySingleton<ScoringRepository>(
    () => ScoringRepositoryImpl(remoteDataSource: sl()),
  );

  // Blocs
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), sessionManager: sl()));
  sl.registerFactory(() => SignupBloc(signupUseCase: sl()));
  sl.registerFactory(
    () => ScoringBloc(socketService: sl(), scoringRepository: sl()),
  );
  sl.registerFactory(() => DashboardBloc(getLiveMatchesUseCase: sl()));
}
