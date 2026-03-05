import 'package:equatable/equatable.dart';

class ArticleInput extends Equatable {
  final String? author;
  final String? title;
  final String? description;
  final String? content;
  final String? imagePath; // Path from ImagePicker

  const ArticleInput({
    this.author,
    this.title,
    this.description,
    this.content,
    this.imagePath,
  });

  @override
  List<Object?> get props => [author, title, description, content, imagePath];
}
