import '../../../../core/usecase/usecase.dart';
import '../entities/live_stream_entity.dart';
import '../repository/streaming_repository.dart';

class GetStreamByIdUseCase implements UseCase<LiveStreamEntity?, String> {
  final StreamingRepository _repository;
  GetStreamByIdUseCase(this._repository);

  @override
  Future<LiveStreamEntity?> call({String? params}) {
    return _repository.getStreamById(params!);
  }
}
