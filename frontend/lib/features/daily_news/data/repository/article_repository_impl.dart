import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  final SharedPreferences _prefs;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  static const _cacheKey = 'cached_articles';

  ArticleRepositoryImpl(this._newsApiService, this._appDatabase, this._prefs);

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles({int page = 1, int pageSize = 20}) async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
        page: page,
        pageSize: pageSize,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        // Cache page 1 results for offline use
        if (page == 1) {
          _cacheArticles(httpResponse.data);
        }
        return DataSuccess(httpResponse.data);
      } else {
        return DataFailed(DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions));
      }
    } on DioException catch (e) {
      // Try serving cached articles on network failure
      if (page == 1) {
        final cached = _getCachedArticles();
        if (cached.isNotEmpty) {
          return DataSuccess(cached);
        }
      }
      return DataFailed(e);
    }
  }

  void _cacheArticles(List<ArticleModel> articles) {
    try {
      final jsonList = articles.map((a) => a.toJson()).toList();
      _prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Failed to cache articles: $e');
    }
  }

  List<ArticleModel> _getCachedArticles() {
    try {
      final raw = _prefs.getString(_cacheKey);
      if (raw == null) return [];
      final List<dynamic> jsonList = jsonDecode(raw);
      return jsonList
          .map((j) => ArticleModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to load cached articles: $e');
      return [];
    }
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    // Use title-based deletion since API articles don't have a local DB id
    if (article.title != null) {
      return _appDatabase.articleDAO.deleteArticleByTitle(article.title!);
    }
    return _appDatabase.articleDAO
        .deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .insertArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> createArticle(ArticleEntity article) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado para crear artículo');
      }

      String? imageUrl = article.urlToImage;

      // Check if image URL is a local file path
      if (imageUrl != null &&
          imageUrl.isNotEmpty &&
          !imageUrl.startsWith('http')) {
        final file = File(imageUrl);
        if (await file.exists()) {
          final fileName = '${const Uuid().v4()}.jpg';
          final path = 'media/articles/$fileName';
          
          try {
            await _supabaseClient.storage.from('images').upload(
              path,
              file,
              fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
            );
            
            imageUrl = _supabaseClient.storage.from('images').getPublicUrl(path);
          } catch (e) {
            debugPrint('Fallo al subir imagen a Supabase: $e');
            // Usamos una imagen de placeholder para que no falle la inserción
            imageUrl = 'https://via.placeholder.com/400x200.png?text=Error+Storage';
          }
        }
      }

      final articleData = {
        'author_id': user.id,
        'author_name': article.author ?? user.email,
        'title': article.title ?? 'Sin título',
        'description': article.description,
        'url_to_image': imageUrl,
        'published_at': article.publishedAt ?? DateTime.now().toIso8601String(),
        'content': article.content,
      };

      await _supabaseClient
          .from('articles')
          .insert(articleData);
          
    } catch (e) {
      debugPrint("Error creating article: $e");
      rethrow;
    }
  }
}
