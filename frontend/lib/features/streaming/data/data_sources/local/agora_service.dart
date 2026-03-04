import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/constants/constants.dart';

class AgoraService {
  RtcEngine? _engine;

  RtcEngine? get engine => _engine;
  bool get isInitialized => _engine != null;

  Future<void> initialize() async {
    debugPrint('[Agora] Creating engine...');
    _engine = createAgoraRtcEngine();
    debugPrint('[Agora] Initializing with appId: ${agoraAppId.substring(0, 8)}...');
    await _engine!.initialize(const RtcEngineContext(
      appId: agoraAppId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    debugPrint('[Agora] Engine initialized');
    await _engine!.enableVideo();
    debugPrint('[Agora] Video enabled');
    await _engine!.enableAudio();
    debugPrint('[Agora] Audio enabled');
  }

  Future<void> joinChannel({
    required String channelName,
    required String? token,
    required int uid,
    required bool isBroadcaster,
  }) async {
    debugPrint('[Agora] joinChannel: channel=$channelName, token=${token ?? "null"}, uid=$uid, broadcaster=$isBroadcaster');
    if (isBroadcaster) {
      await _engine!.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );
      await _engine!.startPreview();
    } else {
      await _engine!.setClientRole(
        role: ClientRoleType.clientRoleAudience,
      );
    }

    await _engine!.joinChannel(
      token: token ?? '',
      channelId: channelName,
      uid: uid,
      options: ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: isBroadcaster,
        publishMicrophoneTrack: isBroadcaster,
        clientRoleType: isBroadcaster
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }

  Future<void> muteAudio(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }

  Future<void> muteVideo(bool muted) async {
    await _engine?.muteLocalVideoStream(muted);
  }

  Future<void> dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }
}
