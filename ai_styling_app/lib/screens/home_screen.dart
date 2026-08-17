import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import 'options_screen.dart';
import 'wardrobe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedImage = File(picked.path);
    });
  }

  Future<void> _continue() async {
    final image = _selectedImage;

    if (image == null) {
      _showError('Please upload a photo first.');
      return;
    }

    setState(() {
      _uploading = true;
    });

    try {
      final uploadResult = await _api.uploadUserImage(image);

      if (!mounted) {
        return;
      }

      final userImagePath =
          uploadResult['user_image_path']?.toString() ??
          uploadResult['image_path']?.toString() ??
          uploadResult['path']?.toString();

      if (userImagePath == null || userImagePath.isEmpty) {
        throw Exception(
          'The server did not return the uploaded image path.',
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OptionsScreen(
            userImagePath: userImagePath,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.replaceFirst('Exception: ', ''),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            28,
            24,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'AI Personal\nStyling Consultant',
                      style: TextStyle(
                        fontSize: 29,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2F2924),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Personal Wardrobe',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const WardrobeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.checkroom_rounded,
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                'Create a look that works for you.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 28),

              GestureDetector(
                onTap: _uploading ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 470,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.black12,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedImage == null
                      ? const Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons
                                  .add_a_photo_outlined,
                              size: 55,
                              color: Colors.black38,
                            ),
                            SizedBox(height: 18),
                            Text(
                              'Upload your photo',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              'Choose a clear full-body photo',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        )
                      : Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _uploading ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2F2924),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.black26,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  child: _uploading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const WardrobeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.checkroom_outlined,
                  ),
                  label: const Text(
                    'Personal Wardrobe',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(0xFF2F2924),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    side: const BorderSide(
                      color: Colors.black26,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}