import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';

class GetDraftsUseCase implements UseCase<List<DraftEntity>, void> {
  final DraftRepository _draftRepository;

  GetDraftsUseCase(this._draftRepository);

  @override
  Future<List<DraftEntity>> call({void params}) {
    return _draftRepository.getDrafts();
  }
}
