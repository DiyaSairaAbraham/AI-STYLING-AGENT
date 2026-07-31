import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../services/image_service.dart';

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







  @override
  Widget build(BuildContext context) {


    return Scaffold(



      appBar: AppBar(


        title: const Text(

          'AI Styling Agent',

        ),



        actions: [


          IconButton(

            icon: const Icon(

              Icons.checkroom,

            ),



            tooltip: "My Wardrobe",



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






      body: Padding(


        padding: const EdgeInsets.all(20),



        child: Column(



          children: [





            Expanded(



              child: _selectedImage != null



                  ? FutureBuilder<Uint8List>(


                      future: _selectedImage!.readAsBytes(),



                      builder: (context, snapshot) {



                        if (!snapshot.hasData) {



                          return const Center(



                            child: CircularProgressIndicator(),



                          );


                        }



                        return Image.memory(



                          snapshot.data!,



                          fit: BoxFit.contain,



                        );


                      },


                    )



                  : const Center(



                      child: Icon(



                        Icons.image,



                        size: 120,



                      ),



                    ),



            ),







            const SizedBox(height: 20),







            Text(



              _status,



              textAlign: TextAlign.center,



              style: const TextStyle(



                fontSize: 16,



              ),



            ),






            const SizedBox(height: 20),







            SizedBox(



              width: double.infinity,



              child: ElevatedButton(



                onPressed: _pickImage,



                child: const Text(



                  'Upload User Image',



                ),



              ),



            ),







            const SizedBox(height: 12),







            SizedBox(



              width: double.infinity,



              child: ElevatedButton(



                onPressed: _loading

                    ? null

                    : _generateOutfit,



                child: _loading



                    ? const SizedBox(



                        width: 20,



                        height: 20,



                        child: CircularProgressIndicator(



                          strokeWidth: 2,



                        ),



                      )



                    : const Text(



                        'Generate Outfit',



                      ),



              ),



            ),





          ],



        ),



      ),



    );


  }


}