import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../../../domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity> ? articles;
  final DioException ? error;

  const RemoteArticlesState({this.articles,this.error});

  @override
  List<Object> get props => [articles ?? [], error ?? ""];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  final bool hasMore;
  final String timestamp; // Force state change
  RemoteArticlesDone(List<ArticleEntity> article, {this.hasMore = true}) 
      : timestamp = DateTime.now().toIso8601String(),
        super(articles: article);

  @override
  List<Object> get props => [articles ?? [], hasMore, timestamp];
}

class RemoteArticlesLoadingMore extends RemoteArticlesDone {
  RemoteArticlesLoadingMore(super.articles, {super.hasMore});
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(DioException error) : super(error: error);
}
