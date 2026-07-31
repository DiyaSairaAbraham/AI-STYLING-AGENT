import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/wardrobe_item.dart';
import '../utils/constants.dart';



class WardrobeService {


  static String get baseUrl =>
      AppConstants.baseUrl;



  // ================================
  // GET WARDROBE
  // ================================


  Future<List<WardrobeItem>> getWardrobe() async {


    final response = await http.get(

      Uri.parse(
        "$baseUrl/wardrobe/"
      )

    );


    if(response.statusCode == 200){


      final data =
          jsonDecode(response.body);



      List items =
          data["items"];



      return items
          .map(
            (item)=>
            WardrobeItem.fromJson(item)
          )
          .toList();

    }


    throw Exception(
      "Failed to load wardrobe"
    );

  }






  // ================================
  // ADD CLOTHING
  // ================================


  Future<bool> addClothing(
      XFile image
  ) async {



    final request =
        http.MultipartRequest(

          "POST",

          Uri.parse(
            "$baseUrl/wardrobe/add"
          )

        );



    request.files.add(

      await http.MultipartFile.fromPath(

        "file",

        image.path,

      )

    );



    final response =
        await request.send();



    return response.statusCode == 200;


  }






  // ================================
  // DELETE CLOTHING
  // ================================


  Future<bool> deleteClothing(
      String id
  ) async {


    final response =
        await http.delete(

          Uri.parse(
            "$baseUrl/wardrobe/$id"
          )

        );



    return response.statusCode == 200;


  }



}