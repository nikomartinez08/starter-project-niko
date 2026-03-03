import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';

class UpdateDraftUseCase implements UseCase<void, DraftEntity> {
  final DraftRepository _draftRepository;

  UpdateDraftUseCase(this._draftRepository);

  @override
  Future<void> call({DraftEntity? params}) {
    return _draftRepository.updateDraft(params!);
  }
}
