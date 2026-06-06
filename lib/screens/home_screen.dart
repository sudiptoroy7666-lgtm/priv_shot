import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:priv_shot/core/theme.dart';
import 'package:priv_shot/screens/review_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final StreamSubscription _intentSub;

  @override
  void initState() {
    super.initState();
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((files) async {
      if (files.isNotEmpty) {
        final imageFile = files.firstWhere((f) => f.type == SharedMediaType.image, orElse: () => files.first);
        try {
          final bytes = await File(imageFile.path).readAsBytes();
          if (!mounted) return;
          Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewScreen(imageBytes: bytes)));
        } catch (_) {}
      }
    });
  }

  Future<void> _pickImage() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewScreen(imageBytes: bytes)));
    }
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 60),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('PrivShot', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: 1.2)),
                const Text('Privacy-First Screenshot Sanitizer', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Select Screenshot'),
                ),
                const SizedBox(height: 40),
                _GlassCard(icon: Icons.draw, title: 'Smart Canvas', desc: 'Draw custom redactions or use 1-tap AI presets.'),
                const SizedBox(height: 16),
                _GlassCard(icon: Icons.speed, title: 'Risk Scoring', desc: 'Instantly see how sensitive your image is.'),
                const SizedBox(height: 16),
                _GlassCard(icon: Icons.security, title: 'Metadata Stripping', desc: 'Automatically removes GPS & EXIF tracking data.'),
                const SizedBox(height: 50),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: AppTheme.success),
                    const SizedBox(width: 8),
                    Text('100% Offline • No Internet • No Backend', style: TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _GlassCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}