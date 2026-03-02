import 'package:equatable/equatable.dart';

class UserPreferencesEntity extends Equatable {
  final List<String> likedCategories;
  final List<String> dislikedCategories;
  final Map<String, int> tagScores;

  const UserPreferencesEntity({
    this.likedCategories = const [],
    this.dislikedCategories = const [],
    this.tagScores = const {},
  });

  @override
  List<Object?> get props => [likedCategories, dislikedCategories, tagScores];

  UserPreferencesEntity copyWith({
    List<String>? likedCategories,
    List<String>? dislikedCategories,
    Map<String, int>? tagScores,
  }) {
    return UserPreferencesEntity(
      likedCategories: likedCategories ?? this.likedCategories,
      dislikedCategories: dislikedCategories ?? this.dislikedCategories,
      tagScores: tagScores ?? this.tagScores,
    );
  }
}
