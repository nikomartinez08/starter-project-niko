import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/article_input.dart';

abstract class UploadArticleRemoteDataSource {
  Future<void> uploadArticle(ArticleInput article);
}

class UploadArticleRemoteDataSourceImpl implements UploadArticleRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase;

  UploadArticleRemoteDataSourceImpl(this._firestore, this._supabase);

  @override
  Future<void> uploadArticle(ArticleInput article) async {
    String? imageUrl;
    
    // 1. Upload Image to Supabase Storage
    if (article.imagePath != null && article.imagePath!.isNotEmpty) {
      final file = File(article.imagePath!);
      // Ensure unique filename
      final fileName = 'articles/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      
      try {
        await _supabase.storage.from('media').upload(
          fileName,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        
        // Get Public URL
        imageUrl = _supabase.storage.from('media').getPublicUrl(fileName);
      } catch (e) {
        throw Exception('Supabase Storage upload failed: $e');
      }
    } else {
        throw Exception('Image is required');
    }

    // 2. Create Article Document in Firestore
    final user = _supabase.auth.currentUser;
    final articleData = {
      'author': article.author ?? 'Anonymous',
      'userId': user?.id, // Store UID for ownership
      'title': article.title ?? '',
      'description': article.description ?? '',
      'content': article.content ?? '',
      'urlToImage': imageUrl ?? '',
      'publishedAt': DateTime.now().toIso8601String(),
      // 'url': '', // Optional
    };

    try {
        await _firestore.collection('articles').add(articleData);
    } catch (e) {
        throw Exception('Firestore write failed: $e');
    }
  }
}
