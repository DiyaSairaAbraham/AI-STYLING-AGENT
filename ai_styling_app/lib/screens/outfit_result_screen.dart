import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

// ============================================================
// App-wide purple theme
// ============================================================

class AppTheme {
  static const Color purpleDeep = Color(0xFF4C2FD6);
  static const Color purpleAccent = Color(0xFF6C48F2);
  static const Color purpleSoft = Color(0xFF7B5CF0);
  static const Color bgLight = Color(0xFFEDE8FD);
  static const Color inkDark = Color(0xFF1A1B4B);
  static const Color inkMuted = Color(0xFF5A5B7E);
}

// ============================================================
// OUTFIT RESULT SCREEN
// ============================================================

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

  // ============================================================
  // DOWNLOAD IMAGE
  // ============================================================

  Future<void> downloadImage(BuildContext context) async {
    try {
      final String url = imagePath.trim();

      if (url.isEmpty) {
        throw Exception('Image URL is empty.');
      }

      final response = await Dio().get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data;

      if (data == null || data.isEmpty) {
        throw Exception('The server returned an empty image.');
      }

      final Uint8List bytes = Uint8List.fromList(data);

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: 'generated_outfit',
          bytes: bytes,
          fileExtension: 'png',
          mimeType: MimeType.png,
        );
      } else {
        await Gal.putImageBytes(bytes);
      }

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image downloaded successfully'),
        ),
      );
    } on DioException catch (e) {
      if (!context.mounted) {
        return;
      }

      final String message = e.response != null
          ? 'Image download failed: HTTP ${e.response?.statusCode}'
          : 'Could not connect to the image server.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double imageHeight = screenWidth < 400
        ? 420.0
        : screenWidth < 600
            ? 500.0
            : 600.0;

    // Keep the decoded bitmap close to the size actually needed.
    // Avoid very large cache dimensions because AI-generated images
    // can otherwise consume a large amount of GPU memory on Android.
    final int imageCacheWidth = screenWidth < 600 ? 600 : 900;

    final int imageCacheHeight = screenWidth < 600 ? 800 : 1100;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppTheme.inkDark,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth < 400 ? 16 : 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // ==================================================
              // AI POWERED BADGE
              // ==================================================

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
                      color: AppTheme.purpleSoft.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppTheme.purpleDeep,
                      ),
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

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                'Your Generated Outfit',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.inkDark,
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: SizedBox(
                  width: 48,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.purpleAccent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // STYLE / SOURCE CHIPS
              // ==================================================

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _chip(
                    icon: Icons.checkroom,
                    label: styleType.toUpperCase(),
                  ),
                  _chip(
                    icon: Icons.source,
                    label: sourceType.toUpperCase(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ==================================================
              // GENERATED IMAGE
              // ==================================================

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: imageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppTheme.purpleSoft.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.purpleDeep.withValues(
                          alpha: 0.12,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: imagePath.trim().isEmpty
                      ? const _ImageError(
                          message:
                              'No generated image URL received.',
                        )
                      : Image.network(
                          imagePath.trim(),

                          width: double.infinity,
                          height: imageHeight,

                          // Contain prevents the generated person/outfit
                          // from being cropped.
                          fit: BoxFit.contain,

                          // Keep the decoded bitmap bounded for Android.
                          cacheWidth: imageCacheWidth,
                          cacheHeight: imageCacheHeight,

                          filterQuality: FilterQuality.low,

                          loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                          ) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
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
                            debugPrint(
                              'Generated image failed to load: '
                              '$imagePath',
                            );

                            debugPrint(
                              'Image error: $error',
                            );

                            return const _ImageError(
                              message:
                                  'Failed to load generated image.',
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // STYLING ADVICE
              // ==================================================

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.purpleDeep.withValues(
                        alpha: 0.06,
                      ),
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
                        Expanded(
                          child: Text(
                            'Styling Advice',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.inkDark,
                            ),
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

              // ==================================================
              // DOWNLOAD
              // ==================================================

              ElevatedButton.icon(
                icon: const Icon(
                  Icons.download,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleDeep,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    54,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => downloadImage(context),
                label: const Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // GENERATE ANOTHER
              // ==================================================

              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.purpleDeep,
                  minimumSize: const Size(
                    double.infinity,
                    54,
                  ),
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
                  'Generate Another Outfit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHIP
  // ============================================================

  Widget _chip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppTheme.purpleSoft.withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.purpleDeep,
          ),
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

// ============================================================
// IMAGE ERROR
// ============================================================

class _ImageError extends StatelessWidget {
  final String message;

  const _ImageError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: AppTheme.inkMuted.withValues(
                alpha: 0.7,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}