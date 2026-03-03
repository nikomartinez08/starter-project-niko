import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/draft.dart';

@dao
abstract class DraftDao {
  @Query('SELECT * FROM draft ORDER BY updatedAt DESC')
  Future<List<DraftModel>> getDrafts();

  @Query('SELECT * FROM draft WHERE id = :id')
  Future<DraftModel?> getDraftById(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertDraft(DraftModel draft);

  @Update()
  Future<void> updateDraft(DraftModel draft);

  @Query('DELETE FROM draft WHERE id = :id')
  Future<void> deleteDraftById(int id);
}
