import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/live_stream_entity.dart';

Future<void> shareStream(LiveStreamEntity stream) async {
  if (stream.id == null) return;
  final link = 'newsapp://stream/${stream.id}';
  try {
    await Share.share(
      'Watch "${stream.title}" live!\n$link',
      subject: stream.title ?? 'Live Stream',
    );
  } catch (e) {
    debugPrint('Share failed: $e');
  }
}
