import 'package:flutter/material.dart';
import 'package:ai_styling_app/screens/outfit_result_screen.dart';
import '../services/api_service.dart';

// ============================================================
// App-wide purple theme (same as HomeScreen & UploadScreen)
// ============================================================
class AppTheme {
  static const Color purpleDeep = Color(0xFF4C2FD6);
  static const Color purpleAccent = Color(0xFF6C48F2);
  static const Color purpleSoft = Color(0xFF7B5CF0);
  static const Color bgLight = Color(0xFFEDE8FD);
  static const Color inkDark = Color(0xFF1A1B4B);
  static const Color inkMuted = Color(0xFF5A5B7E);
}

class SelectWardrobeSourceScreen extends StatefulWidget {
  final String imagePath;
  final String styleType;

  const SelectWardrobeSourceScreen({
    super.key,
    required this.imagePath,
    required this.styleType,
  });

  @override
  State<SelectWardrobeSourceScreen> createState() =>
      _SelectWardrobeSourceScreenState();
}

class _SelectWardrobeSourceScreenState
    extends State<SelectWardrobeSourceScreen> {
  String selectedSource = "";

  bool isLoading = false;

  final ApiService apiService = ApiService();

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
      body: isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppTheme.purpleAccent,
                    strokeWidth: 4,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Generating your outfit...\nThis may take up to 1 minute",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.inkMuted,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
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
                          Icon(Icons.auto_awesome, size: 16, color: AppTheme.purpleDeep),
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
                    "Choose Wardrobe Source",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.inkDark,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Accent underline like the other screens
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
                  const SizedBox(height: 16),

                  const Text(
                    "Select where the outfit items should come from.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.inkMuted,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ---------- Selected style info ----------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.purpleSoft.withOpacity(0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.purpleDeep.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.purpleAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Selected Style: ${widget.styleType.toUpperCase()}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.inkDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  HoverCard(
                    child: _buildSourceCard(
                      icon: Icons.person,
                      title: "Personal",
                      subtitle: "Use clothes from your personal wardrobe",
                      value: "personal",
                    ),
                  ),

                  const SizedBox(height: 16),

                  HoverCard(
                    child: _buildSourceCard(
                      icon: Icons.shopping_bag,
                      title: "Commercial",
                      subtitle: "Use items from commercial catalog",
                      value: "commercial",
                    ),
                  ),

                  const SizedBox(height: 16),

                  HoverCard(
                    child: _buildSourceCard(
                      icon: Icons.public,
                      title: "Open World",
                      subtitle:
                          "Let AI creates outfits from the entire fashion world",
                      value: "open_world",
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome,
                          color: Colors.white),
                      label: const Text(
                        "Generate Outfit",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.purpleDeep,
                        minimumSize: const Size(double.infinity, 56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });

                        final optionsResult =
                            await apiService.generateOutfitOptions(
                          userImagePath: widget.imagePath,
                          styleType: widget.styleType,
                          wardrobeSource: selectedSource,
                        );

                        if (optionsResult == null) {
                          setState(() {
                            isLoading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Failed to generate outfit",
                              ),
                            ),
                          );

                          return;
                        }

                        final recommendation =
                            optionsResult["data"]
                                ["recommendations"][0];

                        final imagePrompt =
                            recommendation[
                                "image_generation_prompt"];

                        final stylingAdvice =
                            recommendation["styling_advice"];

                        final imageResult =
                            await apiService.generateSelectedOutfit(
                          prompt: imagePrompt,
                          userImagePath: widget.imagePath,
                        );

                        setState(() {
                          isLoading = false;
                        });

                        if (imageResult == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Failed to generate image",
                              ),
                            ),
                          );

                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OutfitResultScreen(
                              imagePath: imageResult["image_url"],
                              styleType: widget.styleType,
                              sourceType: selectedSource,
                              stylingAdvice: stylingAdvice,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool isSelected = selectedSource == value;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          selectedSource = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.purpleAccent.withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.purpleAccent
                : AppTheme.purpleSoft.withOpacity(0.35),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.purpleDeep.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.purpleDeep.withOpacity(0.10)
                    : AppTheme.bgLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 34,
                color: isSelected
                    ? AppTheme.purpleDeep
                    : AppTheme.inkMuted,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.inkDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.purpleAccent,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class HoverCard extends StatefulWidget {
  final Widget child;

  const HoverCard({
    super.key,
    required this.child,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(
          0,
          isHovered ? -8 : 0,
          0,
        ),
        child: widget.child,
      ),
    );
  }
}

