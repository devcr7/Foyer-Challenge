import 'dart:convert';

import 'package:foyer/models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  static const String _profileKey = 'profiles';

  Future<List<DeviceProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getStringList(_profileKey) ?? [];
    final profiles = profilesJson.map((json) => DeviceProfile.fromJson(jsonDecode(json))).toList();
    return profiles;
  }

  Future<void> createProfile(DeviceProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getProfiles();
    profiles.add(profile);
    final profilesJson = profiles.map((profile) => jsonEncode(profile.toJson())).toList();
    prefs.setStringList(_profileKey, profilesJson);
  }
}
