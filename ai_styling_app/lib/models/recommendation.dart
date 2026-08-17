class ShoppingItem {
  final String idBaju;
  final String description;
  final String hm;
  final String uniqlo;

  const ShoppingItem({
    required this.idBaju,
    required this.description,
    required this.hm,
    required this.uniqlo,
  });

  factory ShoppingItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ShoppingItem(
      idBaju: json['id_baju']?.toString() ?? '',
      description:
          json['description']?.toString() ?? '',
      hm: json['hm']?.toString() ?? '',
      uniqlo:
          json['uniqlo']?.toString() ?? '',
    );
  }
}

class ShoppingLinks {
  final List<ShoppingItem> items;

  const ShoppingLinks({
    required this.items,
  });

  factory ShoppingLinks.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawItems = json['items'];

    if (rawItems is! List) {
      return const ShoppingLinks(items: []);
    }

    return ShoppingLinks(
      items: rawItems
          .whereType<Map>()
          .map(
            (item) =>
                ShoppingItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
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

  const Recommendation({
    required this.outfitName,
    required this.imagePath,
    required this.stylingAdvice,
    required this.selectedItems,
    this.shoppingLinks,
  });

  factory Recommendation.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawItems =
        json['selected_items'];

    final selected = rawItems is List
        ? rawItems
            .map(
              (item) {
                if (item is Map) {
                  return item['id_baju']
                          ?.toString() ??
                      '';
                }

                return item.toString();
              },
            )
            .toList()
        : <String>[];

    final shopping =
        json['shopping_links'];

    return Recommendation(
      outfitName:
          json['category']?.toString() ?? '',
      imagePath:
          json['image_path']?.toString() ?? '',
      stylingAdvice:
          json['styling_advice']?.toString() ?? '',
      selectedItems: selected,
      shoppingLinks: shopping is Map
          ? ShoppingLinks.fromJson(
              Map<String, dynamic>.from(
                shopping,
              ),
            )
          : null,
    );
  }
}