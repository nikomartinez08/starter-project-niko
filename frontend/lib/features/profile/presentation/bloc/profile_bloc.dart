import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_data.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileDataUseCase _getProfileDataUseCase;

  ProfileBloc(this._getProfileDataUseCase) : super(ProfileLoading()) {
    on<GetProfileEvent>(_onGetProfile);
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
}
