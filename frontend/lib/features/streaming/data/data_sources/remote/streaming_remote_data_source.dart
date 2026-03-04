import '../../models/live_stream_model.dart';

abstract class StreamingRemoteDataSource {
  Future<LiveStreamModel> createStream(LiveStreamModel stream);
  Future<void> endStream(String streamId);
  Future<List<LiveStreamModel>> getActiveStreams();
  Future<void> updateViewerCount(String streamId, int delta);
  Future<LiveStreamModel?> getStreamById(String streamId);
}
