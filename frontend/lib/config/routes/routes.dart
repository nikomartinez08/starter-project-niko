import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/domain/entities/draft.dart';
import '../../features/daily_news/presentation/bloc/article/draft/draft_cubit.dart';
import '../../features/daily_news/presentation/bloc/article/upload/upload_article_cubit.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/daily_news/presentation/pages/upload_article/upload_article.dart';
import '../../features/daily_news/presentation/pages/upload_article/drafts_list_page.dart';
import '../../features/daily_news/presentation/pages/my_articles/my_articles_page.dart';
import '../../features/daily_news/presentation/pages/news_feed/news_feed_screen.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/favorites/presentation/bloc/favorites_event.dart';
import '../../features/streaming/presentation/bloc/streaming_bloc.dart';
import '../../features/streaming/presentation/pages/broadcaster_screen.dart';
import '../../features/streaming/presentation/pages/viewer_screen.dart';
import '../../features/streaming/domain/entities/live_stream_entity.dart';
import '../../injection_container.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/Login':
        return _materialRoute(const LoginPage());

      case '/Register':
        return _materialRoute(const RegisterPage());

      case '/ArticleDetails':
        return _materialRoute(
            ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/UploadArticle':
        final draft = settings.arguments as DraftEntity?;
        return _materialRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider<UploadArticleCubit>(
                create: (_) => sl<UploadArticleCubit>(),
              ),
              BlocProvider<DraftCubit>(
                create: (_) => sl<DraftCubit>(),
              ),
            ],
            child: UploadArticlePage(draft: draft),
          ),
        );

      case '/Drafts':
        return _materialRoute(const DraftsListPage());

      case '/NewsFeed':
        return _materialRoute(const NewsFeedScreen());

      case '/Favorites':
        return _materialRoute(
          BlocProvider<FavoritesBloc>(
            create: (context) => sl()..add(GetFavorites()),
            child: const FavoritesPage(),
          ),
        );

      case '/MyArticles':
        return _materialRoute(
          BlocProvider<DraftCubit>(
            create: (_) => sl<DraftCubit>()..loadDrafts(),
            child: const MyArticlesPage(),
          ),
        );

      case '/BroadcasterScreen':
        return _materialRoute(
          BlocProvider<StreamingBloc>(
            create: (_) => sl<StreamingBloc>(),
            child: const BroadcasterScreen(),
          ),
        );

      case '/ViewerScreen':
        return _materialRoute(
          ViewerScreen(stream: settings.arguments as LiveStreamEntity),
        );

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
