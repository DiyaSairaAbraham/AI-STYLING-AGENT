import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/wardrobe_item.dart';
import '../utils/constants.dart';

class WardrobeService {
  static String get baseUrl => AppConstants.baseUrl;

  // =====================================================
  // GET PERSONAL WARDROBE
  // =====================================================

  Future<List<WardrobeItem>> getWardrobe() async {
    final Uri uri = Uri.parse('$baseUrl/wardrobe/');

    try {
      developer.log(
        'GET $uri',
        name: 'WardrobeService',
      );

      final http.Response response = await http.get(uri);

      developer.log(
        'GET wardrobe response: '
        '${response.statusCode} ${response.reasonPhrase}',
        name: 'WardrobeService',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load wardrobe. '
          'Status: ${response.statusCode}. '
          'Body: ${response.body}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid wardrobe response format.',
        );
      }

      final dynamic itemsData = decoded['items'];

      if (itemsData is! List) {
        throw const FormatException(
          'Wardrobe response does not contain an items list.',
        );
      }

      final List<WardrobeItem> items = <WardrobeItem>[];

      for (final dynamic item in itemsData) {
        if (item is! Map) {
          throw const FormatException(
            'Invalid wardrobe item format.',
          );
        }

        items.add(
          WardrobeItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }

      developer.log(
        'Loaded ${items.length} personal wardrobe items.',
        name: 'WardrobeService',
      );

      return items;
    } on FormatException {
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'GET wardrobe failed.',
        name: 'WardrobeService',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // ADD PERSONAL CLOTHING
  // =====================================================

  Future<bool> addClothing(XFile image) async {
    final Uri uri = Uri.parse('$baseUrl/wardrobe/add');

    try {
      developer.log(
        'POST $uri',
        name: 'WardrobeService',
      );

      final http.MultipartRequest request =
          http.MultipartRequest(
        'POST',
        uri,
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          filename: image.name,
        ),
      );

      final http.StreamedResponse response =
          await request.send();

      final String responseBody =
          await response.stream.bytesToString();

      developer.log(
        'POST wardrobe/add response: '
        '${response.statusCode} ${response.reasonPhrase}',
        name: 'WardrobeService',
      );

      if (response.statusCode == 200) {
        developer.log(
          'Personal clothing item added successfully.',
          name: 'WardrobeService',
        );

        return true;
      }

      developer.log(
        'ADD CLOTHING ERROR RESPONSE: $responseBody',
        name: 'WardrobeService',
        level: 1000,
      );

      return false;
    } catch (error, stackTrace) {
      developer.log(
        'ADD CLOTHING failed.',
        name: 'WardrobeService',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // =====================================================
  // DELETE PERSONAL CLOTHING
  // =====================================================

  Future<bool> deleteClothing(String id) async {
    final String encodedId = Uri.encodeComponent(id);

    final Uri uri = Uri.parse(
      '$baseUrl/wardrobe/$encodedId',
    );

    try {
      developer.log(
        'DELETE $uri',
        name: 'WardrobeService',
      );

      final http.Response response =
          await http.delete(uri);

      developer.log(
        'DELETE wardrobe response: '
        '${response.statusCode} ${response.reasonPhrase}',
        name: 'WardrobeService',
      );

      if (response.statusCode == 200) {
        developer.log(
          'Personal clothing item deleted successfully.',
          name: 'WardrobeService',
        );

        return true;
      }

      developer.log(
        'DELETE CLOTHING ERROR BODY: ${response.body}',
        name: 'WardrobeService',
        level: 1000,
      );

      return false;
    } catch (error, stackTrace) {
      developer.log(
        'DELETE CLOTHING failed.',
        name: 'WardrobeService',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}