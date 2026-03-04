import '../entities/profile_entities.dart';

abstract class ProfileRepository {
  Future<UserProfileDataEntity> getUserProfile();
  Future<List<UserPostEntity>> getUserPosts();
  Future<int> getFollowersCount();
  Future<int> getFollowingCount();
  Future<void> updateProfile({String? name, String? title, String? photoUrl});
}
