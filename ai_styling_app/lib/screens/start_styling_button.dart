import 'package:flutter/material.dart';


class StartStylingButton extends StatefulWidget {
  final VoidCallback onTap;

  const StartStylingButton({super.key, required this.onTap});

  @override
  State<StartStylingButton> createState() => _StartStylingButtonState();
}

class _StartStylingButtonState extends State<StartStylingButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    // Purple theme colors — adjust if your palette differs
    const Color purpleDeep = Color(0xFF4C2FD6);
    const Color purpleGlow = Color(0xFF7B5CF0);

    return MouseRegion(
      // Detect when the mouse pointer enters / leaves the button
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click, // show the hand cursor
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: double.infinity,
          height: 58,
          // The button "pops up" on hover: rises and gets a stronger shadow
          transform: Matrix4.identity()
            ..translate(0.0, _hovering ? -3 : 0)
            ..scale(_hovering ? 1.015 : 1.0),
          padding: EdgeInsets.symmetric(
            horizontal: _hovering ? 32 : 28,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Gradient gets brighter on hover
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _hovering
                  ? const [Color(0xFF5F3DEA), purpleGlow]
                  : const [purpleDeep, Color(0xFF6C48F2)],
            ),
            boxShadow: _hovering
                ? [
                    // Bigger, colored glow shadow on hover
                    BoxShadow(
                      color: purpleDeep.withOpacity(0.3),
                      blurRadius: 118,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    // Subtle shadow in the resting state
                    BoxShadow(
                      color: purpleDeep.withOpacity(0.25),
                      blurRadius: 14,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedRotation(
                turns: _hovering ? 0.12 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Start Styling',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 8),
              // Arrow slides forward on hover
              AnimatedSlide(
                offset: Offset(_hovering ? 0.35 : 0, 0),
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}