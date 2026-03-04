import '../../../../core/usecase/usecase.dart';
import '../repository/streaming_repository.dart';

class EndStreamUseCase implements UseCase<void, String> {
  final StreamingRepository _repository;
  EndStreamUseCase(this._repository);

  @override
  Future<void> call({String? params}) {
    return _repository.endStream(params!);
  }
}
