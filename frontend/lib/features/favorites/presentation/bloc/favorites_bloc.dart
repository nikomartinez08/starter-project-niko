import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/toggle_favorite.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase _getFavoritesUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  FavoritesBloc(this._getFavoritesUseCase, this._toggleFavoriteUseCase)
      : super(FavoritesLoading()) {
    on<GetFavorites>(_onGetFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onGetFavorites(
    GetFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites = await _getFavoritesUseCase.call();
      if (favorites.isEmpty) {
        emit(FavoritesEmpty());
      } else {
        emit(FavoritesLoaded(favorites));
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _toggleFavoriteUseCase.call(params: event.article);
      // Reload favorites after toggling
      add(GetFavorites());
    } catch (e) {
      // In a real app we might just emit a specific error or show a snackbar
      emit(FavoritesError("Failed to toggle favorite: ${e.toString()}"));
    }
  }
}
