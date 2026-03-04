import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:news_app_clean_architecture/features/profile/domain/entities/profile_entities.dart';
import 'package:news_app_clean_architecture/features/profile/data/data_sources/remote/profile_remote_data_source.dart';

class ProfileSupabaseServiceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _supabaseClient;

  ProfileSupabaseServiceImpl(this._supabaseClient);

  String get _uid {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  @override
  Future<int> getFollowersCount() async {
    return 0; // Aún no implementado en Supabase
  }

  @override
  Future<int> getFollowingCount() async {
    return 0; // Aún no implementado en Supabase
  }

  @override
  Future<void> updateProfile({String? name, String? title, String? photoUrl}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (title != null) data['title'] = title;
    if (photoUrl != null) data['photo_url'] = photoUrl;

    if (data.isNotEmpty) {
      await _supabaseClient
          .from('profiles')
          .update(data)
          .eq('id', _uid);
    }
  }

  @override
  Future<List<UserPostEntity>> getUserPosts() async {
    final response = await _supabaseClient
        .from('articles')
        .select()
        .eq('author_id', _uid)
        .order('created_at', ascending: false);

    final List<dynamic> data = response;
    
    return data.map((json) {
      return UserPostEntity(
        id: json['id'].toString(),
        authorId: json['author_id'].toString(),
        title: json['title'] as String,
        content: json['content'] as String? ?? '',
        description: json['description'] as String?,
        urlToImage: json['url_to_image'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<UserProfileDataEntity> getUserProfile() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Intentar obtener el perfil
    var response = await _supabaseClient
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    // Si no existe, crearlo (fallback por si el trigger falló o es un usuario viejo)
    if (response == null) {
      final newProfile = {
        'id': user.id,
        'email': user.email ?? '',
        'name': user.userMetadata?['name'] ?? 'Usuario',
        'title': 'Nuevo usuario',
        'photo_url': null,
      };
      await _supabaseClient.from('profiles').insert(newProfile);
      response = newProfile;
    }

    final Map<String, dynamic> userData = response;

    final posts = await getUserPosts(); 
    final followersCount = await getFollowersCount();
    final followingCount = await getFollowingCount();

    return UserProfileDataEntity(
      uid: user.id,
      name: userData['name'] as String? ?? 'Anonymous',
      email: userData['email'] as String? ?? user.email ?? '',
      title: userData['title'] as String?,
      photoUrl: userData['photo_url'] as String?,
      followersCount: followersCount,
      followingCount: followingCount,
      posts: posts,
    );
  }
}
