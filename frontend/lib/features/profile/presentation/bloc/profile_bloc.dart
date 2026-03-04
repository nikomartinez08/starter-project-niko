import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_data.dart';
import '../../domain/usecases/update_profile_data.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileDataUseCase _getProfileDataUseCase;
  final UpdateProfileDataUseCase _updateProfileDataUseCase;

  ProfileBloc(this._getProfileDataUseCase, this._updateProfileDataUseCase) : super(ProfileLoading()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onGetProfile(GetProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final profile = await _getProfileDataUseCase.call();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    // Keep current state to optimistically update or revert
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileLoading());
      try {
        await _updateProfileDataUseCase.call(
          name: event.name,
          title: event.title,
          photoUrl: event.photoUrl,
        );
        // Fetch fresh data after update to ensure consistency
        add(GetProfileEvent());
      } catch (e) {
        emit(ProfileError(e.toString()));
        // Optionally emit the previous loaded state if needed, or just show error
      }
    }
  }
}
