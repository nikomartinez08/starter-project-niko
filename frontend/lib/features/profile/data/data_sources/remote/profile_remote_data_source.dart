import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/profile_entities.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileDataEntity> getUserProfile();
  Future<List<UserPostEntity>> getUserPosts();
  Future<int> getFollowersCount();
  Future<int> getFollowingCount();
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
  Future<int> getFollowersCount() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('followers')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getFollowingCount() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('following')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  @override
  Future<List<UserPostEntity>> getUserPosts() async {
    final snapshot = await _firestore
        .collection('posts')
        .where('authorId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserPostEntity(
        id: doc.id,
        authorId: data['authorId'] ?? '',
        content: data['content'] ?? '',
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<UserProfileDataEntity> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final posts = await getUserPosts();
    final followersCount = await getFollowersCount();
    final followingCount = await getFollowingCount();

    return UserProfileDataEntity(
      uid: user.uid,
      name: user.displayName ?? 'Anonymous',
      email: user.email ?? 'No Email',
      followersCount: followersCount,
      followingCount: followingCount,
      posts: posts,
    );
  }
}
