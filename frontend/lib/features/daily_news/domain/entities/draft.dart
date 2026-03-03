import 'package:equatable/equatable.dart';

class DraftEntity extends Equatable {
  final int? id;
  final String? author;
  final String? title;
  final String? content;
  final String? imagePath;
  final String? createdAt;
  final String? updatedAt;

  const DraftEntity({
    this.id,
    this.author,
    this.title,
    this.content,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, author, title, content, imagePath, createdAt, updatedAt];
}
