import 'package:news_app_clean_architecture/features/profile/domain/entities/profile_entities.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileDataEntity> getUserProfile();
  Future<List<UserPostEntity>> getUserPosts();
  Future<int> getFollowersCount();
  Future<int> getFollowingCount();
  Future<void> updateProfile({String? name, String? title, String? photoUrl});
}
