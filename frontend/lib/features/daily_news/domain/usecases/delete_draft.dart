import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';

class DeleteDraftUseCase implements UseCase<void, int> {
  final DraftRepository _draftRepository;

  DeleteDraftUseCase(this._draftRepository);

  @override
  Future<void> call({int? params}) {
    return _draftRepository.deleteDraft(params!);
  }
}
