import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? name;
  final String? title;
  final String? photoUrl;

  const UpdateProfileEvent({this.name, this.title, this.photoUrl});

  @override
  List<Object?> get props => [name, title, photoUrl];
}
