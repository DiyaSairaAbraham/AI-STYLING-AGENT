import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'outfit_result_screen.dart';

class WardrobeSourceScreen
    extends StatelessWidget {
  final String userImagePath;

  const WardrobeSourceScreen({
    super.key,
    required this.userImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Wardrobe',
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),

          const Text(
            'Where should your\nlook come from?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Choose the wardrobe you want '
            'the stylist to use.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 36),

          _WardrobeCard(
            icon: Icons.person_outline,
            title: 'Personal Wardrobe',
            description:
                'Style me using clothes '
                'from my wardrobe.',
            onTap: () {
              _generate(
                context,
                'personal',
              );
            },
          ),

          const SizedBox(height: 18),

          _WardrobeCard(
            icon: Icons.storefront_outlined,
            title: 'Commercial Wardrobe',
            description:
                'Create a look using '
                'commercial clothing.',
            onTap: () {
              _generate(
                context,
                'commercial',
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generate(
    BuildContext context,
    String source,
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
          await api.generateWardrobeStyle(
        userImagePath: userImagePath,
        wardrobeSource: source,
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
            functionName:
                source == 'personal'
                    ? 'Personal Wardrobe'
                    : 'Commercial Wardrobe',
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

class _WardrobeCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _WardrobeCard({
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