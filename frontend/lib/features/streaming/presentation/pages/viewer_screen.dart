import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import '../../data/data_sources/local/agora_service.dart';
import '../../domain/entities/live_stream_entity.dart';
import '../../domain/repository/streaming_repository.dart';
import '../../../../injection_container.dart';

class ViewerScreen extends StatefulWidget {
  final LiveStreamEntity stream;
  const ViewerScreen({Key? key, required this.stream}) : super(key: key);

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  final _agoraService = sl<AgoraService>();
  final _repository = sl<StreamingRepository>();
  int? _remoteUid;
  bool _isJoined = false;
  int _viewerCount = 0;

  @override
  void initState() {
    super.initState();
    _viewerCount = widget.stream.viewerCount ?? 0;
    _initAndJoin();
  }

  Future<void> _initAndJoin() async {
    await _agoraService.initialize();

    _agoraService.engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() => _isJoined = true);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            if (_remoteUid == remoteUid) _remoteUid = null;
          });
        },
        onError: (err, msg) {
          debugPrint('Agora viewer error: $err - $msg');
        },
      ),
    );

    await _agoraService.joinChannel(
      channelName: widget.stream.channelName!,
      token: null,
      uid: 0,
      isBroadcaster: false,
    );

    // Increment viewer count
    if (widget.stream.id != null) {
      _repository.updateViewerCount(widget.stream.id!, 1);
      setState(() => _viewerCount++);
    }
  }

  Future<void> _leave() async {
    // Decrement viewer count
    if (widget.stream.id != null) {
      _repository.updateViewerCount(widget.stream.id!, -1);
    }
    await _agoraService.dispose();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Remote video
          if (_remoteUid != null)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _agoraService.engine!,
                canvas: VideoCanvas(uid: _remoteUid!),
                connection:
                    RtcConnection(channelId: widget.stream.channelName!),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isJoined) ...[
                    Icon(Icons.videocam_off_rounded,
                        size: 48, color: Colors.grey[700]),
                    const SizedBox(height: 16),
                    Text(
                      'Waiting for broadcaster...',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ] else
                    const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                ],
              ),
            ),

          // Top bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Host info
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.stream.hostName ?? 'Host',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Live badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('LIVE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  // Viewer count
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('$_viewerCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Close button
                  GestureDetector(
                    onTap: _leave,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom title overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 20,
                right: 20,
                top: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Text(
                widget.stream.title ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
