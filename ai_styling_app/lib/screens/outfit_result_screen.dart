import 'package:flutter/material.dart';


class OutfitResultScreen extends StatelessWidget {

  final String imageUrl;


  const OutfitResultScreen({
    super.key,
    required this.imageUrl,
  });



  @override
  Widget build(BuildContext context) {

    // Prevent browser caching old generated images
    final uniqueImageUrl =
        "$imageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}";


    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Generated Outfit",
        ),
      ),


      body: Center(

        child: InteractiveViewer(

          child: Image.network(

            uniqueImageUrl,

            fit: BoxFit.contain,


            loadingBuilder:
                (context, child, loadingProgress) {


              if (loadingProgress == null) {

                return child;

              }


              return const Center(

                child:
                    CircularProgressIndicator(),

              );

            },


            errorBuilder:
                (context, error, stackTrace){


              return const Center(

                child:
                    Text(
                      "Failed to load image",
                    ),

              );

            },

          ),

        ),

      ),

    );

  }

}