import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'wardrobe_screen.dart';
import 'upload_screen.dart';
import 'start_styling_button.dart';

// ============================================================
// Hero image
// ============================================================

const String kHeroImagePath = 'assets/images/home_page_image.png';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color purpleDeep = Color(0xFF4C2FD6);
  static const Color purpleAccent = Color(0xFF6C48F2);
  static const Color purpleSoft = Color(0xFF7B5CF0);
  static const Color bgLight = Color(0xFFEDE8FD);
  static const Color inkDark = Color(0xFF1A1B4B);
  static const Color inkMuted = Color(0xFF5A5B7E);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktopWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          _WardrobeButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WardrobeScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // HERO SECTION
              // ==========================================================

              if (isDesktopWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: _HeaderContent(),
                    ),
                    const SizedBox(width: 32),
                    const Expanded(
                      child: _HeroImage(),
                    ),
                  ],
                )
              else
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderContent(),
                    SizedBox(height: 24),
                    _HeroImage(),
                  ],
                ),

              const SizedBox(height: 32),

              // ==========================================================
              // FEATURE CARDS
              // ==========================================================

              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 600;

                  if (isCompact) {
                    return const Column(
                      children: [
                        _FeatureCard(
                          icon: Icons.face_retouching_natural,
                          title: 'Smart Analysis',
                          subtitle:
                              'AI analyzes your style, body & preferences.',
                        ),
                        SizedBox(height: 12),
                        _FeatureCard(
                          icon: Icons.checkroom,
                          title: 'Style Matching',
                          subtitle:
                              'Finds the perfect outfits that match you.',
                        ),
                        SizedBox(height: 12),
                        _FeatureCard(
                          icon: Icons.auto_awesome,
                          title: 'AI Generation',
                          subtitle:
                              'Generates unique looks just for you.',
                        ),
                      ],
                    );
                  }

                  return const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.face_retouching_natural,
                          title: 'Smart Analysis',
                          subtitle:
                              'AI analyzes your style, body & preferences.',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.checkroom,
                          title: 'Style Matching',
                          subtitle:
                              'Finds the perfect outfits that match you.',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.auto_awesome,
                          title: 'AI Generation',
                          subtitle:
                              'Generates unique looks just for you.',
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // ==========================================================
              // AI GENERATED BANNER
              // ==========================================================

              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 90,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      purpleDeep,
                      purpleSoft,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 26,
                      color: Colors.white,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'AI Generated\nJust for You',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================================
              // PERSONALIZED STRIP
              // ==========================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: purpleSoft.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 18,
                      color: purpleDeep,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Personalized. Intelligent. Effortless.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: inkDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 70),

              // ==========================================================
              // START STYLING
              // ==========================================================

              StartStylingButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UploadScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HEADER CONTENT
// ============================================================

class _HeaderContent extends StatelessWidget {
  const _HeaderContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI POWERED BADGE
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: HomeScreen.purpleSoft.withOpacity(0.4),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: HomeScreen.purpleDeep,
              ),
              SizedBox(width: 8),
              Text(
                'AI POWERED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: HomeScreen.purpleDeep,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // MAIN TITLE
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'AI Personal\n',
                style: TextStyle(
                  fontSize: 38,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: HomeScreen.inkDark,
                ),
              ),
              const TextSpan(
                text: 'Styling\n',
                style: TextStyle(
                  fontSize: 38,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: HomeScreen.purpleAccent,
                ),
              ),
              const TextSpan(
                text: 'Consultant',
                style: TextStyle(
                  fontSize: 38,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: HomeScreen.inkDark,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ACCENT LINE
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: HomeScreen.purpleAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Your personal AI stylist that understands you '
          'and creates looks that make you look and feel your best.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: HomeScreen.inkMuted,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// FEATURE CARD
// ============================================================

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: HomeScreen.bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: HomeScreen.purpleDeep,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: HomeScreen.inkDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: HomeScreen.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MY WARDROBE BUTTON
// ============================================================

class _WardrobeButton extends StatefulWidget {
  final VoidCallback onTap;

  const _WardrobeButton({
    required this.onTap,
  });

  @override
  State<_WardrobeButton> createState() => _WardrobeButtonState();
}

class _WardrobeButtonState extends State<_WardrobeButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          transform: Matrix4.identity()
            ..translate(
              0.0,
              _hovering ? -3.0 : 0.0,
            )
            ..scale(
              _hovering ? 1.04 : 1.0,
            ),
          decoration: BoxDecoration(
            color: _hovering
                ? HomeScreen.purpleDeep
                : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _hovering
                  ? HomeScreen.purpleDeep
                  : HomeScreen.purpleSoft.withOpacity(0.5),
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: HomeScreen.purpleDeep.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Wardrobe',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _hovering
                      ? Colors.white
                      : HomeScreen.inkDark,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.checkroom,
                size: 18,
                color: _hovering
                    ? Colors.white
                    : HomeScreen.purpleDeep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HERO IMAGE
// ============================================================

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final double height = screenWidth > 900
        ? 380
        : screenWidth > 600
            ? 330
            : 280;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: HomeScreen.purpleSoft.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: HomeScreen.purpleDeep.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        kHeroImagePath,
        fit: BoxFit.contain,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 56,
                  color: Color(0xFFC9C4E8),
                ),
                SizedBox(height: 12),
                Text(
                  'Add your image here\n'
                  '(kHeroImagePath)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HomeScreen.inkMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}