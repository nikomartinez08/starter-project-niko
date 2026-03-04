import 'package:equatable/equatable.dart';

abstract class StreamingEvent extends Equatable {
  const StreamingEvent();
  @override
  List<Object?> get props => [];
}

class LoadActiveStreams extends StreamingEvent {
  const LoadActiveStreams();
}

class StartStream extends StreamingEvent {
  final String title;
  const StartStream(this.title);
  @override
  List<Object?> get props => [title];
}

class EndStream extends StreamingEvent {
  final String streamId;
  const EndStream(this.streamId);
  @override
  List<Object?> get props => [streamId];
}
