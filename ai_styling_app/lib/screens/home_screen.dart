import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../services/image_service.dart';

import 'options_screen.dart';
import 'wardrobe_screen.dart';
import 'upload_screen.dart';
import 'start_styling_button.dart';
class HomeScreen extends StatefulWidget {

  const HomeScreen({
    super.key,
  });


  @override
  State<HomeScreen> createState() => _HomeScreenState();

}


class _HomeScreenState extends State<HomeScreen> {


  final ImageService _imageService = ImageService();

  final ApiService _apiService = ApiService();


  XFile? _selectedImage;


  bool _loading = false;


  String _status = 'No image selected';

  static const Color _purpleDeep = Color(0xFF4C2FD6);
  static const Color _purpleAccent = Color(0xFF6C48F2);
  static const Color _purpleSoft = Color(0xFF7B5CF0);
  static const Color _bgLight = Color(0xFFEDE8FD);
  static const Color _inkDark = Color(0xFF1A1B4B);
  static const Color _inkMuted = Color(0xFF5A5B7E);

  Future<void> _pickImage() async {


    final image = await _imageService.pickImage();


    if (image != null) {

      setState(() {

        _selectedImage = image;

        _status = 'Image selected: ${image.name}';

      });

    }

  }





  Future<void> _generateOutfit() async {


    if (_selectedImage == null) {

      setState(() {

        _status = 'Please select an image first';

      });

      return;

    }



    setState(() {

      _loading = true;

      _status = 'Generating outfit options...';

    });



    final result = await _apiService.generateOptions(

      _selectedImage!,

    );



    setState(() {

      _loading = false;

    });



    if (result != null) {


      setState(() {

        _status = 'Options generated successfully';

      });



      if (mounted) {


        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => OptionsScreen(

              optionsData: result,

            ),

          ),

        );


      }



    } else {


      setState(() {

        _status = 'Failed to generate options';

      });


    }


  }


  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const Text(
                      "My Wardrobe",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          IconButton(
            icon: const Icon(Icons.checkroom),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WardrobeScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: _bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- AI Powered badge ----------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _purpleSoft.withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: _purpleDeep),
                      SizedBox(width: 8),
                      Text(
                        'AI POWERED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _purpleDeep,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Main headline ----------
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'AI Personal\n',
                        style: TextStyle(
                          fontSize: 38,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: _inkDark,
                        ),
                      ),
                      TextSpan(
                        text: 'Styling\n',
                        style: TextStyle(
                          fontSize: 38,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: _purpleAccent,
                        ),
                      ),
                      TextSpan(
                        text: 'Consultant',
                        style: TextStyle(
                          fontSize: 38,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: _inkDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Accent underline like the reference
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _purpleAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Subtitle ----------
                const Text(
                  'Your personal AI stylist that understands you '
                  'and creates looks that make you look and feel your best.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: _inkMuted,
                  ),
                ),
                const SizedBox(height: 32),

                // ---------- Feature cards row ----------
                IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _featureCard(
                          icon: Icons.face_retouching_natural,
                          title: 'Smart Analysis',
                          subtitle: 'AI analyzes your style, body & preferences.',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _featureCard(
                          icon: Icons.checkroom,
                          title: 'Style Matching',
                          subtitle: 'Finds the perfect outfits that match you.',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _featureCard(
                          icon: Icons.auto_awesome,
                          title: 'AI Generation',
                          subtitle: 'Generates unique looks just for you.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

              
                // ---------- AI Generated banner ----------
                Container(
                  width: double.infinity,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_purpleDeep, _purpleSoft],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 26, color: Colors.white),
                      SizedBox(width: 14),
                      Text(
                        'AI Generated\nJust for You',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Personalized strip ----------
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
                      color: _purpleSoft.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 18,
                        color: _purpleDeep,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Personalized. Intelligent. Effortless.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _inkDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 200),

                // ---------- Start Styling button ----------
                StartStylingButton(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UploadScreen()),
    );
  },
),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Feature card ----------
  Widget _featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _purpleDeep, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _inkDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              height: 1.3,
              color: _inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Recommended style card ----------
  Widget _styleCard(String label, String rating) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            height: 95,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, size: 40, color: _purpleSoft),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _inkDark,
                  ),
                ),
              ),
              const Icon(Icons.star, size: 14, color: Color(0xFFE8A33D)),
              Text(
                rating,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _inkDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- Small helpers ----------

class _Swatch extends StatelessWidget {
  final Color color;
  const _Swatch(this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF4C2FD6)   // _purpleDeep
            : const Color(0xFFC9C4E8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}