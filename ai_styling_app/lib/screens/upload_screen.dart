import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/wardrobe_source_screen.dart';
import '../services/api_service.dart';

// ============================================================
// App-wide purple theme
// ============================================================

class AppTheme {
  static const Color purpleDeep = Color(0xFF4C2FD6);
  static const Color purpleAccent = Color(0xFF6C48F2);
  static const Color purpleSoft = Color(0xFF7B5CF0);
  static const Color bgLight = Color(0xFFEDE8FD);
  static const Color inkDark = Color(0xFF1A1B4B);
  static const Color inkMuted = Color(0xFF5A5B7E);
}

// ============================================================
// Upload Screen
// ============================================================

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool isFormalHovered = false;
  bool isLeisureHovered = false;

  String selectedStyle = '';

  bool analysisCompleted = false;
  bool isLoading = false;

  final ApiService apiService = ApiService();
  final ImagePicker picker = ImagePicker();

  XFile? selectedImage;

  Map<String, dynamic>? visionResult;

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        selectedImage = image;
        visionResult = null;
        analysisCompleted = false;
        selectedStyle = '';
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not select image: $e'),
        ),
      );
    }
  }

  // ============================================================
  // ANALYZE IMAGE
  // ============================================================

  Future<void> analyzeSelectedImage(String styleType) async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an image first.'),
        ),
      );
      return;
    }

    if (isLoading) {
      return;
    }

    setState(() {
      selectedStyle = styleType;
      isLoading = true;
      analysisCompleted = false;
      visionResult = null;
    });

    try {
      final result = await apiService.analyzeImage(
        imageFile: selectedImage!,
        styleType: styleType,
      );

      if (!mounted) {
        return;
      }

      if (result == null) {
        setState(() {
          isLoading = false;
          analysisCompleted = false;
          visionResult = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Image analysis failed. Please check the server and try again.',
            ),
          ),
        );

        return;
      }

      setState(() {
        visionResult = result;
        analysisCompleted = true;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        analysisCompleted = false;
        visionResult = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: $e'),
        ),
      );
    }
  }

  // ============================================================
  // CONTINUE TO WARDROBE SOURCE
  // ============================================================

  void continueToWardrobeSource() {
    final userImagePath =
        visionResult?['user_image_path']?.toString();

    if (userImagePath == null || userImagePath.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User image path was not returned by the server.',
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectWardrobeSourceScreen(
          imagePath: userImagePath,
          styleType: selectedStyle,
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget buildImagePreview() {
    if (selectedImage == null) {
      return const Center(
        child: Icon(
          Icons.add_a_photo_outlined,
          size: 80,
          color: AppTheme.purpleSoft,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: FutureBuilder<Uint8List>(
        future: selectedImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.purpleAccent,
              ),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 50,
                    color: AppTheme.inkMuted,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Unable to display image',
                    style: TextStyle(
                      color: AppTheme.inkMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return Image.memory(
            snapshot.data!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppTheme.inkDark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),

            // ==================================================
            // AI POWERED BADGE
            // ==================================================

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
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppTheme.purpleDeep,
                    ),
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

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'Upload Your Photo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppTheme.inkDark,
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: SizedBox(
                width: 48,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTheme.purpleAccent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Upload a clear image and choose your desired styling mode.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.inkMuted,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // IMAGE CONTAINER
            // ==================================================

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
              child: buildImagePreview(),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // UPLOAD BUTTON
            // ==================================================

            ElevatedButton.icon(
              onPressed: isLoading ? null : pickImage,
              icon: const Icon(
                Icons.upload,
                color: Colors.white,
              ),
              label: const Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purpleDeep,
                disabledBackgroundColor:
                    AppTheme.purpleDeep.withOpacity(0.5),
                minimumSize: const Size(
                  double.infinity,
                  54,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ==================================================
            // CHOOSE STYLE
            // ==================================================

            const Text(
              'Choose Style',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.inkDark,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                // ==================================================
                // FORMAL
                // ==================================================

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
                      onTap: isLoading
                          ? null
                          : () => analyzeSelectedImage('formal'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(
                          0,
                          isFormalHovered ? -8 : 0,
                          0,
                        ),
                        height: 120,
                        decoration: BoxDecoration(
                          color: selectedStyle == 'formal'
                              ? AppTheme.purpleAccent.withOpacity(0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedStyle == 'formal'
                                ? AppTheme.purpleAccent
                                : AppTheme.purpleSoft
                                    .withOpacity(0.35),
                            width:
                                selectedStyle == 'formal' ? 2 : 1,
                          ),
                          boxShadow: selectedStyle == 'formal'
                              ? [
                                  BoxShadow(
                                    color: AppTheme.purpleDeep
                                        .withOpacity(0.18),
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
                              color: selectedStyle == 'formal'
                                  ? AppTheme.purpleDeep
                                  : AppTheme.inkMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Formal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedStyle == 'formal'
                                    ? AppTheme.purpleDeep
                                    : AppTheme.inkDark,
                              ),
                            ),
                            if (selectedStyle == 'formal')
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

                // ==================================================
                // LEISURE
                // ==================================================

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
                      onTap: isLoading
                          ? null
                          : () => analyzeSelectedImage('leisure'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(
                          0,
                          isLeisureHovered ? -8 : 0,
                          0,
                        ),
                        height: 120,
                        decoration: BoxDecoration(
                          color: selectedStyle == 'leisure'
                              ? AppTheme.purpleAccent.withOpacity(0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedStyle == 'leisure'
                                ? AppTheme.purpleAccent
                                : AppTheme.purpleSoft
                                    .withOpacity(0.35),
                            width:
                                selectedStyle == 'leisure' ? 2 : 1,
                          ),
                          boxShadow: selectedStyle == 'leisure'
                              ? [
                                  BoxShadow(
                                    color: AppTheme.purpleDeep
                                        .withOpacity(0.18),
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
                              color: selectedStyle == 'leisure'
                                  ? AppTheme.purpleDeep
                                  : AppTheme.inkMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Leisure',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedStyle == 'leisure'
                                    ? AppTheme.purpleDeep
                                    : AppTheme.inkDark,
                              ),
                            ),
                            if (selectedStyle == 'leisure')
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

            // ==================================================
            // LOADING
            // ==================================================

            if (isLoading) ...[
              const SizedBox(height: 30),

              const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.purpleAccent,
                  strokeWidth: 4,
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Analyzing your style...',
                  style: TextStyle(
                    color: AppTheme.inkMuted,
                  ),
                ),
              ),
            ],

            // ==================================================
            // VISION ANALYSIS
            // ==================================================

            if (analysisCompleted && visionResult != null) ...[
              const SizedBox(height: 30),

              _buildVisionAnalysis(),

              const SizedBox(height: 30),

              // This does NOT generate the outfit yet.
              // It takes the user to wardrobe-source selection.
              ElevatedButton(
                onPressed: continueToWardrobeSource,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleDeep,
                  minimumSize: const Size(
                    double.infinity,
                    54,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue to Wardrobe Selection',
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

  // ============================================================
  // VISION ANALYSIS UI
  // ============================================================

  Widget _buildVisionAnalysis() {
    final userFeatures =
        visionResult?['profile']?['user_features']
            as Map<String, dynamic>?;

    final analysis =
        visionResult?['profile']?['analysis']
            as Map<String, dynamic>?;

    final advantages =
        analysis?['advantages'] as List<dynamic>? ?? [];

    final improvements =
        analysis?['areas_for_improvement'] as List<dynamic>? ?? [];

    final comments =
        visionResult?['profile']?['comments']?.toString() ?? '';

    return Container(
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
          // ==================================================
          // HEADER
          // ==================================================

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
              const Expanded(
                child: Text(
                  'Vision Analysis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.inkDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ==================================================
          // DETECTED FEATURES
          // ==================================================

          const Text(
            'Detected Features',
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
              'Gender: ${userFeatures?['gender'] ?? ''}\n'
              'Skin Tone: ${userFeatures?['skin_tone'] ?? ''}\n'
              'Hairstyle: ${userFeatures?['hairstyle'] ?? ''}\n'
              'Body Type: ${userFeatures?['body_type'] ?? ''}',
              style: const TextStyle(
                color: AppTheme.inkDark,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ==================================================
          // ADVANTAGES
          // ==================================================

          const Text(
            'Advantages',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.inkDark,
            ),
          ),

          const SizedBox(height: 8),

          _buildBulletList(
            advantages,
            Icons.check_circle,
            AppTheme.purpleAccent,
          ),

          const SizedBox(height: 20),

          // ==================================================
          // IMPROVEMENTS
          // ==================================================

          const Text(
            'Improvements',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.inkDark,
            ),
          ),

          const SizedBox(height: 8),

          _buildBulletList(
            improvements,
            Icons.warning_amber_rounded,
            Colors.orange,
          ),

          const SizedBox(height: 20),

          // ==================================================
          // GPT STYLIST COMMENTS
          // ==================================================

          const Text(
            'GPT Stylist Comments',
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
              comments.isEmpty
                  ? 'No additional comments.'
                  : comments,
              style: const TextStyle(
                color: AppTheme.inkDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BULLET LIST
  // ============================================================

  Widget _buildBulletList(
    List<dynamic> items,
    IconData icon,
    Color iconColor,
  ) {
    if (items.isEmpty) {
      return const Text(
        'None detected.',
        style: TextStyle(
          color: AppTheme.inkMuted,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        color: AppTheme.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}