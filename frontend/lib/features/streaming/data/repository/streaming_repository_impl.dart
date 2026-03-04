import 'package:uuid/uuid.dart';
import '../../domain/entities/live_stream_entity.dart';
import '../../domain/repository/streaming_repository.dart';
import '../data_sources/remote/streaming_remote_data_source.dart';
import '../models/live_stream_model.dart';

class StreamingRepositoryImpl implements StreamingRepository {
  final StreamingRemoteDataSource _remoteDataSource;
  StreamingRepositoryImpl(this._remoteDataSource);

  @override
  Future<LiveStreamEntity> createStream({
    required String title,
    required String hostId,
    required String hostName,
    String? thumbnailUrl,
  }) async {
    final channelName = const Uuid().v4().replaceAll('-', '');
    final model = LiveStreamModel(
      channelName: channelName,
      hostId: hostId,
      hostName: hostName,
      title: title,
      thumbnailUrl: thumbnailUrl,
      viewerCount: 0,
      isLive: true,
    );
    return _remoteDataSource.createStream(model);
  }

  @override
  Future<void> endStream(String streamId) =>
      _remoteDataSource.endStream(streamId);

  @override
  Future<List<LiveStreamEntity>> getActiveStreams() =>
      _remoteDataSource.getActiveStreams();

  @override
  Future<String?> getStreamToken({
    required String channelName,
    required int uid,
    required bool isBroadcaster,
  }) async {
    // DEV: return null to use App ID only (no token needed)
    // PROD: call Supabase Edge Function here for token generation
    return null;
  }

  @override
  Future<void> updateViewerCount(String streamId, int delta) =>
      _remoteDataSource.updateViewerCount(streamId, delta);
}
