import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../domain/entities/article_input.dart';

abstract class UploadArticleRemoteDataSource {
  Future<void> uploadArticle(ArticleInput article);
}

class UploadArticleRemoteDataSourceImpl implements UploadArticleRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UploadArticleRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<void> uploadArticle(ArticleInput article) async {
    String? imageUrl;
    
    // 1. Upload Image if exists
    if (article.imagePath != null && article.imagePath!.isNotEmpty) {
      final file = File(article.imagePath!);
      // Ensure unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child('media/articles/$fileName');
      
      try {
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        throw Exception('Image upload failed: $e');
      }
    } else {
        throw Exception('Image is required');
    }

    // 2. Create Article Document
    final articleData = {
      'author': article.author ?? 'Anonymous',
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
