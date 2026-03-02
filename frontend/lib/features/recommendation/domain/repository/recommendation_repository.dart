import '../../../daily_news/domain/entities/article.dart';
import '../entities/user_preferences.dart';

abstract class RecommendationRepository {
  Future<UserPreferencesEntity> getUserPreferences();
  
  /// Swipe left (dislike a category/tag)
  Future<void> addDislike(String category, List<String> tags);
  
  /// Swipe right (like a category/tag)
  Future<void> addLike(String category, List<String> tags);

  /// Get personalized feed by scoring articles against preferences
  Future<List<ArticleEntity>> getPersonalizedFeed(List<ArticleEntity> rawArticles);
}
