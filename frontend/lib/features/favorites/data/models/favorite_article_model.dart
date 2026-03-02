import 'package:floor/floor.dart';
import '../../domain/entities/favorite_article.dart';

@Entity(tableName: 'favorite_article', primaryKeys: ['id'])
class FavoriteArticleModel extends FavoriteArticleEntity {
  const FavoriteArticleModel({
    int? id,
    String? externalId,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    DateTime? savedAt,
  }) : super(
          id: id,
          externalId: externalId,
          author: author,
          title: title,
          description: description,
          url: url,
          urlToImage: urlToImage,
          publishedAt: publishedAt,
          content: content,
          savedAt: savedAt,
        );

  factory FavoriteArticleModel.fromEntity(FavoriteArticleEntity entity) {
    return FavoriteArticleModel(
      id: entity.id,
      externalId: entity.externalId,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
      savedAt: entity.savedAt ?? DateTime.now(),
    );
  }
}
