import 'package:flutter/material.dart';
import 'package:ai_styling_app/screens/outfit_result_screen.dart';

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
  String selectedSource = "personal";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wardrobe Source"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            const SizedBox(height: 20),

            const Text(
              "Choose Wardrobe Source",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Select where the outfit items should come from.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFFF4F6E5),
                borderRadius: BorderRadius.circular(16),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "Selected Style: ${widget.styleType.toUpperCase()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _buildSourceCard(
              icon: Icons.checkroom,
              title: "Personal",
              subtitle: "Use clothes from your wardrobe",
              value: "personal",
            ),

            const SizedBox(height: 16),

            _buildSourceCard(
              icon: Icons.shopping_bag,
              title: "Commercial",
              subtitle: "Use clothes from fashion catalog",
              value: "commercial",
            ),

            const SizedBox(height: 16),

            _buildSourceCard(
              icon: Icons.public,
              title: "Open World",
              subtitle: "Use online fashion items",
              value: "open_world",
            ),

            const Spacer(),

            SizedBox(
              height: 56,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),

                label: const Text(
                  "Generate Outfit",
                ),

                onPressed: () {

                                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OutfitResultScreen(
                        imagePath: widget.imagePath,
                        styleType: widget.styleType,
                        sourceType: selectedSource,
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
              ? const Color(0xFFF4F6E5)
              : Colors.white,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : Colors.grey.shade300,
            width: 2,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [

            Icon(
              icon,
              size: 34,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}