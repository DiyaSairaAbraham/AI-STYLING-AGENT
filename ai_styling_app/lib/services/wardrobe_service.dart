import 'dart:io';

import 'api_service.dart';

class WardrobeService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getPersonalWardrobe() {
    return _api.getWardrobe('personal');
  }

  Future<List<Map<String, dynamic>>> getCommercialWardrobe() {
    return _api.getWardrobe('commercial');
  }

  Future<Map<String, dynamic>> addPersonalItem(
    File image,
  ) {
    return _api.addWardrobeItem(
      source: 'personal',
      image: image,
    );
  }

  Future<Map<String, dynamic>> deletePersonalItem(
    String itemId,
  ) {
    return _api.deleteWardrobeItem(
      source: 'personal',
      itemId: itemId,
    );
  }
}