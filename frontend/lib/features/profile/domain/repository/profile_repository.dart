import '../entities/profile_entities.dart';

abstract class ProfileRepository {
  Stream<UserProfileDataEntity> getUserProfile();
}
