import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/favorite_article_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteArticleModel>> getFavorites();
  Future<void> saveFavorite(FavoriteArticleModel article);
  Future<void> removeFavorite(String externalId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoritesRemoteDataSourceImpl(this._firestore, this._auth);

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _favoritesRef {
    return _firestore.collection('users').doc(_uid).collection('favorites');
  }

  @override
  Future<List<FavoriteArticleModel>> getFavorites() async {
    final snapshot = await _favoritesRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FavoriteArticleModel(
        externalId: doc.id,
        author: data['author'],
        title: data['title'],
        description: data['description'],
        url: data['url'],
        urlToImage: data['urlToImage'],
        publishedAt: data['publishedAt'],
        content: data['content'],
        savedAt: data['savedAt'] != null
            ? (data['savedAt'] as Timestamp).toDate()
            : null,
      );
    }).toList();
  }

  @override
  Future<void> removeFavorite(String externalId) async {
    // Firestore uses document IDs which cannot contain slashes. We need to encode the URL
    // if using url as externalId, or use it directly if encoded elsewhere.
    await _favoritesRef.doc(_encodeId(externalId)).delete();
  }

  @override
  Future<void> saveFavorite(FavoriteArticleModel article) async {
    final data = {
      'author': article.author,
      'title': article.title,
      'description': article.description,
      'url': article.url,
      'urlToImage': article.urlToImage,
      'publishedAt': article.publishedAt,
      'content': article.content,
      'savedAt': Timestamp.fromDate(article.savedAt ?? DateTime.now()),
    };

    await _favoritesRef.doc(_encodeId(article.externalId!)).set(data);
  }

  String _encodeId(String url) {
    // Basic encoding to use url as document id, since document IDs cannot contain '/'
    return Uri.encodeComponent(url);
  }
}
