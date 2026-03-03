import 'package:equatable/equatable.dart';

class UserPostEntity extends Equatable {
  final String id;
  final String authorId;
  final String content;
  final DateTime createdAt;

  const UserPostEntity({
    required this.id,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, authorId, content, createdAt];
}

class UserProfileDataEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final int followersCount;
  final int followingCount;
  final List<UserPostEntity> posts;

  const UserProfileDataEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.followersCount,
    required this.followingCount,
    required this.posts,
  });

  @override
  List<Object?> get props => [uid, name, email, photoUrl, followersCount, followingCount, posts];
}
