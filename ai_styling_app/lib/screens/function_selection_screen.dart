import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'outfit_result_screen.dart';
import 'wardrobe_source_screen.dart';

class FunctionSelectionScreen
    extends StatelessWidget {
  final String userImagePath;

  const FunctionSelectionScreen({
    super.key,
    required this.userImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Your Styling',
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 20),

            const Text(
              'How would you like\nto style yourself?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Choose one of the two styling '
              'experiences.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 36),

            _FunctionCard(
              icon: Icons.auto_awesome,
              title: 'AI Styling',
              description:
                  'Let AI create a complete '
                  'look for you.',
              onTap: () {
                _generateAiStyle(context);
              },
            ),

            const SizedBox(height: 18),

            _FunctionCard(
              icon: Icons.checkroom_outlined,
              title: 'Wardrobe Styling',
              description:
                  'Create a look using a '
                  'personal or commercial wardrobe.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WardrobeSourceScreen(
                      userImagePath:
                          userImagePath,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAiStyle(
    BuildContext context,
  ) async {
    final api = ApiService();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final result =
          await api.generateAiStyle(
        userImagePath,
      );

      if (!context.mounted) {
        return;
      }

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OutfitResultScreen(
            result: result,
            functionName: 'AI Styling',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    }
  }
}

class _FunctionCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FunctionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECE6),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 30,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color:
                            Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}