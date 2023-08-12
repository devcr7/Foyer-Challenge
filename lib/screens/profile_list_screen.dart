import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foyer/blocs/profile_bloc.dart';
import 'package:foyer/models/profile.dart';
import 'package:foyer/models/profile_settings.dart';
import 'package:foyer/services/profile_repository.dart';
import 'package:shimmer/shimmer.dart';

class ProfileListScreen extends StatefulWidget {
  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  late ProfileRepository profileRepository;
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    profileRepository = ProfileRepository();
    _profileBloc = ProfileBloc(profileRepository: profileRepository);
    _profileBloc.add(LoadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _profileBloc, 
      child: Scaffold(
        appBar: AppBar(
          title: Text('Location Profiles'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ProfileListScreenView(),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => ProfileCreationDialog(_profileBloc),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Add Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _profileBloc.close(); // Close the bloc when disposing
    super.dispose();
  }
}

class ProfileCreationDialog extends StatefulWidget {
  ProfileBloc profileBloc;

  ProfileCreationDialog(this.profileBloc);

  @override
  _ProfileCreationDialogState createState() => _ProfileCreationDialogState();
}

class _ProfileCreationDialogState extends State<ProfileCreationDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isCheckingDuplicate = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AlertDialog(
        title: Text('Create New Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _latitudeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _longitudeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: _isCheckingDuplicate
                ? null
                : () async {
              final name = _nameController.text;
              final latitude =
                  double.tryParse(_latitudeController.text) ?? 0.0;
              final longitude =
                  double.tryParse(_longitudeController.text) ?? 0.0;

              if (latitude != 0.0 && longitude != 0.0 && name.isNotEmpty) {
                setState(() {
                  _isCheckingDuplicate = true;
                });

                final existingProfiles =
                await widget.profileBloc.profileRepository.getProfiles();

                if (_isDuplicateProfile(
                    existingProfiles, latitude, longitude)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile already exists.')),
                  );
                } else {
                  Navigator.of(context).pop(); // Close this dialog
                  showDialog(
                    context: context,
                    builder: (ctx) => ProfileCreationWithSettingsDialog(
                      profileBloc: widget.profileBloc,
                      name: name,
                      latitude: latitude,
                      longitude: longitude,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid input')),
                );
              }
            },
            child: _isCheckingDuplicate
                ? CircularProgressIndicator()
                : Text('Create'),
          ),
        ],
      ),
    );
  }

  bool _isDuplicateProfile(
      List<DeviceProfile> profiles, double latitude, double longitude) {
    return profiles.any(
            (profile) => profile.latitude == latitude && profile.longitude == longitude);
  }
}

class ProfileCreationWithSettingsDialog extends StatefulWidget {
  final ProfileBloc profileBloc;
  final String name;
  final double latitude;
  final double longitude;

  ProfileCreationWithSettingsDialog({
    required this.profileBloc,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  _ProfileCreationWithSettingsDialogState createState() =>
      _ProfileCreationWithSettingsDialogState();
}

class _ProfileCreationWithSettingsDialogState
    extends State<ProfileCreationWithSettingsDialog> {
  // State variables for additional settings
  Color _selectedColor = Colors.blue;
  double _selectedTextSize = 16.0;
  bool _receiveNotifications = true;
  double _vibrationIntensity = 0.5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create New Profile with Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Widget to select theme color
          DropdownButton<Color>(
          value: _selectedColor,
          onChanged: (color) {
            setState(() {
              _selectedColor = color!;
            });
          },
          items: [
            DropdownMenuItem(
              value: Colors.blue,
              child: _buildColorOption(Colors.blue),
            ),
            DropdownMenuItem(
              value: Colors.red,
              child: _buildColorOption(Colors.red),
            ),
            DropdownMenuItem(
              value: Colors.green,
              child: _buildColorOption(Colors.green),
            ),
            // Add more color options if needed
          ],
        ),
    SizedBox(height: 16),
            Text('Text Size'),
            Slider(
              value: _selectedTextSize,
              min: 10,
              max: 30,
              onChanged: (value) {
                setState(() {
                  _selectedTextSize = value;
                });
              },
            ),
            SizedBox(height: 16),
            // Widget to toggle notifications
            CheckboxListTile(
              title: Text('Receive Notifications'),
              value: _receiveNotifications,
              onChanged: (value) {
                setState(() {
                  _receiveNotifications = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Vibration Intensity'),
            Slider(
              value: _vibrationIntensity,
              min: 0,
              max: 1,
              onChanged: (value) {
                setState(() {
                  _vibrationIntensity = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            // Create the new profile with settings and save it
            final newProfile = DeviceProfile(
              id: DateTime.now().toString(),
              name: widget.name,
              latitude: widget.latitude,
              longitude: widget.longitude,
              settings: ProfileSettings(
                themeColor: _selectedColor,
                textSize: _selectedTextSize,
                receiveNotifications: _receiveNotifications,
                vibrationIntensity: _vibrationIntensity,
              ),
            );

            await widget.profileBloc.profileRepository.createProfile(newProfile);
            final profiles =
            await widget.profileBloc.profileRepository.getProfiles();
            widget.profileBloc.add(LoadProfiles());

            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Create'),
        ),
      ],
    );
  }
}


class ProfileListScreenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfilesLoaded) {
          final profiles = state.profiles;
          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No profiles found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (ctx, index) {
              final profile = profiles[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    profile.name,
                    style: TextStyle(fontSize: profile.settings.textSize),
                  ),
                  subtitle: Text(
                    'Latitude: ${profile.latitude}, Longitude: ${profile.longitude}',
                    style: TextStyle(fontSize: 14),
                  ),
                  tileColor: profile.settings.themeColor.withOpacity(0.1),
                ),
              );
            },
          );
        } else if (state is ProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return Center(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                itemCount: 5, // Number of shimmering items
                itemBuilder: (ctx, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      subtitle: Container(
                        width: double.infinity,
                        height: 14,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}

Widget _buildColorOption(Color color) {
  return Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
  );
}