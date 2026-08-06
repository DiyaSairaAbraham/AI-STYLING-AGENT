import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../services/api_service.dart';
import 'outfit_result_screen.dart';


class OptionsScreen extends StatefulWidget {

  final Map<String, dynamic> optionsData;


  const OptionsScreen({
    super.key,
    required this.optionsData,
  });


  @override
  State<OptionsScreen> createState() =>
      _OptionsScreenState();

}



class _OptionsScreenState extends State<OptionsScreen> {


  final ApiService _apiService = ApiService();

  late List recommendations;

  bool _loading = false;

  String _loadingMessage = "";

  @override
  void initState() {
    super.initState();

    recommendations =
      widget.optionsData["data"]["recommendations"];
  }

  Future<void> _generateOutfit(
    Map<String, dynamic> outfit,
  ) async {


    setState(() {

      _loading = true;
      _loadingMessage = "Creating your outfit image...";
    });



    final result =
        await _apiService.generateSelectedOutfit(

      prompt:
          outfit["image_generation_prompt"],


      userImagePath:
          widget.optionsData["user_image_path"],

    );



    if (!mounted) return;



    setState(() {

      _loading = false;

    });




    if (result != null) {


      final imageUrl =
          result["image_url"];



      if (imageUrl != null) {


        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => OutfitResultScreen(

              imageUrl: imageUrl,
              recommendation: Recommendation.fromJson(
        outfit,
              ),

            ),

          ),

        );


      }

      else {


        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content:
                Text(
                  "Image URL not received",
                ),

          ),

        );


      }



    }

    else {


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
              Text(
                "Failed to generate outfit image",
              ),

        ),

      );


    }



  }



  Future<void> _regenerateRecommendations() async {

    setState(() {
      _loading = true;
      _loadingMessage = "Generating new outfit recommendations...";
    });

    final result =
        await _apiService.regenerateRecommendations(
      widget.optionsData["user_image_path"],
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    if (result != null) {

      setState(() {
        recommendations =
            result["data"]["recommendations"];
      });

    } else {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text(
            "Failed to regenerate recommendations",
          ),
        ),

      );

    }

  }


  @override
  Widget build(BuildContext context) {



    


    return Scaffold(


      appBar: AppBar(

        title:
            const Text(
              "Choose Your Outfit",
            ),

     

        actions: [
          IconButton(
            tooltip: "Generate new outfit recommendations",
            icon: const Icon(Icons.refresh),
            onPressed: _loading
              ? null
              : _regenerateRecommendations,

          ),
        ],
      ),


      body: Stack(


        children: [



          ListView.builder(


            padding:
                const EdgeInsets.all(16),



            itemCount:
                recommendations.length,



            itemBuilder:
                (context,index) {



              final outfit =
                  recommendations[index];



              return Card(


                elevation:5,


                margin:
                    const EdgeInsets.only(
                      bottom:20,
                    ),



                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(15),

                ),




                child:
                    Padding(


                  padding:
                      const EdgeInsets.all(18),




                  child:
                      Column(


                    crossAxisAlignment:
                        CrossAxisAlignment.start,



                    children: [



                      Text(


                        outfit["category"],


                        style:
                            const TextStyle(

                          fontSize:22,

                          fontWeight:
                              FontWeight.bold,

                        ),


                      ),





                      const SizedBox(
                        height:15,
                      ),





                      const Text(


                        "Selected Items",


                        style:
                            TextStyle(

                          fontSize:16,

                          fontWeight:
                              FontWeight.bold,

                        ),


                      ),





                      const SizedBox(
                        height:10,
                      ),





                      ...List.generate(


                        outfit["selected_items"].length,


                        (itemIndex) {



                          final item =
                              outfit["selected_items"]
                              [itemIndex];



                          return Padding(


                            padding:
                                const EdgeInsets.only(
                                  bottom:6,
                                ),



                            child:

                                Text(

                              "• ${item["description"]}",

                            ),


                          );


                        },

                      ),





                      const SizedBox(
                        height:15,
                      ),





                      Text(


                        outfit["styling_advice"],


                        style:
                            const TextStyle(

                          fontSize:14,

                        ),


                      ),





                      const SizedBox(
                        height:20,
                      ),





                      SizedBox(


                        width:
                            double.infinity,



                        child:
                            ElevatedButton(



                          onPressed:
                              _loading
                              ? null
                              :
                              () {


                                _generateOutfit(
                                  outfit,
                                );


                              },



                          child:
                              const Text(

                                "Generate This Outfit",

                              ),


                        ),


                      )



                    ],


                  ),


                ),


              );


            },


          ),






          if(_loading)

            Container(


              color:
                  Colors.black54,



              child:
                   Center(


                child:
                    Column(


                  mainAxisSize:
                      MainAxisSize.min,



                  children: [



                    CircularProgressIndicator(),




                    SizedBox(
                      height:15,
                    ),





                    Text(


                      _loadingMessage,


                      style:
                          const TextStyle(

                        color:
                            Colors.white,

                        fontSize:
                            16,

                      ),


                    )


                  ],


                ),


              ),


            )



        ],


      ),


    );


  }


}