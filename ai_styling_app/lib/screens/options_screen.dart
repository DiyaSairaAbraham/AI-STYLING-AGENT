import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'outfit_result_screen.dart';

class OptionsScreen extends StatefulWidget {
  final String userImagePath;

  const OptionsScreen({
    super.key,
    required this.userImagePath,
  });

  @override
  State<OptionsScreen> createState() =>
      _OptionsScreenState();
}

class _OptionsScreenState
    extends State<OptionsScreen> {
  final ApiService _api = ApiService();

  bool _loading = false;

  Future<void> _generateAiStyle() async {
    setState(() {
      _loading = true;
    });

    try {
      final result = await _api.generateAiStyle(
        widget.userImagePath,
      );

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OutfitResultScreen(
            result: result,
            functionName: 'AI Styling',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _generateWardrobeStyle(
    String source,
  ) async {
    setState(() {
      _loading = true;
    });

    try {
      final result =
          await _api.generateWardrobeStyle(
        userImagePath: widget.userImagePath,
        wardrobeSource: source,
      );

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OutfitResultScreen(
            result: result,
            functionName:
                source == 'personal'
                    ? 'Personal Wardrobe'
                    : 'Commercial Wardrobe',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.replaceFirst(
            'Exception: ',
            '',
          ),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
            const Color(0xFF2F2924),
        title: const Text(
          'Choose a Function',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            20,
            22,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'What would you like\nto create?',
                style: TextStyle(
                  fontSize: 31,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F2924),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Choose how AI Personal Styling Consultant should create your look.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 28),

              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _FunctionCard(
                        icon:
                            Icons.auto_awesome_rounded,
                        title: 'Create My Look',
                        description:
                            'Let the AI stylist create a complete look for you.',
                        onTap: _loading
                            ? null
                            : _generateAiStyle,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: _FunctionCard(
                        icon:
                            Icons.checkroom_rounded,
                        title: 'Use a Wardrobe',
                        description:
                            'Create your look using a commercial or personal wardrobe.',
                        onTap: _loading
                            ? null
                            : () {
                                _showWardrobeChoice();
                              },
                      ),
                    ),
                  ],
                ),
              ),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWardrobeChoice() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF8F5F0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              24,
              22,
              25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose wardrobe',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2F2924),
                  ),
                ),

                const SizedBox(height: 20),

                _WardrobeChoice(
                  icon: Icons.storefront_outlined,
                  title: 'Commercial Wardrobe',
                  description:
                      'Create a look using available commercial clothing.',
                  onTap: () {
                    Navigator.pop(context);
                    _generateWardrobeStyle(
                      'commercial',
                    );
                  },
                ),

                const SizedBox(height: 12),

                _WardrobeChoice(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Wardrobe',
                  description:
                      'Create a look using your own wardrobe.',
                  onTap: () {
                    Navigator.pop(context);
                    _generateWardrobeStyle(
                      'personal',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FunctionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

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
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE4),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(0xFF2F2924),
                  size: 29,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F2924),
                ),
              ),

              const SizedBox(height: 9),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WardrobeChoice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _WardrobeChoice({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                icon,
                size: 30,
                color: const Color(0xFF2F2924),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}