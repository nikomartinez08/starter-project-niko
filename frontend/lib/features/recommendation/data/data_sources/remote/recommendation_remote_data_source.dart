import '../../../domain/entities/user_preferences.dart';

abstract class RecommendationRemoteDataSource {
  Future<UserPreferencesEntity> getPreferences();
  Future<void> updatePreferences(UserPreferencesEntity preferences);
}
