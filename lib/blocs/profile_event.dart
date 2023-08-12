part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfiles extends ProfileEvent {}

class CreateProfile extends ProfileEvent {
  final String name;
  final double latitude;
  final double longitude;
  final ProfileSettings settings; // Add this line

  CreateProfile({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.settings, // Add this line
  });

  @override
  List<Object> get props => [name, latitude, longitude, settings]; // Add settings here
}

class CreateProfileWithSettings extends ProfileEvent {
  final DeviceProfile profile;

  CreateProfileWithSettings(this.profile);

  @override
  List<Object> get props => [profile];
}


