import '../../../../core/usecase/usecase.dart';
import '../repository/streaming_repository.dart';

class GetStreamTokenParams {
  final String channelName;
  final int uid;
  final bool isBroadcaster;

  const GetStreamTokenParams({
    required this.channelName,
    required this.uid,
    required this.isBroadcaster,
  });
}

class GetStreamTokenUseCase implements UseCase<String?, GetStreamTokenParams> {
  final StreamingRepository _repository;
  GetStreamTokenUseCase(this._repository);

  @override
  Future<String?> call({GetStreamTokenParams? params}) {
    return _repository.getStreamToken(
      channelName: params!.channelName,
      uid: params.uid,
      isBroadcaster: params.isBroadcaster,
    );
  }
}
