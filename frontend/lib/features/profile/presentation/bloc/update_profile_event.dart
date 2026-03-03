import '../../domain/entities/profile_entities.dart';
import 'profile_event.dart';

class UpdateProfileEvent extends ProfileEvent {
  final UserProfileDataEntity profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}
