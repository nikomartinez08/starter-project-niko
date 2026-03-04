import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/create_stream_usecase.dart';
import '../../domain/usecases/end_stream_usecase.dart';
import '../../domain/usecases/get_active_streams_usecase.dart';
import 'streaming_event.dart';
import 'streaming_state.dart';

class StreamingBloc extends Bloc<StreamingEvent, StreamingState> {
  final GetActiveStreamsUseCase _getActiveStreamsUseCase;
  final CreateStreamUseCase _createStreamUseCase;
  final EndStreamUseCase _endStreamUseCase;

  StreamingBloc(
    this._getActiveStreamsUseCase,
    this._createStreamUseCase,
    this._endStreamUseCase,
  ) : super(const StreamingInitial()) {
    on<LoadActiveStreams>(_onLoadActiveStreams);
    on<StartStream>(_onStartStream);
    on<EndStream>(_onEndStream);
  }

  Future<void> _onLoadActiveStreams(
      LoadActiveStreams event, Emitter<StreamingState> emit) async {
    emit(const StreamingLoading());
    try {
      final streams = await _getActiveStreamsUseCase.call();
      emit(ActiveStreamsLoaded(streams));
    } catch (e) {
      emit(StreamingError(e.toString()));
    }
  }

  Future<void> _onStartStream(
      StartStream event, Emitter<StreamingState> emit) async {
    emit(const StreamingLoading());
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        emit(const StreamingError('User not authenticated'));
        return;
      }
      final stream = await _createStreamUseCase.call(
        params: CreateStreamParams(
          title: event.title,
          hostId: user.id,
          hostName: user.userMetadata?['display_name'] ??
              user.email ??
              'Anonymous',
        ),
      );
      emit(StreamingActive(stream));
    } catch (e) {
      emit(StreamingError(e.toString()));
    }
  }

  Future<void> _onEndStream(
      EndStream event, Emitter<StreamingState> emit) async {
    try {
      await _endStreamUseCase.call(params: event.streamId);
      emit(const StreamingEnded());
    } catch (e) {
      emit(StreamingError(e.toString()));
    }
  }
}
