import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:priv_shot/core/theme.dart';

class ResultScreen extends StatefulWidget {
  final Uint8List redactedBytes;
  const ResultScreen({super.key, required this.redactedBytes});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSharing = false;
  bool _isSaving = false;

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/privshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(widget.redactedBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Shared via PrivShot - Privacy Safe & Metadata Stripped',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/privshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(widget.redactedBytes);

      // Push to public Gallery/Downloads using Gal
      await Gal.putImage(path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Saved to Gallery (Metadata Stripped)'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Safe & Clean'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppTheme.success, size: 32),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Privacy Guaranteed', style: TextStyle(color: AppTheme.success, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('PII redacted & EXIF metadata destroyed.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Image Preview with Glow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.memory(widget.redactedBytes, fit: BoxFit.contain),
            ),
            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _saveToGallery,
                    icon: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                        : const Icon(Icons.save_alt),
                    label: const Text('Save to Gallery'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _share,
                    icon: _isSharing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.share),
                    label: const Text('Share Safe'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}