import 'package:flutter/material.dart';
import '../screens/wardrobe_source_screen.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class HoverCard extends StatefulWidget {

  final Widget child;

  const HoverCard({
    super.key,
    required this.child,
  });

  @override
  State<HoverCard> createState() =>
      _HoverCardState();
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
        duration: const Duration(
          milliseconds: 200,
        ),

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

  final XFile? image =
      await picker.pickImage(
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
      appBar: AppBar(
        
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            const SizedBox(height: 20),

            const Text(
              "Upload Your Photo",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Upload a clear image and choose your desired styling mode.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),

              child: selectedImage == null
                  ? const Center(
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        size: 80,
                      ),
                    )
                  : ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    selectedImage!.path,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                )
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                pickImage();
              },

              icon: const Icon(Icons.upload),

              label: const Text("Upload Image"),
            ),

            const SizedBox(height: 40),

            const Text(
              "Choose Style",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
                                      ? const Color(0xFFF4F6E5)
                                      : Colors.white,

                                  borderRadius: BorderRadius.circular(20),

                                  border: Border.all(
                                    color: selectedStyle == "formal"
                                        ? const Color(0xFFF4F6E5)
                                        : Colors.grey.shade300,
                                  ),
                                ),

                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.business_center,
                                      size: 40,
                                    ),
                                    SizedBox(height: 8),
                                    Text("Formal"),
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
                                      ? const Color(0xFFF4F6E5)
                                      : Colors.white,

                                  borderRadius: BorderRadius.circular(20),

                                  border: Border.all(
                                    color: selectedStyle == "leisure"
                                        ? const Color(0xFFF4F6E5)
                                        : Colors.grey.shade300,
                                  ),
                                ),

                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.weekend,
                                      size: 40,
                                    ),
                                    SizedBox(height: 8),
                                    Text("Leisure"),
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

                const Center(
                  child: CircularProgressIndicator(),
                ),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    "Analyzing your style...",
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
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Vision Analysis",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                        "Detected Features",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        """
                      Gender: ${visionResult?['profile']?['user_features']?['gender'] ?? ""}
                      Skin Tone: ${visionResult?['profile']?['user_features']?['skin_tone'] ?? ""}
                      Hairstyle: ${visionResult?['profile']?['user_features']?['hairstyle'] ?? ""}
                      Body Type: ${visionResult?['profile']?['user_features']?['body_type'] ?? ""}
                      """,
                      ),
                    const Text(
                      "Advantages",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item.toString(),
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
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      visionResult?["profile"]?["comments"] ?? "",
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
  imagePath:
    visionResult?["user_image_path"] ?? "",
  styleType: selectedStyle,
),
  ),
);
                },

                child: const Text(
                  "Continue to Wardrobe Selection",
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