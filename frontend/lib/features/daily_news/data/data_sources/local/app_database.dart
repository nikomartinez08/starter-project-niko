import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import '../../models/article.dart';
import '../../../../favorites/data/models/favorite_article_model.dart';
import '../../../../favorites/data/data_sources/local/favorites_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';
part 'app_database.g.dart';

@Database(version: 2, entities: [ArticleModel, FavoriteArticleModel])
abstract class AppDatabase extends FloorDatabase {
  ArticleDao get articleDAO;
  FavoriteDao get favoriteDAO;
}
