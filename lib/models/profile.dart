import 'package:foyer/models/profile_settings.dart';

class DeviceProfile {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final ProfileSettings settings; // Add this line

  DeviceProfile({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.settings, // Add this line
  });

  factory DeviceProfile.fromJson(Map<String, dynamic> json) {
    return DeviceProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      settings: ProfileSettings.fromJson(json['settings']), // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'settings': settings.toJson(), // Add this line
    };
  }
}

