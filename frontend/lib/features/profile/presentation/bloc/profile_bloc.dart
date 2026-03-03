import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile_entities.dart';
import '../../domain/usecases/get_profile_data.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileDataUseCase _getProfileDataUseCase;

  ProfileBloc(this._getProfileDataUseCase) : super(ProfileLoading()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onGetProfile(GetProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    await emit.forEach<UserProfileDataEntity>(
      _getProfileDataUseCase(),
      onData: (profile) => ProfileLoaded(profile),
      onError: (error, stackTrace) => ProfileError(error.toString()),
    );
  }

  void _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) {
    emit(ProfileLoaded(event.profile));
  }
}
