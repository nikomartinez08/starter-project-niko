import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/live_stream_model.dart';
import 'streaming_remote_data_source.dart';

class StreamingSupabaseServiceImpl implements StreamingRemoteDataSource {
  final SupabaseClient _supabaseClient;
  StreamingSupabaseServiceImpl(this._supabaseClient);

  @override
  Future<LiveStreamModel> createStream(LiveStreamModel stream) async {
    // End any stale live streams before starting a new one
    if (stream.hostId != null) {
      await _supabaseClient
          .from('live_streams')
          .update({
            'is_live': false,
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('host_id', stream.hostId!)
          .eq('is_live', true);
    }

    final response = await _supabaseClient
        .from('live_streams')
        .insert(stream.toJson())
        .select()
        .single();
    return LiveStreamModel.fromJson(response);
  }

  @override
  Future<void> endStream(String streamId) async {
    await _supabaseClient
        .from('live_streams')
        .update({
          'is_live': false,
          'ended_at': DateTime.now().toIso8601String(),
        })
        .eq('id', streamId);
  }

  @override
  Future<List<LiveStreamModel>> getActiveStreams() async {
    final response = await _supabaseClient
        .from('live_streams')
        .select()
        .eq('is_live', true)
        .order('started_at', ascending: false);
    return (response as List)
        .map((json) => LiveStreamModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateViewerCount(String streamId, int delta) async {
    final current = await _supabaseClient
        .from('live_streams')
        .select('viewer_count')
        .eq('id', streamId)
        .single();
    final newCount = ((current['viewer_count'] as int?) ?? 0) + delta;
    await _supabaseClient
        .from('live_streams')
        .update({'viewer_count': newCount < 0 ? 0 : newCount})
        .eq('id', streamId);
  }

  @override
  Future<LiveStreamModel?> getStreamById(String streamId) async {
    final response = await _supabaseClient
        .from('live_streams')
        .select()
        .eq('id', streamId)
        .maybeSingle();
    if (response == null) return null;
    return LiveStreamModel.fromJson(response);
  }
}
