import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/favorite_article_model.dart';
import 'favorites_remote_data_source.dart';

class FavoritesSupabaseServiceImpl implements FavoritesRemoteDataSource {
  final SupabaseClient _supabaseClient;

  FavoritesSupabaseServiceImpl(this._supabaseClient);

  String get _uid {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  @override
  Future<List<FavoriteArticleModel>> getFavorites() async {
    final response = await _supabaseClient
        .from('favorites')
        .select()
        .eq('user_id', _uid)
        .order('created_at', ascending: false);

    final List<dynamic> data = response;
    return data.map((json) {
      // Los datos del artículo están dentro de 'article_data' (columna JSONB)
      final articleData = json['article_data'] as Map<String, dynamic>;
      
      return FavoriteArticleModel(
        // Usamos el ID de la fila de favoritos como externalId si no hay uno en el json
        externalId: json['id'] as String?, 
        author: articleData['author'] as String?,
        title: articleData['title'] as String?,
        description: articleData['description'] as String?,
        url: articleData['url'] as String?,
        urlToImage: articleData['urlToImage'] as String?,
        publishedAt: articleData['publishedAt'] as String?,
        content: articleData['content'] as String?,
        savedAt: DateTime.parse(json['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> removeFavorite(String externalId) async {
    // Aquí asumimos que externalId es la URL del artículo (como en Firestore)
    // Pero en Supabase, lo ideal es borrar por ID de fila.
    // Buscaremos la fila que tenga esa URL en article_data -> url
    
    // OPCIÓN A: Si externalId es el UUID de la tabla favorites
    // await _supabaseClient.from('favorites').delete().eq('id', externalId);

    // OPCIÓN B: Buscar dentro del JSON (más lento pero compatible con la lógica anterior)
    // Nota: Esto requiere que externalId sea único.
    
    // Mejor estrategia para compatibilidad: 
    // Buscar el registro donde article_data->url coincida con externalId
    await _supabaseClient
        .from('favorites')
        .delete()
        .eq('user_id', _uid)
        .filter('article_data->>url', 'eq', externalId); 
  }

  @override
  Future<void> saveFavorite(FavoriteArticleModel article) async {
    final articleData = {
      'author': article.author,
      'title': article.title,
      'description': article.description,
      'url': article.url, // Usamos la URL como identificador único
      'urlToImage': article.urlToImage,
      'publishedAt': article.publishedAt,
      'content': article.content,
    };

    // Usamos upsert para evitar duplicados si la tabla tiene restricción unique(user_id, article_id)
    // Pero como no tenemos article_id (UUID), dependemos de que no se repita.
    // La mejor forma aquí es insertar.
    
    await _supabaseClient.from('favorites').insert({
      'user_id': _uid,
      'article_data': articleData,
      // 'article_id': null, // Dejamos null si no viene de nuestra tabla articles interna
    });
  }
}
