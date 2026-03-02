import '../../../daily_news/domain/entities/article.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repository/recommendation_repository.dart';
import '../data_sources/remote/recommendation_remote_data_source.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource _remoteDataSource;

  // Cache to avoid hitting firestore on every feed item update
  UserPreferencesEntity? _cachedPreferences;

  RecommendationRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> addDislike(String category, List<String> tags) async {
    final prefs = await getUserPreferences();

    // Add to disliked if not present, remove from liked if there
    final disliked = List<String>.from(prefs.dislikedCategories);
    final liked = List<String>.from(prefs.likedCategories);

    if (!disliked.contains(category)) disliked.add(category);
    liked.remove(category);

    final tagsScores = Map<String, int>.from(prefs.tagScores);
    for (var tag in tags) {
      tagsScores[tag] = (tagsScores[tag] ?? 0) - 1;
    }

    final newPrefs = prefs.copyWith(
      likedCategories: liked,
      dislikedCategories: disliked,
      tagScores: tagsScores,
    );

    _cachedPreferences = newPrefs;
    try {
      await _remoteDataSource.updatePreferences(newPrefs);
    } catch (_) {}
  }

  @override
  Future<void> addLike(String category, List<String> tags) async {
    final prefs = await getUserPreferences();

    final liked = List<String>.from(prefs.likedCategories);
    final disliked = List<String>.from(prefs.dislikedCategories);

    if (!liked.contains(category)) liked.add(category);
    disliked.remove(category);

    final tagsScores = Map<String, int>.from(prefs.tagScores);
    for (var tag in tags) {
      tagsScores[tag] = (tagsScores[tag] ?? 0) + 1;
    }

    final newPrefs = prefs.copyWith(
      likedCategories: liked,
      dislikedCategories: disliked,
      tagScores: tagsScores,
    );

    _cachedPreferences = newPrefs;
    try {
      await _remoteDataSource.updatePreferences(newPrefs);
    } catch (_) {}
  }

  @override
  Future<UserPreferencesEntity> getUserPreferences() async {
    if (_cachedPreferences != null) return _cachedPreferences!;
    try {
      _cachedPreferences = await _remoteDataSource.getPreferences();
      return _cachedPreferences!;
    } catch (_) {
      // Offline fallback
      return const UserPreferencesEntity();
    }
  }

  @override
  Future<List<ArticleEntity>> getPersonalizedFeed(
      List<ArticleEntity> rawArticles) async {
    final prefs = await getUserPreferences();

    // Sorting by score (and date inherently usually handled by API but we can sort by score)
    final List<Map<String, dynamic>> scoredArticles =
        rawArticles.map((article) {
      int score = 0;
      // Derive category and tags since ArticleEntity doesn't strictly have them
      // In a real app we'd map this properly, here we extrapolate from URL or title
      final title = (article.title ?? '').toLowerCase();
      final url = (article.url ?? '').toLowerCase();

      String derivedCategory = 'general';
      if (url.contains('tech') || title.contains('tech')) {
        derivedCategory = 'technology';
      } else if (url.contains('sport') || title.contains('sport')) {
        derivedCategory = 'sports';
      } else if (url.contains('politic') || title.contains('politic')) {
        derivedCategory = 'politics';
      } else if (url.contains('finance') || title.contains('market')) {
        derivedCategory = 'finance';
      }

      if (prefs.likedCategories.contains(derivedCategory)) {
        score += 2;
      }
      if (prefs.dislikedCategories.contains(derivedCategory)) {
        score -= 3;
      }

      // We can mock tags by splitting the title into words.
      final words = title.split(' ');
      for (var word in words) {
        if (word.length > 4 && prefs.tagScores.containsKey(word)) {
          score += (prefs.tagScores[word] ?? 0);
        }
      }

      return {
        'article': article,
        'score': score,
        'date': article.publishedAt,
      };
    }).toList();

    // Sort by score first, then by date as a fallback (assuming ISO8601 strings)
    scoredArticles.sort((a, b) {
      int scoreA = a['score'];
      int scoreB = b['score'];
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA); // Higher score first
      }

      String dateA = a['date'] ?? '';
      String dateB = b['date'] ?? '';
      return dateB.compareTo(dateA); // Newer date first
    });

    return scoredArticles.map((e) => e['article'] as ArticleEntity).toList();
  }
}
