import 'package:equatable/equatable.dart';
import '../../domain/entities/live_stream_entity.dart';

abstract class StreamingState extends Equatable {
  const StreamingState();
  @override
  List<Object?> get props => [];
}

class StreamingInitial extends StreamingState {
  const StreamingInitial();
}

class StreamingLoading extends StreamingState {
  const StreamingLoading();
}

class ActiveStreamsLoaded extends StreamingState {
  final List<LiveStreamEntity> streams;
  const ActiveStreamsLoaded(this.streams);
  @override
  List<Object?> get props => [streams];
}

class StreamingActive extends StreamingState {
  final LiveStreamEntity stream;
  const StreamingActive(this.stream);
  @override
  List<Object?> get props => [stream];
}

class StreamingEnded extends StreamingState {
  const StreamingEnded();
}

class StreamingError extends StreamingState {
  final String message;
  const StreamingError(this.message);
  @override
  List<Object?> get props => [message];
}
