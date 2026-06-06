import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:priv_shot/screens/home_screen.dart';
import 'package:priv_shot/screens/review_screen.dart';
import 'package:priv_shot/core/theme.dart';

void main() {
  runApp(const PrivShotApp());
}

class PrivShotApp extends StatelessWidget {
  const PrivShotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrivShot',
      debugShowCheckedModeBanner: false,
      // In lib/main.dart -> PrivShotApp
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force dark mode for the premium look
      darkTheme: AppTheme.darkTheme,
      home: const AppEntry(),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  // This will hold the screen we want to show
  Widget? _nextScreen;

  @override
  void initState() {
    super.initState();
    _checkShareIntent();
  }

  Future<void> _checkShareIntent() async {
    try {
      // 1. Check if the app was opened via a Share Intent
      final files = await ReceiveSharingIntent.instance.getInitialMedia();

      if (files.isNotEmpty) {
        final imageFile = files.firstWhere(
              (f) => f.type == SharedMediaType.image,
          orElse: () => files.first,
        );

        final file = File(imageFile.path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (mounted) {
            setState(() {
              // If shared image found, go straight to Review Screen
              _nextScreen = ReviewScreen(imageBytes: bytes);
            });
            return;
          }
        }
      }
    } catch (e) {
      print('Share intent error: $e');
    }

    // 2. If NO shared image was found, show the normal Home Screen
    if (mounted) {
      setState(() {
        _nextScreen = const HomeScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking for intents
    if (_nextScreen == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    // Render the chosen screen
    return _nextScreen!;
  }
}