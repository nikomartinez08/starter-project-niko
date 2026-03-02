import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
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
import 'package:news_app_clean_architecture/features/favorites/domain/repository/favorites_repository.dart';
import 'package:news_app_clean_architecture/features/favorites/data/repository/favorites_repository_impl.dart';
import 'package:news_app_clean_architecture/features/favorites/data/data_sources/remote/favorites_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/favorites/domain/usecases/get_favorites.dart';
import 'package:news_app_clean_architecture/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:news_app_clean_architecture/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/recommendation/domain/repository/recommendation_repository.dart';
import 'package:news_app_clean_architecture/features/recommendation/data/repository/recommendation_repository_impl.dart';
import 'package:news_app_clean_architecture/features/recommendation/data/data_sources/remote/recommendation_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/recommendation/domain/usecases/get_personalized_feed.dart';
import 'package:news_app_clean_architecture/features/recommendation/domain/usecases/update_user_preferences.dart';
import 'package:news_app_clean_architecture/features/profile/domain/repository/profile_repository.dart';
import 'package:news_app_clean_architecture/features/profile/data/repository/profile_repository_impl.dart';
import 'package:news_app_clean_architecture/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/profile/domain/usecases/get_profile_data.dart';
import 'package:news_app_clean_architecture/features/profile/presentation/bloc/profile_bloc.dart';

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

  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .addMigrations([migration1to2]).build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Firebase
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // Favorites Data Source
  sl.registerSingleton<FavoritesRemoteDataSource>(
      FavoritesRemoteDataSourceImpl(sl(), sl()));

  // Recommendation Data Source
  sl.registerSingleton<RecommendationRemoteDataSource>(
      RecommendationRemoteDataSourceImpl(sl(), sl()));

  // Profile Data Source
  sl.registerSingleton<ProfileRemoteDataSource>(
      ProfileRemoteDataSourceImpl(sl(), sl()));

  // Repositories
  sl.registerSingleton<FavoritesRepository>(
      FavoritesRepositoryImpl(database.favoriteDAO, sl()));

  sl.registerSingleton<RecommendationRepository>(
      RecommendationRepositoryImpl(sl()));

  sl.registerSingleton<ProfileRepository>(ProfileRepositoryImpl(sl()));

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  //UseCases
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

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(
      () => RemoteArticlesBloc(sl(), sl(), sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  sl.registerFactory<UploadArticleCubit>(() => UploadArticleCubit(sl()));

  sl.registerFactory<FavoritesBloc>(() => FavoritesBloc(sl(), sl()));

  sl.registerFactory<ProfileBloc>(() => ProfileBloc(sl()));
}
