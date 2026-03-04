import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../../features/streaming/domain/usecases/get_stream_by_id_usecase.dart';

class DeepLinkService {
  final AppLinks _appLinks;
  final GetStreamByIdUseCase _getStreamByIdUseCase;
  final GlobalKey<NavigatorState> navigatorKey;
  StreamSubscription? _sub;

  DeepLinkService({
    required this.navigatorKey,
    required GetStreamByIdUseCase getStreamByIdUseCase,
  })  : _appLinks = AppLinks(),
        _getStreamByIdUseCase = getStreamByIdUseCase;

  Future<void> init() async {
    // Handle link that launched the app (cold start)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);

    // Handle links while app is running (warm start)
    _sub = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    // Expected format: newsapp://stream/{streamId}
    if (uri.host == 'stream' && uri.pathSegments.isNotEmpty) {
      final streamId = uri.pathSegments.first;
      _navigateToStream(streamId);
    }
  }

  Future<void> _navigateToStream(String streamId) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    try {
      final stream = await _getStreamByIdUseCase.call(params: streamId);
      if (stream == null) {
        _showSnackBar('Stream not found');
        return;
      }
      if (stream.isLive != true) {
        _showSnackBar('This stream has ended');
        return;
      }
      navigatorKey.currentState?.pushNamed('/ViewerScreen', arguments: stream);
    } catch (e) {
      _showSnackBar('Could not open stream');
    }
  }

  void _showSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
