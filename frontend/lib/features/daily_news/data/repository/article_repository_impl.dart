import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
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
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  ArticleRepositoryImpl(this._newsApiService, this._appDatabase);

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      } else {
        return DataFailed(DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
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
        'url': article.url, 
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
