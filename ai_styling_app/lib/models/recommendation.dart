class ShoppingItem {


  final String idBaju;

  final String description;

  final String hm;

  final String uniqlo;



  ShoppingItem({

    required this.idBaju,

    required this.description,

    required this.hm,

    required this.uniqlo,

  });



  factory ShoppingItem.fromJson(
      Map<String,dynamic> json
  ){

    return ShoppingItem(

      idBaju:
      json["id_baju"] ?? "",


      description:
      json["description"] ?? "",


      hm:
      json["hm"] ?? "",


      uniqlo:
      json["uniqlo"] ?? "",


    );

  }

}





class ShoppingLinks {


  final List<ShoppingItem> items;



  ShoppingLinks({

    required this.items,

  });




  factory ShoppingLinks.fromJson(
      Map<String,dynamic> json
  ){


    return ShoppingLinks(

      items:
      (json["items"] as List? ?? [])

          .map(

            (item)=>
            ShoppingItem.fromJson(item),

      )

          .toList(),

    );


  }


}







class Recommendation {


  final String outfitName;


  final String imagePath;


  final String stylingAdvice;


  final List<String> selectedItems;


  final ShoppingLinks? shoppingLinks;




  Recommendation({

    required this.outfitName,

    required this.imagePath,

    required this.stylingAdvice,

    required this.selectedItems,

    this.shoppingLinks,

  });






  factory Recommendation.fromJson(
      Map<String,dynamic> json
  ){

    return Recommendation(


      outfitName:
      json["category"] ?? "",



      imagePath:
      json["image_path"] ?? "",



      stylingAdvice:
      json["styling_advice"] ?? "",




      selectedItems:


      (json["selected_items"] as List? ?? [])

          .map(

              (item)=>
              item["id_baju"].toString()

      )

          .toList(),




      shoppingLinks:


      json["shopping_links"] != null

          ?

      ShoppingLinks.fromJson(

          json["shopping_links"]

      )

          :

      null,


    );


  }


}