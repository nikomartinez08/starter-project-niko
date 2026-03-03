import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

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
      String? imageUrl = article.urlToImage;

      // Check if image URL is a local file path
      if (imageUrl != null &&
          imageUrl.isNotEmpty &&
          !imageUrl.startsWith('http')) {
        final file = File(imageUrl);
        if (await file.exists()) {
          final fileName = const Uuid().v4();
          final ref = _storage.ref().child('media/articles/$fileName');
          try {
            final uploadSnapshot = await ref
                .putFile(file)
                .timeout(const Duration(seconds: 10)); // Timeout más corto para no esperar tanto
            imageUrl = await uploadSnapshot.ref
                .getDownloadURL()
                .timeout(const Duration(seconds: 5));
          } catch (e) {
            debugPrint('Fallo al subir imagen (Storage no configurado): $e');
            // Usamos una imagen de placeholder para que no falle Firestore
            imageUrl = 'https://via.placeholder.com/400x200.png?text=Sin+Imagen+Storage';
          }
        }
      }

      final articleData = {
        'authorId': FirebaseAuth.instance.currentUser?.uid,
        'author': article.author,
        'title': article.title,
        'description': article.description,
        'url': article.url,
        'urlToImage': imageUrl,
        'publishedAt': article.publishedAt,
        'content': article.content,
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore
            .collection('posts')
            .add(articleData)
            .timeout(const Duration(seconds: 15));
      } on TimeoutException catch (te) {
        debugPrint('Timeout adding article to Firestore: $te');
        throw Exception('Timeout adding article to server');
      }
    } catch (e) {
      debugPrint("Error creating article: $e");
      rethrow;
    }
  }
}
