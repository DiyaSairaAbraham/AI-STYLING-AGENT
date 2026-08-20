import 'package:flutter/material.dart';
import 'package:ai_styling_app/screens/outfit_result_screen.dart';
import '../services/api_service.dart';

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
      appBar: AppBar(
        
      ),

      body: isLoading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      CircularProgressIndicator(),

                      SizedBox(height: 20),

                      Text(
                        "Generating your outfit...\nThis may take up to 1 minute",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
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
                  subtitle: "Let AI creates outfits from the entire fashion world",
                  value: "open_world",
                ),
              ),

            const Spacer(),

            SizedBox(
              height: 56,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),

                label: const Text(
                  "Generate Outfit",
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
                            imagePath:
                                imageResult["image_url"],
                            styleType:
                                widget.styleType,
                            sourceType:
                                selectedSource,
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