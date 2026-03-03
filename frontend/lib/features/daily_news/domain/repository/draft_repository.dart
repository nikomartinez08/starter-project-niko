import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';

abstract class DraftRepository {
  Future<List<DraftEntity>> getDrafts();
  Future<DraftEntity?> getDraftById(int id);
  Future<int> saveDraft(DraftEntity draft);
  Future<void> updateDraft(DraftEntity draft);
  Future<void> deleteDraft(int id);
}
