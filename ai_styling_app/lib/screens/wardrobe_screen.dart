import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


import '../models/wardrobe_item.dart';
import '../services/wardrobe_service.dart';



class WardrobeScreen extends StatefulWidget {


  const WardrobeScreen({
    super.key
  });



  @override
  State<WardrobeScreen> createState()
      => _WardrobeScreenState();

}





class _WardrobeScreenState 
extends State<WardrobeScreen>{



  final WardrobeService service =
      WardrobeService();



  List<WardrobeItem> wardrobe=[];



  bool loading=true;





  @override
  void initState(){

    super.initState();

    loadWardrobe();

  }





  Future<void> loadWardrobe() async{


    setState((){

      loading=true;

    });



    wardrobe =
        await service.getWardrobe();



    setState((){

      loading=false;

    });


  }





  Future<void> addItem() async{


    final picker =
        ImagePicker();



    final image =
        await picker.pickImage(

          source:
          ImageSource.gallery

        );



    if(image==null)
    {return;}
      



    await service.addClothing(image);



    loadWardrobe();


  }





  Future<void> deleteItem(
      String id
  ) async{


    await service.deleteClothing(id);


    await loadWardrobe();


  }





  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar: AppBar(

        title:
        const Text(
          "My Wardrobe"
        ),


        actions:[

          IconButton(

            icon:
            const Icon(
              Icons.add
            ),


            onPressed:
            addItem,

          )

        ],

      ),




      body:


      loading

      ?

      const Center(
        child:
        CircularProgressIndicator()
      )


      :


      GridView.builder(

        padding:
        const EdgeInsets.all(12),


        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount:2,

          childAspectRatio:
          0.65

        ),



        itemCount:
        wardrobe.length,



        itemBuilder:
        (context,index){



          final item =
          wardrobe[index];



          return Card(

            child:
            Column(


              children:[



                Expanded(

                  child:
                  Image.network(

                    "${
                      WardrobeService.baseUrl
                    }${item.imagePath}",


                    fit:
                    BoxFit.cover,

                  ),

                ),



                Text(
                  item.category
                ),


                Text(
                  item.color
                ),



                IconButton(

                  icon:
                  const Icon(
                    Icons.delete
                  ),


                  onPressed:
                  ()=>
                  deleteItem(
                    item.id
                  ),

                )



              ],


            ),


          );



        },


      ),


    );

  }



}