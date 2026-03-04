import '../../../../core/usecase/usecase.dart';
import '../entities/live_stream_entity.dart';
import '../repository/streaming_repository.dart';

class CreateStreamParams {
  final String title;
  final String hostId;
  final String hostName;
  final String? thumbnailUrl;

  const CreateStreamParams({
    required this.title,
    required this.hostId,
    required this.hostName,
    this.thumbnailUrl,
  });
}

class CreateStreamUseCase implements UseCase<LiveStreamEntity, CreateStreamParams> {
  final StreamingRepository _repository;
  CreateStreamUseCase(this._repository);

  @override
  Future<LiveStreamEntity> call({CreateStreamParams? params}) {
    return _repository.createStream(
      title: params!.title,
      hostId: params.hostId,
      hostName: params.hostName,
      thumbnailUrl: params.thumbnailUrl,
    );
  }
}
