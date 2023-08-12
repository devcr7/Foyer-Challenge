import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:foyer/models/profile.dart';
import 'package:foyer/models/profile_settings.dart';
import 'package:foyer/services/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<LoadProfiles>((event, emit) async {
      final profiles = await profileRepository.getProfiles();
      emit(ProfilesLoaded(profiles));
    });

    on<CreateProfile>((event, emit) async {
      try {
        final newProfile = DeviceProfile(
          id: DateTime.now().toString(),
          name: event.name,
          latitude: event.latitude,
          longitude: event.longitude,
          settings: event.settings, // Use settings from the event
        );

        await profileRepository.createProfile(newProfile);
        final profiles = await profileRepository.getProfiles();
        emit(ProfilesLoaded(profiles));
      } catch (e) {
        emit(ProfileError('Failed to create profile'));
      }
    });
  }
}