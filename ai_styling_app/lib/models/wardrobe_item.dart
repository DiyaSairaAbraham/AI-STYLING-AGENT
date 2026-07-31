class WardrobeItem {

  final String id;
  final String imagePath;

  final String category;
  final String color;
  final String style;


  WardrobeItem({

    required this.id,
    required this.imagePath,
    required this.category,
    required this.color,
    required this.style,

  });



  factory WardrobeItem.fromJson(
      Map<String,dynamic> json
  ){

    return WardrobeItem(

      id: json["id_baju"],

      imagePath:
          json["image_path"],

      category:
          json["category"],

      color:
          json["color"],

      style:
          json["style"],

    );

  }

}