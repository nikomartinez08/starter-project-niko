import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_drafts.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_draft.dart';
import 'draft_state.dart';

class DraftCubit extends Cubit<DraftState> {
  final GetDraftsUseCase _getDraftsUseCase;
  final SaveDraftUseCase _saveDraftUseCase;
  final UpdateDraftUseCase _updateDraftUseCase;
  final DeleteDraftUseCase _deleteDraftUseCase;

  DraftCubit(
    this._getDraftsUseCase,
    this._saveDraftUseCase,
    this._updateDraftUseCase,
    this._deleteDraftUseCase,
  ) : super(const DraftInitial());

  Future<void> loadDrafts() async {
    emit(const DraftsLoading());
    try {
      final drafts = await _getDraftsUseCase.call();
      emit(DraftsLoaded(drafts));
    } catch (e) {
      emit(DraftError(e.toString()));
    }
  }

  Future<int> saveDraft(DraftEntity draft) async {
    try {
      final id = await _saveDraftUseCase.call(params: draft);
      emit(DraftSaved(id));
      return id;
    } catch (e) {
      emit(DraftError(e.toString()));
      return -1;
    }
  }

  Future<void> updateDraft(DraftEntity draft) async {
    try {
      await _updateDraftUseCase.call(params: draft);
      emit(DraftSaved(draft.id!));
    } catch (e) {
      emit(DraftError(e.toString()));
    }
  }

  Future<void> deleteDraft(int id) async {
    try {
      await _deleteDraftUseCase.call(params: id);
      emit(const DraftDeleted());
      await loadDrafts();
    } catch (e) {
      emit(DraftError(e.toString()));
    }
  }
}
