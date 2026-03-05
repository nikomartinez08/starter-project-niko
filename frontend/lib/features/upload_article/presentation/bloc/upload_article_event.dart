import 'package:equatable/equatable.dart';
import '../../domain/entities/article_input.dart';

abstract class UploadArticleEvent extends Equatable {
  const UploadArticleEvent();

  @override
  List<Object?> get props => [];
}

class UploadArticleRequested extends UploadArticleEvent {
  final ArticleInput articleInput;

  const UploadArticleRequested(this.articleInput);

  @override
  List<Object?> get props => [articleInput];
}
