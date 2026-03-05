import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'features/upload_article/data/datasources/remote/upload_article_remote_data_source.dart';
import 'features/upload_article/data/repositories/upload_article_repository_impl.dart';
import 'features/upload_article/domain/repositories/upload_article_repository.dart';
import 'features/upload_article/domain/usecases/upload_article_usecase.dart';
import 'features/upload_article/presentation/bloc/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_cubit.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'package:floor/floor.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/draft_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_drafts.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/draft/draft_cubit.dart';
import 'package:news_app_clean_architecture/features/favorites/domain/repository/favorites_repository.dart';
import 'package:news_app_clean_architecture/features/favorites/data/repository/favorites_repository_impl.dart';
import 'package:news_app_clean_architecture/features/favorites/data/data_sources/remote/favorites_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/favorites/domain/usecases/get_favorites.dart';
import 'package:news_app_clean_architecture/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:news_app_clean_architecture/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:news_app_clean_architecture/features/recommendation/domain/repository/recommendation_repository.dart';
import 'package:news_app_clean_architecture/features/recommendation/data/repository/recommendation_repository_impl.dart';
import 'package:news_app_clean_architecture/features/recommendation/data/data_sources/remote/recommendation_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/recommendation/data/data_sources/remote/recommendation_supabase_service.dart';
import 'package:news_app_clean_architecture/features/recommendation/domain/usecases/get_personalized_feed.dart';
import 'package:news_app_clean_architecture/features/recommendation/domain/usecases/update_user_preferences.dart';
import 'package:news_app_clean_architecture/features/profile/domain/repository/profile_repository.dart';
import 'package:news_app_clean_architecture/features/profile/data/repository/profile_repository_impl.dart';
import 'package:news_app_clean_architecture/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/profile/domain/usecases/get_profile_data.dart';
import 'package:news_app_clean_architecture/features/profile/domain/usecases/update_profile_data.dart';
import 'package:news_app_clean_architecture/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_github_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_supabase_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:news_app_clean_architecture/features/profile/data/data_sources/remote/profile_supabase_service.dart';
import 'package:news_app_clean_architecture/features/favorites/data/data_sources/remote/favorites_supabase_service.dart';
import 'package:news_app_clean_architecture/features/streaming/data/data_sources/remote/streaming_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/streaming/data/data_sources/remote/streaming_supabase_service.dart';
import 'package:news_app_clean_architecture/features/streaming/data/data_sources/local/agora_service.dart';
import 'package:news_app_clean_architecture/features/streaming/domain/repository/streaming_repository.dart';
import 'package:news_app_clean_architecture/features/streaming/data/repository/streaming_repository_impl.dart';
import 'package:news_app_clean_architecture/features/streaming/domain/usecases/create_stream_usecase.dart';
import 'package:news_app_clean_architecture/features/streaming/domain/usecases/end_stream_usecase.dart';
import 'package:news_app_clean_architecture/features/streaming/domain/usecases/get_active_streams_usecase.dart';
import 'package:news_app_clean_architecture/features/streaming/domain/usecases/get_stream_token_usecase.dart';
import 'package:news_app_clean_architecture/features/streaming/domain/usecases/get_stream_by_id_usecase.dart';
import 'package:news_app_clean_architecture/features/streaming/presentation/bloc/streaming_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Migration from v1 to v2: adds the favorite_article table
  final migration1to2 = Migration(1, 2, (database) async {
    await database.execute(
      'CREATE TABLE IF NOT EXISTS `favorite_article` '
      '(`id` INTEGER PRIMARY KEY AUTOINCREMENT, `externalId` TEXT, '
      '`author` TEXT, `title` TEXT, `description` TEXT, `url` TEXT, '
      '`urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, `savedAt` TEXT)',
    );
  });

  // Migration from v2 to v3: adds the draft table
  final migration2to3 = Migration(2, 3, (database) async {
    await database.execute(
      'CREATE TABLE IF NOT EXISTS `draft` '
      '(`id` INTEGER PRIMARY KEY AUTOINCREMENT, `author` TEXT, '
      '`title` TEXT, `content` TEXT, `imagePath` TEXT, '
      '`createdAt` TEXT, `updatedAt` TEXT)',
    );
  });

  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .addMigrations([migration1to2, migration2to3]).build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  sl.registerSingleton<Dio>(dio);
  
  // Supabase
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Auth Data Sources
  sl.registerSingleton<AuthRemoteDataSource>(
      AuthSupabaseServiceImpl(sl()));
  sl.registerSingleton<AuthLocalDataSource>(
      AuthLocalDataSourceImpl(sl()));

  // Favorites Data Source (Supabase)
  sl.registerSingleton<FavoritesRemoteDataSource>(
      FavoritesSupabaseServiceImpl(sl()));

  // Recommendation Data Source
  sl.registerSingleton<RecommendationRemoteDataSource>(
      RecommendationSupabaseServiceImpl(sl()));

  // Profile Data Source
  sl.registerSingleton<ProfileRemoteDataSource>(
      ProfileSupabaseServiceImpl(sl()) as ProfileRemoteDataSource);

  // Repositories
  sl.registerSingleton<FavoritesRepository>(
      FavoritesRepositoryImpl(database.favoriteDAO, sl()));

  sl.registerSingleton<RecommendationRepository>(
      RecommendationRepositoryImpl(sl()));

  sl.registerSingleton<ProfileRepository>(ProfileRepositoryImpl(sl()));

  sl.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(sl(), sl()));

  sl.registerSingleton<DraftRepository>(
      DraftRepositoryImpl(database.draftDAO));

  // Dependencies
  // Explicitly passing GNews URL to avoid generated code default (newsapi.org)
  sl.registerSingleton<NewsApiService>(NewsApiService(sl(), baseUrl: 'https://gnews.io/api/v4'));

  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl(), sl()));

  //UseCases
  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl()));
  sl.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(sl()));
  sl.registerSingleton<SignInWithGithubUseCase>(SignInWithGithubUseCase(sl()));
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));
  sl.registerSingleton<DeleteAccountUseCase>(DeleteAccountUseCase(sl()));
  sl.registerSingleton<GetCurrentUserUseCase>(GetCurrentUserUseCase(sl()));

  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  sl.registerSingleton<CreateArticleUseCase>(CreateArticleUseCase(sl()));

  sl.registerSingleton<GetFavoritesUseCase>(GetFavoritesUseCase(sl()));

  sl.registerSingleton<ToggleFavoriteUseCase>(ToggleFavoriteUseCase(sl()));

  sl.registerSingleton<CheckFavoriteUseCase>(CheckFavoriteUseCase(sl()));

  sl.registerSingleton<GetPersonalizedFeedUseCase>(
      GetPersonalizedFeedUseCase(sl()));

  sl.registerSingleton<UpdateUserPreferencesUseCase>(
      UpdateUserPreferencesUseCase(sl()));

  sl.registerSingleton<GetProfileDataUseCase>(GetProfileDataUseCase(sl()));

  sl.registerSingleton<UpdateProfileDataUseCase>(UpdateProfileDataUseCase(sl()));

  sl.registerSingleton<GetDraftsUseCase>(GetDraftsUseCase(sl()));

  sl.registerSingleton<SaveDraftUseCase>(SaveDraftUseCase(sl()));

  sl.registerSingleton<UpdateDraftUseCase>(UpdateDraftUseCase(sl()));

  sl.registerSingleton<DeleteDraftUseCase>(DeleteDraftUseCase(sl()));

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
      () => RemoteArticlesBloc(sl(), sl(), sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  sl.registerFactory<UploadArticleCubit>(() => UploadArticleCubit(sl()));

  sl.registerFactory<FavoritesBloc>(() => FavoritesBloc(sl(), sl()));

  sl.registerFactory<ProfileBloc>(() => ProfileBloc(sl(), sl()));

  sl.registerFactory<DraftCubit>(
      () => DraftCubit(sl(), sl(), sl(), sl()));

  sl.registerFactory<AuthBloc>(
      () => AuthBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl()));

  // ── Streaming ──────────────────────────────────────────────
  sl.registerSingleton<StreamingRemoteDataSource>(
      StreamingSupabaseServiceImpl(sl()));

  sl.registerSingleton<AgoraService>(AgoraService());

  sl.registerSingleton<StreamingRepository>(
      StreamingRepositoryImpl(sl()));

  sl.registerSingleton<CreateStreamUseCase>(CreateStreamUseCase(sl()));
  sl.registerSingleton<EndStreamUseCase>(EndStreamUseCase(sl()));
  sl.registerSingleton<GetActiveStreamsUseCase>(GetActiveStreamsUseCase(sl()));
  sl.registerSingleton<GetStreamTokenUseCase>(GetStreamTokenUseCase(sl()));
  sl.registerSingleton<GetStreamByIdUseCase>(GetStreamByIdUseCase(sl()));

  sl.registerFactory<StreamingBloc>(
      () => StreamingBloc(sl(), sl(), sl()));

  // Upload Article
  sl.registerSingleton<UploadArticleRemoteDataSource>(
      UploadArticleRemoteDataSourceImpl(FirebaseFirestore.instance, FirebaseStorage.instance));
      
  sl.registerSingleton<UploadArticleRepository>(
      UploadArticleRepositoryImpl(sl()));
      
  sl.registerSingleton<UploadArticleUseCase>(
      UploadArticleUseCase(sl()));

  sl.registerFactory<UploadArticleBloc>(
      () => UploadArticleBloc(sl()));
}
