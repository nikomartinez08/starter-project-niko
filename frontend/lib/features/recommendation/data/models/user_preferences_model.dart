import '../../domain/entities/user_preferences.dart';

class UserPreferencesModel extends UserPreferencesEntity {
  const UserPreferencesModel({
    super.likedCategories,
    super.dislikedCategories,
    super.tagScores,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      likedCategories: List<String>.from(json['liked_categories'] ?? []),
      dislikedCategories: List<String>.from(json['disliked_categories'] ?? []),
      tagScores: Map<String, int>.from(json['tag_scores'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liked_categories': likedCategories,
      'disliked_categories': dislikedCategories,
      'tag_scores': tagScores,
    };
  }
  
  factory UserPreferencesModel.fromEntity(UserPreferencesEntity entity) {
    return UserPreferencesModel(
      likedCategories: entity.likedCategories,
      dislikedCategories: entity.dislikedCategories,
      tagScores: entity.tagScores,
    );
  }
}
