import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coloncare/core/services/app_session_service.dart';
import 'package:coloncare/features/bmi/data/datasources/bmi_local_data_source.dart';
import 'package:coloncare/features/bmi/data/repositories/bmi_repository_impl.dart';
import 'package:coloncare/features/bmi/domain/repositories/bmi_repository.dart';
import 'package:coloncare/features/bmi/domain/usecases/calculate_bmi_usecase.dart';
import 'package:coloncare/features/bmi/domain/usecases/get_bmi_history_usecase.dart';
import 'package:coloncare/features/bmi/presentation/blocs/bmi_bloc.dart';
import 'package:coloncare/features/chatbot/data/datasources/chatbot_local_data_source.dart';
import 'package:coloncare/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:coloncare/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:coloncare/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:coloncare/features/chatbot/domain/usecase/send_chat_message_usecase.dart';
import 'package:coloncare/features/chatbot/presentation/blocs/chatbot_bloc.dart';
import 'package:coloncare/features/health_check/blocs/health_check_bloc.dart';
import 'package:coloncare/features/health_check/data/datasource/health_check_local_data_source.dart';
import 'package:coloncare/features/health_check/data/repositories/health_check_repository_impl.dart';
import 'package:coloncare/features/health_check/domain/repositories/health_check_repository.dart';
import 'package:coloncare/features/health_check/domain/usecases/get_health_check_settings_usecase.dart';
import 'package:coloncare/features/health_check/domain/usecases/save_health_check_result_usecase.dart';
import 'package:coloncare/features/health_check/domain/usecases/should_show_questions_usecase.dart';
import 'package:coloncare/features/health_check/domain/usecases/update_health_check_settings_usecase.dart';
import 'package:coloncare/features/medicine/data/datasources/medicine_remote_data_source.dart';
import 'package:coloncare/features/medicine/data/repositories/medicine_repository_impl.dart';
import 'package:coloncare/features/medicine/domain/repositories/medicine_repository.dart';
import 'package:coloncare/features/medicine/domain/usecases/delete_medicine_usecase.dart';
import 'package:coloncare/features/medicine/domain/usecases/get_all_medicines_usecase.dart';
import 'package:coloncare/features/medicine/domain/usecases/get_taken_status_for_day_usecase.dart';
import 'package:coloncare/features/medicine/domain/usecases/get_todays_medicines_usecase.dart';
import 'package:coloncare/features/medicine/domain/usecases/mark_medicine_taken_usecase.dart';
import 'package:coloncare/features/medicine/domain/usecases/save_medicine_usecase.dart';
import 'package:coloncare/features/medicine/domain/usecases/toggle_active_status_usecase.dart';
import 'package:coloncare/features/medicine/domain/usecases/update_last_taken_usecase.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_bloc.dart';
import 'package:coloncare/features/predict/data/datasources/prediction_local_data_source.dart';
import 'package:coloncare/features/predict/data/datasources/prediction_remote_data_source.dart';
import 'package:coloncare/features/predict/data/repositories/prediction_repository_impl.dart';
import 'package:coloncare/features/predict/domain/repositories/prediction_repository.dart';
import 'package:coloncare/features/predict/domain/usecases/get_prediction_history_usecase.dart';
import 'package:coloncare/features/predict/domain/usecases/make_prediction_usecase.dart';
import 'package:coloncare/features/predict/presentation/blocs/prediction_bloc.dart';
import 'package:coloncare/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:coloncare/features/splash/presentation/splash_bloc/splash_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import '../../features/auth/presentation/blocs/auth_form_bloc/auth_form_bloc.dart';
import '../../features/home/presentation/blocs/home_bloc/home_bloc.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/predict/domain/usecases/delete_prediction_usecase.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  await _mainInject();
  await _authInject();
  await _profileInject();
  await _medicineInject();
  await _chatbotInject();
  await _predictionInject();
  await _bmiInject();
  await _healthCheckInject();
}

Future<void> _medicineInject() async {
  // ────────────────────────────────────────────────────────────────
  //  Data Sources
  // ────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<MedicineRemoteDataSource>(
        () => MedicineRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),           // ← added (was missing)
    ),
  );

  // ────────────────────────────────────────────────────────────────
  //  Repository
  // ────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<MedicineRepository>(
        () => MedicineRepositoryImpl(
      remote: getIt<MedicineRemoteDataSource>(),
    ),
  );

  // ────────────────────────────────────────────────────────────────
  //  Use Cases – Core / Frequently used
  // ────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<SaveMedicineUseCase>(
        () => SaveMedicineUseCase(getIt<MedicineRepository>()),
  );

  getIt.registerLazySingleton<GetTodaysMedicinesUseCase>(
        () => GetTodaysMedicinesUseCase(getIt<MedicineRepository>()),
  );

  getIt.registerLazySingleton<GetAllMedicinesUseCase>(
        () => GetAllMedicinesUseCase(getIt<MedicineRepository>()),
  );

  getIt.registerLazySingleton<DeleteMedicineUseCase>(
        () => DeleteMedicineUseCase(getIt<MedicineRepository>()),
  );

  getIt.registerLazySingleton<ToggleActiveStatusUseCase>(
        () => ToggleActiveStatusUseCase(getIt<MedicineRepository>()),
  );

  getIt.registerLazySingleton<MarkMedicineTakenUseCase>(
        () => MarkMedicineTakenUseCase(getIt<MedicineRepository>()),
  );

  getIt.registerLazySingleton<GetTakenStatusForDayUseCase>(
        () => GetTakenStatusForDayUseCase(getIt<MedicineRepository>()),
  );

  getIt.registerLazySingleton<UpdateLastTakenUseCase>(
        () => UpdateLastTakenUseCase(getIt<MedicineRepository>()),
  );

  // ────────────────────────────────────────────────────────────────
  //  Bloc
  // ────────────────────────────────────────────────────────────────
  getIt.registerFactory<MedicineBloc>(
        () => MedicineBloc(
      getTodaysMedicines: getIt<GetTodaysMedicinesUseCase>(),
      getAllMedicines: getIt<GetAllMedicinesUseCase>(),
      saveMedicine: getIt<SaveMedicineUseCase>(),
      deleteMedicine: getIt<DeleteMedicineUseCase>(),
      toggleActive: getIt<ToggleActiveStatusUseCase>(),
      markTaken: getIt<MarkMedicineTakenUseCase>(),
      getTakenStatusForDay: getIt<GetTakenStatusForDayUseCase>(),
      medicineRepository: getIt<MedicineRepository>(), // ← ADD THIS LINE
    ),
  );
}

Future<void> _mainInject() async {
  // Core Services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => AppSessionService());
}


Future<void> _predictionInject() async {
  // Data Sources
  getIt.registerLazySingleton<PredictionRemoteDataSource>(
        () => PredictionRemoteDataSourceImpl(
      httpClient: http.Client(),
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton<PredictionLocalDataSource>(
        () => PredictionLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<PredictionRepository>(
        () => PredictionRepositoryImpl(
      remoteDataSource: getIt<PredictionRemoteDataSource>(),
      localDataSource: getIt<PredictionLocalDataSource>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<MakePredictionUseCase>(
        () => MakePredictionUseCase(getIt<PredictionRepository>()),
  );
  getIt.registerLazySingleton<GetPredictionHistoryUseCase>(
        () => GetPredictionHistoryUseCase(getIt<PredictionRepository>()),
  );
  getIt.registerLazySingleton<DeletePredictionUseCase>(
        () => DeletePredictionUseCase(getIt<PredictionRepository>()),
  );

  // BLoC (factory - new instance per screen)
  getIt.registerFactory<PredictionBloc>(
        () => PredictionBloc(
      makePredictionUseCase: getIt<MakePredictionUseCase>(),
      getPredictionHistoryUseCase: getIt<GetPredictionHistoryUseCase>(),
      deletePredictionUseCase: getIt<DeletePredictionUseCase>(),
    ),
  );
}

Future<void> _chatbotInject() async {
  // Data Sources
  getIt.registerLazySingleton<ChatbotRemoteDataSource>(
        () => ChatbotRemoteDataSourceImpl(
      httpClient: http.Client(),
    ),
  );

  getIt.registerLazySingleton<ChatbotLocalDataSource>(
        () => const ChatbotLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<ChatbotRepository>(
        () => ChatbotRepositoryImpl(
      remoteDataSource: getIt<ChatbotRemoteDataSource>(),
      localDataSource: getIt<ChatbotLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<SendChatMessageUseCase>(
        () => SendChatMessageUseCase(getIt<ChatbotRepository>()),
  );

  // BLoC (factory - new instance per screen)
  getIt.registerFactory<ChatbotBloc>(
        () => ChatbotBloc(
      sendChatMessageUseCase: getIt<SendChatMessageUseCase>(),
    ),
  );
}

Future<void> _bmiInject() async {
  // Data Sources
  getIt.registerLazySingleton<BmiLocalDataSource>(
        () => BmiLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<BmiRepository>(
        () => BmiRepositoryImpl(
      localDataSource: getIt<BmiLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<CalculateBmiUseCase>(
        () => CalculateBmiUseCase(getIt<BmiRepository>()),
  );

  getIt.registerLazySingleton<GetBmiHistoryUseCase>(
        () => GetBmiHistoryUseCase(getIt<BmiRepository>()),
  );

  // BLoC (factory - new instance per screen)
  getIt.registerFactory<BmiBloc>(
        () => BmiBloc(
      calculateBmiUseCase: getIt<CalculateBmiUseCase>(),
      getBmiHistoryUseCase: getIt<GetBmiHistoryUseCase>(),
    ),
  );
}

Future<void> _healthCheckInject() async {
  // Data Sources
  getIt.registerLazySingleton<HealthCheckLocalDataSource>(
        () => HealthCheckLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<HealthCheckRepository>(
        () => HealthCheckRepositoryImpl(
      localDataSource: getIt<HealthCheckLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<ShouldShowQuestionsUseCase>(
        () => ShouldShowQuestionsUseCase(getIt<HealthCheckRepository>()),
  );

  getIt.registerLazySingleton<SaveHealthCheckResultUseCase>(
        () => SaveHealthCheckResultUseCase(getIt<HealthCheckRepository>()),
  );

  // NEW: Settings Use Cases
  getIt.registerLazySingleton<GetHealthCheckSettingsUseCase>(
        () => GetHealthCheckSettingsUseCase(getIt<HealthCheckRepository>()),
  );

  getIt.registerLazySingleton<UpdateHealthCheckSettingsUseCase>(
        () => UpdateHealthCheckSettingsUseCase(getIt<HealthCheckRepository>()),
  );

  // BLoC
  getIt.registerFactory<HealthCheckBloc>(
        () => HealthCheckBloc(
      shouldShowQuestionsUseCase: getIt<ShouldShowQuestionsUseCase>(),
      saveHealthCheckResultUseCase: getIt<SaveHealthCheckResultUseCase>(),
      repository: getIt<HealthCheckRepository>(),
    ),
  );
}

Future<void> _profileInject() async {
  getIt.registerFactory<ProfileBloc>(
        () => ProfileBloc(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );
}

Future<void> _authInject() async {
  getIt.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      auth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
          () => ResetPasswordUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
          () => CheckAuthStatusUseCase(getIt<AuthRepository>()));

  // BLoCs
  getIt.registerLazySingleton<AuthBloc>(
        () => AuthBloc(
      checkAuthStatusUseCase: getIt<CheckAuthStatusUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
    ),
  );

  getIt.registerFactory<AuthFormBloc>(
        () => AuthFormBloc(),
  );

  getIt.registerFactory<HomeBloc>(
        () => HomeBloc(authBloc: getIt<AuthBloc>()),
  );

  getIt.registerFactory<SplashBloc>(
        () => SplashBloc(authBloc: getIt<AuthBloc>()),
  );
}