import '../../../../domain/entities/article.dart';

abstract class RemoteArticlesEvent {
  const RemoteArticlesEvent();
}

class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

class LoadMoreArticles extends RemoteArticlesEvent {
  const LoadMoreArticles();
}

class RefreshArticles extends RemoteArticlesEvent {
  const RefreshArticles();
}

class SwipeArticleEvent extends RemoteArticlesEvent {
  final ArticleEntity article;
  final bool isLike;
  const SwipeArticleEvent(this.article, this.isLike);
}

class FilterArticles extends RemoteArticlesEvent {
  final String category;
  const FilterArticles(this.category);
}

class ResetFilter extends RemoteArticlesEvent {
  const ResetFilter();
}
