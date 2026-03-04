import '../../../../core/usecase/usecase.dart';
import '../entities/live_stream_entity.dart';
import '../repository/streaming_repository.dart';

class GetActiveStreamsUseCase implements UseCase<List<LiveStreamEntity>, void> {
  final StreamingRepository _repository;
  GetActiveStreamsUseCase(this._repository);

  @override
  Future<List<LiveStreamEntity>> call({void params}) {
    return _repository.getActiveStreams();
  }
}
