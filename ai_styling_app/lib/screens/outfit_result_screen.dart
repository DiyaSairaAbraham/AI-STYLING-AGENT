import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

class OutfitResultScreen extends StatelessWidget {
  final String imagePath;
  final String styleType;
  final String sourceType;

  const OutfitResultScreen({
    super.key,
    required this.imagePath,
    required this.styleType,
    required this.sourceType,
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

      final bytes =
          Uint8List.fromList(response.data);

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
      appBar: AppBar(
        title: const Text("Generated Outfit"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Your Generated Outfit",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 500,
                color: Colors.grey.shade200,
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

                    return const Center(
                      child: CircularProgressIndicator(),
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
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Style: ${styleType.toUpperCase()}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Source: ${sourceType.toUpperCase()}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
                onPressed: () {
                  downloadImage(context);
                },
                child: const Text(
                  "Download",
                ),
              ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Generate Another Outfit"),
            ),
          ],
        ),
      ),
    );
  }
}