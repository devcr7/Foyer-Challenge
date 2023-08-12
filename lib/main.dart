// lib/main.dart

import 'package:flutter/material.dart';
import 'package:foyer/screens/profile_list_screen.dart';
import 'package:foyer/services/profile_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Profile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProfileListScreen(),
    );
  }
}
