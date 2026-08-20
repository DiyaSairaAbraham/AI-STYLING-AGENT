import 'package:flutter/material.dart';
import '../screens/wardrobe_source_screen.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

// ============================================================
// App-wide purple theme (same as redesigned HomeScreen)
// ============================================================
class AppTheme {
  static const Color purpleDeep = Color(0xFF4C2FD6);
  static const Color purpleAccent = Color(0xFF6C48F2);
  static const Color purpleSoft = Color(0xFF7B5CF0);
  static const Color bgLight = Color(0xFFEDE8FD);
  static const Color inkDark = Color(0xFF1A1B4B);
  static const Color inkMuted = Color(0xFF5A5B7E);
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

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool isFormalHovered = false;
  bool isLeisureHovered = false;

  String selectedStyle = "";

  bool analysisCompleted = false;

  final ApiService apiService = ApiService();

  Map<String, dynamic>? visionResult;

  bool isLoading = false;

  XFile? selectedImage;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              "Upload Your Photo",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppTheme.inkDark,
              ),
            ),
            const SizedBox(height: 10),

            // Accent underline like the home screen
            const Center(
              child: SizedBox(
                width: 48,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTheme.purpleAccent,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Upload a clear image and choose your desired styling mode.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.inkMuted,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            // ---------- Photo container ----------
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selectedImage == null
                      ? AppTheme.purpleSoft.withOpacity(0.4)
                      : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purpleDeep.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: selectedImage == null
                  ? const Center(
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        size: 80,
                        color: AppTheme.purpleSoft,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        selectedImage!.path,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // ---------- Upload Image button ----------
            ElevatedButton.icon(
              onPressed: () {
                pickImage();
              },
              icon: const Icon(Icons.upload, color: Colors.white),
              label: const Text(
                "Upload Image",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purpleDeep,
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ---------- Choose Style ----------
            const Text(
              "Choose Style",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.inkDark,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) {
                      setState(() {
                        isFormalHovered = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        isFormalHovered = false;
                      });
                    },
                    child: GestureDetector(
                      onTap: () async {
                        if (selectedImage == null) {
                          return;
                        }

                        setState(() {
                          selectedStyle = "formal";
                          isLoading = true;
                        });

                        final result = await apiService.analyzeImage(
                          imageFile: selectedImage!,
                          styleType: "formal",
                        );

                        setState(() {
                          visionResult = result;
                          analysisCompleted = result != null;
                          isLoading = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(
                          0,
                          isFormalHovered ? -8 : 0,
                          0,
                        ),
                        height: 120,
                        decoration: BoxDecoration(
                          color: selectedStyle == "formal"
                              ? AppTheme.purpleAccent.withOpacity(0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedStyle == "formal"
                                ? AppTheme.purpleAccent
                                : AppTheme.purpleSoft.withOpacity(0.35),
                            width: selectedStyle == "formal" ? 2 : 1,
                          ),
                          boxShadow: selectedStyle == "formal"
                              ? [
                                  BoxShadow(
                                    color: AppTheme.purpleDeep.withOpacity(0.18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_center,
                              size: 40,
                              color: selectedStyle == "formal"
                                  ? AppTheme.purpleDeep
                                  : AppTheme.inkMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Formal",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedStyle == "formal"
                                    ? AppTheme.purpleDeep
                                    : AppTheme.inkDark,
                              ),
                            ),
                            if (selectedStyle == "formal")
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: AppTheme.purpleAccent,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) {
                      setState(() {
                        isLeisureHovered = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        isLeisureHovered = false;
                      });
                    },
                    child: GestureDetector(
                      onTap: () async {
                        if (selectedImage == null) {
                          return;
                        }

                        setState(() {
                          selectedStyle = "leisure";
                          isLoading = true;
                        });

                        final result = await apiService.analyzeImage(
                          imageFile: selectedImage!,
                          styleType: "leisure",
                        );

                        setState(() {
                          visionResult = result;
                          analysisCompleted = result != null;
                          isLoading = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(
                          0,
                          isLeisureHovered ? -8 : 0,
                          0,
                        ),
                        height: 120,
                        decoration: BoxDecoration(
                          color: selectedStyle == "leisure"
                              ? AppTheme.purpleAccent.withOpacity(0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedStyle == "leisure"
                                ? AppTheme.purpleAccent
                                : AppTheme.purpleSoft.withOpacity(0.35),
                            width: selectedStyle == "leisure" ? 2 : 1,
                          ),
                          boxShadow: selectedStyle == "leisure"
                              ? [
                                  BoxShadow(
                                    color: AppTheme.purpleDeep.withOpacity(0.18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.weekend,
                              size: 40,
                              color: selectedStyle == "leisure"
                                  ? AppTheme.purpleDeep
                                  : AppTheme.inkMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Leisure",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedStyle == "leisure"
                                    ? AppTheme.purpleDeep
                                    : AppTheme.inkDark,
                              ),
                            ),
                            if (selectedStyle == "leisure")
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: AppTheme.purpleAccent,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            if (isLoading) ...[
              const SizedBox(height: 30),

              Center(
                child: CircularProgressIndicator(
                  color: AppTheme.purpleAccent,
                  strokeWidth: 4,
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  "Analyzing your style...",
                  style: TextStyle(
                    color: AppTheme.inkMuted,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],

            if (analysisCompleted) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.purpleDeep.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- Vision Analysis header with badge ----------
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.bgLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppTheme.purpleDeep,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Vision Analysis",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.inkDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Detected Features",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.inkDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        """
Gender: ${visionResult?['profile']?['user_features']?['gender'] ?? ""}
Skin Tone: ${visionResult?['profile']?['user_features']?['skin_tone'] ?? ""}
Hairstyle: ${visionResult?['profile']?['user_features']?['hairstyle'] ?? ""}
Body Type: ${visionResult?['profile']?['user_features']?['body_type'] ?? ""}
                        """,
                        style: const TextStyle(color: AppTheme.inkDark),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Advantages",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.inkDark,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          (visionResult?["profile"]?["analysis"]?["advantages"]
                                      as List<dynamic>? ??
                                  [])
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppTheme.purpleAccent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.toString(),
                                          style: const TextStyle(
                                            color: AppTheme.inkMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Improvements",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.inkDark,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          (visionResult?["profile"]?["analysis"]?["areas_for_improvement"]
                                      as List<dynamic>? ??
                                  [])
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.toString(),
                                          style: const TextStyle(
                                            color: AppTheme.inkMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "GPT Stylist Comments",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.inkDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        visionResult?["profile"]?["comments"] ?? "",
                        style: const TextStyle(color: AppTheme.inkDark),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectWardrobeSourceScreen(
                        imagePath: visionResult?["user_image_path"] ?? "",
                        styleType: selectedStyle,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleDeep,
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Continue to Wardrobe Selection",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

