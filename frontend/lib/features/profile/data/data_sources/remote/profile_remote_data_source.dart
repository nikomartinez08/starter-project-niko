import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/profile_entities.dart';

abstract class ProfileRemoteDataSource {
  Stream<UserProfileDataEntity> getUserProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRemoteDataSourceImpl(this._firestore, this._auth);

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  @override
  Stream<UserProfileDataEntity> getUserProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('posts')
        .where('authorId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((postsSnapshot) async {
      
      final posts = postsSnapshot.docs.map((doc) {
        final data = doc.data();
        return UserPostEntity(
          id: doc.id,
          authorId: data['authorId'] ?? '',
          content: data['content'] ?? '',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      final followersSnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('followers')
          .count()
          .get();
          
      final followingSnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('following')
          .count()
          .get();

      return UserProfileDataEntity(
        uid: user.uid,
        name: user.displayName ?? 'Anonymous',
        email: user.email ?? 'No Email',
        photoUrl: user.photoURL,
        followersCount: followersSnapshot.count ?? 0,
        followingCount: followingSnapshot.count ?? 0,
        posts: posts,
      );
    });
  }
}
