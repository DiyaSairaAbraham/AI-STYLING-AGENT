import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

// ============================================================
// App-wide purple theme (same as the other 3 screens)
// ============================================================
class AppTheme {
  static const Color purpleDeep = Color(0xFF4C2FD6);
  static const Color purpleAccent = Color(0xFF6C48F2);
  static const Color purpleSoft = Color(0xFF7B5CF0);
  static const Color bgLight = Color(0xFFEDE8FD);
  static const Color inkDark = Color(0xFF1A1B4B);
  static const Color inkMuted = Color(0xFF5A5B7E);
}

class OutfitResultScreen extends StatelessWidget {
  final String imagePath;
  final String styleType;
  final String sourceType;
  final String stylingAdvice;
  const OutfitResultScreen({
    super.key,
    required this.imagePath,
    required this.styleType,
    required this.sourceType,
    required this.stylingAdvice,
  });

  Future<void> downloadImage(
    BuildContext context,
  ) async {
    try {
      final response = await Dio().get(
        imagePath,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final bytes = Uint8List.fromList(response.data);

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: 'generated_outfit',
          bytes: bytes,
          ext: 'png',
          mimeType: MimeType.png,
        );
      } else {
        await Gal.putImageBytes(
          bytes,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image downloaded successfully',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Download failed: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.inkDark),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),

            // ---------- AI Powered badge ----------
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppTheme.purpleSoft.withOpacity(0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 16, color: AppTheme.purpleDeep),
                    SizedBox(width: 8),
                    Text(
                      'AI POWERED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.purpleDeep,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------- Main headline ----------
            const Text(
              "Your Generated Outfit",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppTheme.inkDark,
              ),
            ),

            const SizedBox(height: 12),

            // Accent underline
            const Center(
              child: SizedBox(
                width: 48,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTheme.purpleAccent,
                    borderRadius:
                        BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------- Style & source chips ----------
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _chip(
                    icon: Icons.checkroom,
                    label: styleType.toUpperCase(),
                  ),
                  const SizedBox(width: 12),
                  _chip(
                    icon: Icons.source,
                    label: sourceType.toUpperCase(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- Generated outfit image ----------
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                  color: AppTheme.bgLight,
                  border: Border.all(
                    color: AppTheme.purpleSoft.withOpacity(0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.purpleDeep.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.network(
                  imagePath,
                  fit: BoxFit.contain,
                  loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                  ) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.purpleAccent,
                        strokeWidth: 4,
                      ),
                    );
                  },
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Center(
                      child: Text(
                        "Failed to load generated image",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.inkMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ---------- Styling Advice ----------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purpleDeep.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: AppTheme.purpleAccent,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Styling Advice",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.inkDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    stylingAdvice,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppTheme.inkMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------- Download button ----------
            ElevatedButton.icon(
              icon: const Icon(Icons.download, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purpleDeep,
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                downloadImage(context);
              },
              label: const Text(
                "Download",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------- Generate Another Outfit ----------
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.purpleDeep,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(
                  color: AppTheme.purpleAccent,
                  width: 1.5,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              label: const Text(
                "Generate Another Outfit",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Small style/source chip ----------
  Widget _chip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppTheme.purpleSoft.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.purpleDeep),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.inkDark,
            ),
          ),
        ],
      ),
    );
  }
}

