import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';

class SaveDraftUseCase implements UseCase<int, DraftEntity> {
  final DraftRepository _draftRepository;

  SaveDraftUseCase(this._draftRepository);

  @override
  Future<int> call({DraftEntity? params}) {
    return _draftRepository.saveDraft(params!);
  }
}
