import 'package:equatable/equatable.dart';

class FavoriteArticleEntity extends Equatable {
  final int? id; // Local database ID
  final String? externalId; // URL or remote ID
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final DateTime? savedAt;

  const FavoriteArticleEntity({
    this.id,
    this.externalId,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.savedAt,
  });

  @override
  List<Object?> get props => [
        id,
        externalId,
        author,
        title,
        description,
        url,
        urlToImage,
        publishedAt,
        content,
        savedAt,
      ];
}
