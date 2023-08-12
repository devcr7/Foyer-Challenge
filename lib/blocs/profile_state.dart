part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfilesLoaded extends ProfileState {
  final List<DeviceProfile> profiles;

  ProfilesLoaded(this.profiles);

  @override
  List<Object> get props => [profiles];
}

class ProfileCreated extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object> get props => [message];
}
