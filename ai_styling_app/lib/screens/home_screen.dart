import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../services/image_service.dart';

import 'options_screen.dart';
import 'wardrobe_screen.dart';
import 'upload_screen.dart';

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



  Widget _featureCard(
      IconData icon,
      String title,
    ) {

      return Card(

        child: Padding(

          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),

          child: Column(

            children: [

              Icon(
                icon,
                size: 32,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,
              ),

            ],

          ),

        ),

      );

    }



  
  @override Widget build(BuildContext context) {

  return Scaffold(

    appBar: AppBar(

      title: const Text(
        "AI Styling Agent",
      ),

      actions: [

        IconButton(

          icon: const Icon(
            Icons.checkroom,
          ),

          onPressed: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WardrobeScreen(),
              ),
            );

          },

        ),

      ],

    ),

    body: SafeArea(

      child: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            const SizedBox(height: 20),


            Container(
              height: 220,
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF4F6E5),
                    Colors.white,
                  ],
                ),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  "assets/images/fashion_banner.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(

                children: [

                  Expanded(
                    child: _featureCard(
                      Icons.psychology,
                      "AI Analysis",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _featureCard(
                      Icons.checkroom,
                      "Outfits",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _featureCard(
                      Icons.auto_awesome,
                      "Generation",
                    ),
                  ),

                ],

              ),

            const Text(

              "AI Styling Agent",

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),

            ),

            const SizedBox(height: 10),

            const Text(

              "Upload your photo and receive AI-powered outfit recommendations tailored to your style.",

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),

            ),

            const SizedBox(height: 40),
          

            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                icon: const Icon(
                  Icons.upload,
                ),

                label: const Text(
                  "Start Styling",
                ),

                onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const UploadScreen(),
    ),
  );
},

              ),

            ),

            const SizedBox(height: 20),

          ],

        ),

      ),

    ),

  );

}


}