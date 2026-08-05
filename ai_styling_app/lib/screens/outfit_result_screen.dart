import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/recommendation.dart';



class OutfitResultScreen extends StatelessWidget {


  final String imageUrl;

  final Recommendation recommendation;



  const OutfitResultScreen({

    super.key,

    required this.imageUrl,

    required this.recommendation,

  });





  Future<void> _openUrl(String url) async {


    if(url.isEmpty){
      return;
    }



    final Uri uri =
    Uri.parse(url);



    await launchUrl(

      uri,

      mode:
      LaunchMode.externalApplication,

    );


  }






  @override
  Widget build(BuildContext context) {



    final uniqueImageUrl =
        "$imageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}";



    return Scaffold(


      appBar:
      AppBar(

        title:
        const Text(
          "Generated Outfit",
        ),

      ),




      body:

      SingleChildScrollView(


        child:

        Column(


          children:[



            Image.network(

              uniqueImageUrl,

              height:450,

              fit:
              BoxFit.contain,

              errorBuilder:
                  (context,error,stack){

                return const Text(
                  "Failed to load image",
                );

              },

            ),




            const SizedBox(
              height:20,
            ),




            Text(

              recommendation.outfitName,


              style:
              const TextStyle(

                fontSize:24,

                fontWeight:
                FontWeight.bold,

              ),

            ),




            Padding(

              padding:
              const EdgeInsets.all(16),


              child:

              Text(

                recommendation.stylingAdvice,

                textAlign:
                TextAlign.center,

              ),

            ),




            const SizedBox(
              height:20,
            ),





            if(recommendation.shoppingLinks != null)

              Column(

                children:[



                  const Text(

                    "Shop Similar Items",

                    style:
                    TextStyle(

                      fontSize:20,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),




                  const SizedBox(
                    height:15,
                  ),




                  ...recommendation
                      .shoppingLinks!
                      .items
                      .map(



                          (item){


                        return Card(


                          margin:
                          const EdgeInsets.all(10),


                          child:

                          Padding(

                            padding:
                            const EdgeInsets.all(12),


                            child:

                            Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,


                              children:[



                                Text(

                                  item.description,

                                  style:
                                  const TextStyle(

                                    fontWeight:
                                    FontWeight.bold,

                                  ),

                                ),




                                const SizedBox(
                                  height:10,
                                ),




                                Row(

                                  children:[


                                    Expanded(

                                      child:

                                      ElevatedButton(

                                        onPressed:(){

                                          _openUrl(
                                            item.hm,
                                          );

                                        },


                                        child:
                                        const Text(
                                          "H&M",
                                        ),

                                      ),

                                    ),




                                    const SizedBox(
                                      width:10,
                                    ),





                                    Expanded(

                                      child:

                                      ElevatedButton(

                                        onPressed:(){

                                          _openUrl(
                                            item.uniqlo,
                                          );

                                        },


                                        child:
                                        const Text(
                                          "Uniqlo",
                                        ),

                                      ),

                                    ),



                                  ],

                                )


                              ],


                            ),


                          ),


                        );


                      }

                  )


                ],

              )



          ],


        ),


      ),


    );

  }


}