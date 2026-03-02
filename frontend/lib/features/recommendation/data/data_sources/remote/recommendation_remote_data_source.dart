import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/user_preferences.dart';

abstract class RecommendationRemoteDataSource {
  Future<UserPreferencesEntity> getPreferences();
  Future<void> updatePreferences(UserPreferencesEntity preferences);
}

class RecommendationRemoteDataSourceImpl
    implements RecommendationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RecommendationRemoteDataSourceImpl(this._firestore, this._auth);

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _preferencesRef {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('preferences')
        .doc('news_prefs');
  }

  @override
  Future<UserPreferencesEntity> getPreferences() async {
    final doc = await _preferencesRef.get();
    if (!doc.exists || doc.data() == null) {
      return const UserPreferencesEntity();
    }

    final data = doc.data()!;
    return UserPreferencesEntity(
      likedCategories: List<String>.from(data['likedCategories'] ?? []),
      dislikedCategories: List<String>.from(data['dislikedCategories'] ?? []),
      tagScores: Map<String, int>.from(data['tagScores'] ?? {}),
    );
  }

  @override
  Future<void> updatePreferences(UserPreferencesEntity preferences) async {
    final data = {
      'likedCategories': preferences.likedCategories,
      'dislikedCategories': preferences.dislikedCategories,
      'tagScores': preferences.tagScores,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _preferencesRef.set(data, SetOptions(merge: true));
  }
}
