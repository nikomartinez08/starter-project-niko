import 'package:equatable/equatable.dart';

class LiveStreamEntity extends Equatable {
  final String? id;
  final String? channelName;
  final String? hostId;
  final String? hostName;
  final String? title;
  final String? thumbnailUrl;
  final int? viewerCount;
  final bool? isLive;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const LiveStreamEntity({
    this.id,
    this.channelName,
    this.hostId,
    this.hostName,
    this.title,
    this.thumbnailUrl,
    this.viewerCount,
    this.isLive,
    this.startedAt,
    this.endedAt,
  });

  @override
  List<Object?> get props => [
        id, channelName, hostId, hostName, title,
        thumbnailUrl, viewerCount, isLive, startedAt, endedAt,
      ];
}
