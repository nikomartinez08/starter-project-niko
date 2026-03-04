import 'package:equatable/equatable.dart';

class UserPostEntity extends Equatable {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final String? description;
  final String? urlToImage;
  final DateTime createdAt;

  const UserPostEntity({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    this.description,
    this.urlToImage,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, authorId, title, content, description, urlToImage, createdAt];
}

class UserProfileDataEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? title;
  final String? photoUrl;
  final int followersCount;
  final int followingCount;
  final List<UserPostEntity> posts;

  const UserProfileDataEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.title,
    this.photoUrl,
    required this.followersCount,
    required this.followingCount,
    required this.posts,
  });

  @override
  List<Object?> get props => [uid, name, email, title, photoUrl, followersCount, followingCount, posts];
}
