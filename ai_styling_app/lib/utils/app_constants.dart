class AppConstants {
  static const String baseUrl = 'http://xxxxxxxxxxxxxxxxx:8000';//change according to phone,webapp,emulator

  static const String uploadUserImage =
      '$baseUrl/recommendation/upload';

  static const String aiStyling =
      '$baseUrl/recommendation/ai-style';

  static const String wardrobeStyling =
      '$baseUrl/recommendation/wardrobe-style';

  static const String regenerateAiStyling =
      '$baseUrl/recommendation/regenerate';

  static const String regenerateWardrobeStyling =
      '$baseUrl/recommendation/regenerate-wardrobe';

  static String wardrobe(String source) =>
      '$baseUrl/wardrobe/$source';

  static String addWardrobeItem(String source) =>
      '$baseUrl/wardrobe/add/$source';

  static String deleteWardrobeItem(
    String source,
    String itemId,
  ) =>
      '$baseUrl/wardrobe/$source/$itemId';

  static String buildWardrobe(String source) =>
      '$baseUrl/wardrobe/build/$source';

  static String imageUrl(String filename) =>
      '$baseUrl/images/$filename';
}