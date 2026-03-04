import '../entities/live_stream_entity.dart';

abstract class StreamingRepository {
  Future<LiveStreamEntity> createStream({
    required String title,
    required String hostId,
    required String hostName,
    String? thumbnailUrl,
  });
  Future<void> endStream(String streamId);
  Future<List<LiveStreamEntity>> getActiveStreams();
  Future<String?> getStreamToken({
    required String channelName,
    required int uid,
    required bool isBroadcaster,
  });
  Future<void> updateViewerCount(String streamId, int delta);
  Future<LiveStreamEntity?> getStreamById(String streamId);
}
