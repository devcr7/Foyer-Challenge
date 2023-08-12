import 'package:flutter/material.dart';

class ProfileSettings {
  final Color themeColor;
  final double textSize;
  final bool receiveNotifications;
  final double vibrationIntensity;

  ProfileSettings({
    required this.themeColor,
    required this.textSize,
    required this.receiveNotifications,
    required this.vibrationIntensity,
  });

  factory ProfileSettings.fromJson(Map<String, dynamic> json) {
    return ProfileSettings(
      themeColor: Color(json['themeColor']),
      textSize: json['textSize'],
      receiveNotifications: json['receiveNotifications'],
      vibrationIntensity: json['vibrationIntensity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeColor': themeColor.value,
      'textSize': textSize,
      'receiveNotifications': receiveNotifications,
      'vibrationIntensity': vibrationIntensity,
    };
  }
}
