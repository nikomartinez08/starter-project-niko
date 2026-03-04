import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/user_preferences.dart';
import '../../models/user_preferences_model.dart';
import 'recommendation_remote_data_source.dart';

class RecommendationSupabaseServiceImpl implements RecommendationRemoteDataSource {
  final SupabaseClient _supabaseClient;

  RecommendationSupabaseServiceImpl(this._supabaseClient);

  @override
  Future<UserPreferencesEntity> getPreferences() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabaseClient
          .from('user_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        return const UserPreferencesEntity();
      }

      return UserPreferencesModel.fromJson(response);
    } catch (e) {
      // If table doesn't exist or other error, return default
      return const UserPreferencesEntity();
    }
  }

  @override
  Future<void> updatePreferences(UserPreferencesEntity preferences) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final model = UserPreferencesModel.fromEntity(preferences);
    
    final data = model.toJson();
    data['user_id'] = user.id;

    await _supabaseClient
        .from('user_preferences')
        .upsert(data);
  }
}
