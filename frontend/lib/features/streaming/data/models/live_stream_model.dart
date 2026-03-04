import '../../domain/entities/live_stream_entity.dart';

class LiveStreamModel extends LiveStreamEntity {
  const LiveStreamModel({
    super.id,
    super.channelName,
    super.hostId,
    super.hostName,
    super.title,
    super.thumbnailUrl,
    super.viewerCount,
    super.isLive,
    super.startedAt,
    super.endedAt,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      id: json['id'] as String?,
      channelName: json['channel_name'] as String?,
      hostId: json['host_id'] as String?,
      hostName: json['host_name'] as String?,
      title: json['title'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      viewerCount: json['viewer_count'] as int? ?? 0,
      isLive: json['is_live'] as bool? ?? false,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'channel_name': channelName,
        'host_id': hostId,
        'host_name': hostName,
        'title': title,
        'thumbnail_url': thumbnailUrl,
        'viewer_count': viewerCount,
        'is_live': isLive,
      };

  factory LiveStreamModel.fromEntity(LiveStreamEntity entity) {
    return LiveStreamModel(
      id: entity.id,
      channelName: entity.channelName,
      hostId: entity.hostId,
      hostName: entity.hostName,
      title: entity.title,
      thumbnailUrl: entity.thumbnailUrl,
      viewerCount: entity.viewerCount,
      isLive: entity.isLive,
      startedAt: entity.startedAt,
      endedAt: entity.endedAt,
    );
  }
}
