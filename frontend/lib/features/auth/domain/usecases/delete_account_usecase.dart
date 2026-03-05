import '../../../../core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountUseCase implements UseCase<void, void> {
  final AuthRepository _authRepository;
  final ArticleRepository _articleRepository;

  DeleteAccountUseCase(this._authRepository, this._articleRepository);

  @override
  Future<void> call({void params}) async {
    // 1. Delete user data (Cascade)
    try {
      await _articleRepository.deleteAllMyArticles();
    } catch (_) {
      // Continue deleting account even if data cleanup fails partially
    }
    // 2. Delete auth account
    return _authRepository.deleteAccount();
  }
}
