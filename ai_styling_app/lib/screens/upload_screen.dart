import 'package:flutter/material.dart';
import '../screens/wardrobe_source_screen.dart';


class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String selectedStyle = "formal";

  bool analysisCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Photo"),
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

              child: const Center(
                child: Icon(
                  Icons.add_a_photo_outlined,
                  size: 80,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                // Image Picker
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
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStyle = "formal";
                      });
                    },

                    child: Container(
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

                const SizedBox(width: 16),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStyle = "leisure";
                      });
                    },

                    child: Container(
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
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  analysisCompleted = true;
                });
              },

              child: const Text("Analyze Style"),
            ),

            const SizedBox(height: 30),

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
                      "Advantages",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "• Good clothing fit\n"
                      "• Balanced proportions\n"
                      "• Clean appearance",
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Areas for Improvement",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "• Add more color contrast\n"
                      "• Improve layering",
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "GPT Stylist Comments",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Your outfit has a clean foundation. "
                      "Adding structured layers and stronger color contrast "
                      "would improve the overall appearance.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                 print("Pressed");
                  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => SelectWardrobeSourceScreen(
  imagePath: "",
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