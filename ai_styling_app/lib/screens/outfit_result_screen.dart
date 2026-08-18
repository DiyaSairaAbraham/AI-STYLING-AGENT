import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generated Outfit"),
      ),

      body: Padding(
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

            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Center(
                child: Text(
                  "Generated Outfit Image",
                  style: TextStyle(fontSize: 20),
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

            const Spacer(),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Save Outfit"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Download"),
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