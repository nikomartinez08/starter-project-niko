import 'package:flutter/material.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/daily_news/presentation/pages/upload_article/upload_article.dart';
import '../../features/daily_news/presentation/pages/news_feed/news_feed_screen.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/favorites/presentation/bloc/favorites_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        return _materialRoute(
            ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/UploadArticle':
        return _materialRoute(const UploadArticlePage());

      case '/NewsFeed':
        return _materialRoute(const NewsFeedScreen());

      case '/Favorites':
        return _materialRoute(
          BlocProvider<FavoritesBloc>(
            create: (context) => sl()..add(GetFavorites()),
            child: const FavoritesPage(),
          ),
        );

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
