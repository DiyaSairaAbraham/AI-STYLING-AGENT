import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';

class ApiService {
  /// Uses the platform-specific URL configured in AppConstants.
  static String get baseUrl => AppConstants.baseUrl;

  // ==========================================================
  // FULL PIPELINE
  // Vision + Wardrobe + Stylist + Image
  // ==========================================================

  Future<Map<String, dynamic>?> generateRecommendation(
    XFile imageFile,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/recommendation/generate'),
      );

      final bytes = await imageFile.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'user_image',
          bytes,
          filename: imageFile.name,
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      developer.log(
        'Generate Status: ${response.statusCode}',
      );

      developer.log(
        'Generate Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Generate failed: $e',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // GENERATE OUTFIT OPTIONS
  // Vision + Wardrobe + Stylist
  // ==========================================================

  Future<Map<String, dynamic>?> generateOptions(
    XFile imageFile,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/recommendation/options'),
      );

      final bytes = await imageFile.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'user_image',
          bytes,
          filename: imageFile.name,
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      developer.log(
        'Options Status: ${response.statusCode}',
      );

      developer.log(
        'Options Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Options failed: $e',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // REGENERATE ALL OUTFIT RECOMMENDATIONS
  // ==========================================================

  Future<Map<String, dynamic>?> regenerateRecommendations(
    String userImagePath,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommendation/regenerate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_image_path': userImagePath,
        }),
      );

      developer.log(
        'Regenerate Status: ${response.statusCode}',
      );

      developer.log(
        'Regenerate Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Regeneration failed: $e',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // REGENERATE ONE OUTFIT RECOMMENDATION
  // ==========================================================

  Future<Map<String, dynamic>?> regenerateOneRecommendation({
    required String userImagePath,
    required String category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommendation/regenerate-one'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_image_path': userImagePath,
          'category': category,
        }),
      );

      developer.log(
        'Regenerate One Status: ${response.statusCode}',
      );

      developer.log(
        'Regenerate One Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Regenerate one failed: $e',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // GENERATE SELECTED OUTFIT IMAGE
  // ==========================================================

  Future<Map<String, dynamic>?> generateSelectedOutfit({
    required String prompt,
    required String userImagePath,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommendation/generate-image'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
          'user_image_path': userImagePath,
        }),
      );

      developer.log(
        'Image Status: ${response.statusCode}',
      );

      developer.log(
        'Image Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Image generation failed: $e',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // WARDROBE
  // Get all wardrobe items
  // ==========================================================

  Future<Map<String, dynamic>?> getWardrobe() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wardrobe/'),
      );

      developer.log(
        'Wardrobe Status: ${response.statusCode}',
      );

      developer.log(
        'Wardrobe Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Get wardrobe failed: $e',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // ADD CLOTHING ITEM
  // ==========================================================

  Future<Map<String, dynamic>?> addWardrobeItem(
    XFile imageFile,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/wardrobe/add'),
      );

      final bytes = await imageFile.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      developer.log(
        'Add wardrobe status: ${response.statusCode}',
      );

      developer.log(
        'Add wardrobe response: ${response.body}',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Add wardrobe failed: $e',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // DELETE CLOTHING ITEM
  // ==========================================================

  Future<bool> deleteWardrobeItem(
    String itemId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/wardrobe/$itemId'),
      );

      developer.log(
        'Delete status: ${response.statusCode}',
      );

      developer.log(
        'Delete response: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e, stackTrace) {
      developer.log(
        'Delete wardrobe failed: $e',
        error: e,
        stackTrace: stackTrace,
      );

      return false;
    }
  }
}