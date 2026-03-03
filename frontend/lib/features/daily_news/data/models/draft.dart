import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';

@Entity(tableName: 'draft')
class DraftModel extends DraftEntity {
  @PrimaryKey(autoGenerate: true)
  @override
  final int? id;

  const DraftModel({
    this.id,
    String? author,
    String? title,
    String? content,
    String? imagePath,
    String? createdAt,
    String? updatedAt,
  }) : super(
          author: author,
          title: title,
          content: content,
          imagePath: imagePath,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory DraftModel.fromEntity(DraftEntity entity) {
    return DraftModel(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      content: entity.content,
      imagePath: entity.imagePath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
