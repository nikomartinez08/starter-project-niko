import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/draft_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';

class DraftRepositoryImpl implements DraftRepository {
  final DraftDao _draftDao;

  DraftRepositoryImpl(this._draftDao);

  @override
  Future<List<DraftEntity>> getDrafts() {
    return _draftDao.getDrafts();
  }

  @override
  Future<DraftEntity?> getDraftById(int id) {
    return _draftDao.getDraftById(id);
  }

  @override
  Future<int> saveDraft(DraftEntity draft) {
    return _draftDao.insertDraft(DraftModel.fromEntity(draft));
  }

  @override
  Future<void> updateDraft(DraftEntity draft) {
    return _draftDao.updateDraft(DraftModel.fromEntity(draft));
  }

  @override
  Future<void> deleteDraft(int id) {
    return _draftDao.deleteDraftById(id);
  }
}
