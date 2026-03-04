import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/data_sources/local/agora_service.dart';
import '../../domain/entities/live_stream_entity.dart';
import '../bloc/streaming_bloc.dart';
import '../bloc/streaming_event.dart';
import '../bloc/streaming_state.dart';
import '../../../../injection_container.dart';

class BroadcasterScreen extends StatefulWidget {
  const BroadcasterScreen({Key? key}) : super(key: key);

  @override
  State<BroadcasterScreen> createState() => _BroadcasterScreenState();
}

class _BroadcasterScreenState extends State<BroadcasterScreen> {
  final _titleController = TextEditingController();
  final _agoraService = sl<AgoraService>();
  bool _isPreview = true;
  bool _isInitialized = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  LiveStreamEntity? _activeStream;
  int _viewerCount = 0;

  static const _surface = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.camera, Permission.microphone].request();

    await _agoraService.initialize();

    _agoraService.engine!.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() => _viewerCount++);
        },
        onUserOffline: (connection, remoteUid, reason) {
          if (_viewerCount > 0) setState(() => _viewerCount--);
        },
        onError: (err, msg) {
          debugPrint('Agora error: $err - $msg');
        },
      ),
    );

    await _agoraService.engine!.startPreview();
    setState(() => _isInitialized = true);
  }

  Future<void> _goLive() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter a title for your stream',
              style: TextStyle(color: Colors.white)),
          backgroundColor: _surface,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    context.read<StreamingBloc>().add(StartStream(title));
  }

  Future<void> _endStream() async {
    if (_activeStream?.id != null) {
      context.read<StreamingBloc>().add(EndStream(_activeStream!.id!));
    }
    await _agoraService.leaveChannel();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StreamingBloc, StreamingState>(
      listener: (context, state) async {
        if (state is StreamingActive) {
          _activeStream = state.stream;
          await _agoraService.joinChannel(
            channelName: state.stream.channelName!,
            token: null,
            uid: 0,
            isBroadcaster: true,
          );
          setState(() => _isPreview = false);
        } else if (state is StreamingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red[900],
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            if (_isInitialized)
              AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _agoraService.engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 12,
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
                    GestureDetector(
                      onTap: () async {
                        if (!_isPreview && _activeStream != null) {
                          await _endStream();
                        } else {
                          await _agoraService.dispose();
                          if (mounted) Navigator.of(context).pop();
                        }
                      },
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
                    const SizedBox(width: 12),
                    if (!_isPreview) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
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
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
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
                    ],
                  ],
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: _isPreview ? _buildPreviewControls() : _buildLiveControls(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title input
        TextField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: "What's your stream about?",
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
            filled: true,
            fillColor: _surface.withValues(alpha: 0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          keyboardAppearance: Brightness.dark,
        ),
        const SizedBox(height: 16),
        // Go live button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _goLive,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text('Go Live',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _controlButton(
          icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
          label: _isCameraOff ? 'Camera Off' : 'Camera',
          onTap: () {
            setState(() => _isCameraOff = !_isCameraOff);
            _agoraService.muteVideo(_isCameraOff);
          },
        ),
        _controlButton(
          icon: _isMuted ? Icons.mic_off : Icons.mic,
          label: _isMuted ? 'Muted' : 'Mic',
          onTap: () {
            setState(() => _isMuted = !_isMuted);
            _agoraService.muteAudio(_isMuted);
          },
        ),
        _controlButton(
          icon: Icons.cameraswitch_rounded,
          label: 'Flip',
          onTap: () => _agoraService.switchCamera(),
        ),
        _controlButton(
          icon: Icons.stop_circle_outlined,
          label: 'End',
          color: Colors.red,
          onTap: _endStream,
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
