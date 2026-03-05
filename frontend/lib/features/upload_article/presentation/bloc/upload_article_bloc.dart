import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/upload_article_usecase.dart';
import 'upload_article_event.dart';
import 'upload_article_state.dart';

class UploadArticleBloc extends Bloc<UploadArticleEvent, UploadArticleState> {
  final UploadArticleUseCase _uploadArticleUseCase;

  UploadArticleBloc(this._uploadArticleUseCase) : super(const UploadArticleInitial()) {
    on<UploadArticleRequested>(_onUploadArticle);
  }

  void _onUploadArticle(UploadArticleRequested event, Emitter<UploadArticleState> emit) async {
    emit(const UploadArticleLoading());
    try {
      await _uploadArticleUseCase(params: event.articleInput);
      emit(const UploadArticleSuccess());
    } catch (e) {
      emit(UploadArticleError(e.toString()));
    }
  }
}
