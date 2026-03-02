import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_article.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class GetFavorites extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final FavoriteArticleEntity article;

  const ToggleFavoriteEvent(this.article);

  @override
  List<Object?> get props => [article];
}
