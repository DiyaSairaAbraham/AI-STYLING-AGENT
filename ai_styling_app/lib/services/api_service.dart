import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';

class ApiService {
  static const Duration _requestTimeout = Duration(minutes: 2);

  static String get baseUrl => AppConstants.baseUrl;

  // ==========================================================
  // IMAGE CONTENT TYPE
  // ==========================================================

  MediaType _getImageContentType(String filename) {
    final name = filename.toLowerCase();

    if (name.endsWith('.png')) {
      return MediaType('image', 'png');
    }

    if (name.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }

    if (name.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }

    if (name.endsWith('.bmp')) {
      return MediaType('image', 'bmp');
    }

    if (name.endsWith('.heic')) {
      return MediaType('image', 'heic');
    }

    if (name.endsWith('.heif')) {
      return MediaType('image', 'heif');
    }

    // JPEG is the default for camera/gallery images.
    return MediaType('image', 'jpeg');
  }

  // ==========================================================
  // TEST API CONNECTION
  // ==========================================================

  Future<bool> testConnection() async {
    final uri = Uri.parse('$baseUrl/docs');

    developer.log('========================================');
    developer.log('TESTING API CONNECTION');
    developer.log('URL: $uri');
    developer.log('========================================');

    try {
      final response = await http
          .get(
            uri,
            headers: const {
              'Accept': 'text/html',
            },
          )
          .timeout(const Duration(seconds: 10));

      developer.log(
        'Connection test status: ${response.statusCode}',
      );

      developer.log(
        'Connection response length: ${response.body.length}',
      );

      if (response.statusCode == 200) {
        developer.log('API CONNECTION: SUCCESS');
        return true;
      }

      developer.log(
        'API CONNECTION: FAILED - HTTP ${response.statusCode}',
      );

      return false;
    } catch (e, stackTrace) {
      developer.log(
        'API CONNECTION: FAILED',
        error: e,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ==========================================================
  // FULL PIPELINE
  // Vision + Wardrobe + Stylist + Image
  // ==========================================================

  Future<Map<String, dynamic>?> generateRecommendation(
    XFile imageFile,
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/recommendation/generate',
      );

      developer.log('========================================');
      developer.log('FULL PIPELINE');
      developer.log('URL: $uri');
      developer.log('Image: ${imageFile.name}');
      developer.log('========================================');

      final bytes = await imageFile.readAsBytes();

      if (bytes.isEmpty) {
        developer.log('ERROR: User image is empty.');
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'user_image',
          bytes,
          filename: imageFile.name,
          contentType: _getImageContentType(imageFile.name),
        ),
      );

      developer.log(
        'Uploading ${bytes.length} bytes as ${imageFile.name}',
      );

      final streamedResponse = await request
          .send()
          .timeout(_requestTimeout);

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      developer.log(
        'Generate Status: ${response.statusCode}',
      );

      developer.log(
        'Generate Body: ${response.body}',
      );

      return _decodeMapResponse(
        response,
        operation: 'Full pipeline',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Generate failed',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // LEGACY MULTIPART OPTIONS
  // ==========================================================

  Future<Map<String, dynamic>?> generateOptions(
    XFile imageFile,
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/recommendation/options',
      );

      developer.log(
        'Legacy Options URL: $uri',
      );

      final bytes = await imageFile.readAsBytes();

      if (bytes.isEmpty) {
        developer.log(
          'ERROR: Image file is empty.',
        );
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'user_image',
          bytes,
          filename: imageFile.name,
          contentType: _getImageContentType(imageFile.name),
        ),
      );

      final streamedResponse = await request
          .send()
          .timeout(_requestTimeout);

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      developer.log(
        'Legacy Options Status: ${response.statusCode}',
      );

      developer.log(
        'Legacy Options Body: ${response.body}',
      );

      return _decodeMapResponse(
        response,
        operation: 'Legacy options',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Legacy options failed',
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
      final uri = Uri.parse(
        '$baseUrl/recommendation/regenerate',
      );

      final requestBody = <String, dynamic>{
        'user_image_path': userImagePath,
      };

      developer.log('========================================');
      developer.log('REGENERATE ALL RECOMMENDATIONS');
      developer.log('URL: $uri');
      developer.log(
        'Request: ${jsonEncode(requestBody)}',
      );
      developer.log('========================================');

      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_requestTimeout);

      developer.log(
        'Regenerate Status: ${response.statusCode}',
      );

      developer.log(
        'Regenerate Body: ${response.body}',
      );

      return _decodeMapResponse(
        response,
        operation: 'Regenerate recommendations',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Regeneration failed',
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
      final uri = Uri.parse(
        '$baseUrl/recommendation/regenerate-one',
      );

      final requestBody = <String, dynamic>{
        'user_image_path': userImagePath,
        'category': category,
      };

      developer.log('========================================');
      developer.log('REGENERATE ONE RECOMMENDATION');
      developer.log('URL: $uri');
      developer.log(
        'Request: ${jsonEncode(requestBody)}',
      );
      developer.log('========================================');

      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_requestTimeout);

      developer.log(
        'Regenerate One Status: ${response.statusCode}',
      );

      developer.log(
        'Regenerate One Body: ${response.body}',
      );

      return _decodeMapResponse(
        response,
        operation: 'Regenerate one recommendation',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Regenerate one failed',
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
      final uri = Uri.parse(
        '$baseUrl/recommendation/generate-image',
      );

      final requestBody = <String, dynamic>{
        'prompt': prompt,
        'user_image_path': userImagePath,
      };

      developer.log('========================================');
      developer.log('GENERATE SELECTED OUTFIT IMAGE');
      developer.log('URL: $uri');
      developer.log(
        'Request: ${jsonEncode(requestBody)}',
      );
      developer.log('========================================');

      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_requestTimeout);

      developer.log(
        'Image Status: ${response.statusCode}',
      );

      developer.log(
        'Image Body: ${response.body}',
      );

      return _decodeMapResponse(
        response,
        operation: 'Selected outfit image',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Image generation failed',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // GET WARDROBE
  // ==========================================================

  Future<Map<String, dynamic>?> getWardrobe() async {
    try {
      final uri = Uri.parse(
        '$baseUrl/wardrobe/',
      );

      developer.log('========================================');
      developer.log('GET WARDROBE');
      developer.log('URL: $uri');
      developer.log('========================================');

      final response = await http
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(_requestTimeout);

      developer.log(
        'Wardrobe Status: ${response.statusCode}',
      );

      developer.log(
        'Wardrobe Body: ${response.body}',
      );

      return _decodeMapResponse(
        response,
        operation: 'Get wardrobe',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Get wardrobe failed',
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
      final uri = Uri.parse(
        '$baseUrl/wardrobe/add',
      );

      developer.log('========================================');
      developer.log('ADD WARDROBE ITEM');
      developer.log('URL: $uri');
      developer.log('File: ${imageFile.name}');
      developer.log('========================================');

      final bytes = await imageFile.readAsBytes();

      if (bytes.isEmpty) {
        developer.log(
          'ERROR: Wardrobe image is empty.',
        );
        return null;
      }

      developer.log(
        'Image bytes: ${bytes.length}',
      );

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.headers['Accept'] = 'application/json';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
          contentType: _getImageContentType(
            imageFile.name,
          ),
        ),
      );

      developer.log(
        'Multipart file added successfully.',
      );

      final streamedResponse = await request
          .send()
          .timeout(_requestTimeout);

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      developer.log(
        'Add wardrobe status: ${response.statusCode}',
      );

      developer.log(
        'Add wardrobe response: ${response.body}',
      );

      return _decodeMapResponse(
        response,
        operation: 'Add wardrobe item',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Add wardrobe failed',
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
      final uri = Uri.parse(
        '$baseUrl/wardrobe/$itemId',
      );

      developer.log('========================================');
      developer.log('DELETE WARDROBE ITEM');
      developer.log('URL: $uri');
      developer.log('Item ID: $itemId');
      developer.log('========================================');

      final response = await http
          .delete(
            uri,
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(_requestTimeout);

      developer.log(
        'Delete status: ${response.statusCode}',
      );

      developer.log(
        'Delete response: ${response.body}',
      );

      return response.statusCode == 200;
    } catch (e, stackTrace) {
      developer.log(
        'Delete wardrobe failed',
        error: e,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ==========================================================
  // VISION ANALYSIS
  // ==========================================================

  Future<Map<String, dynamic>?> analyzeImage({
    required XFile imageFile,
    required String styleType,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/vision/analyze',
      );

      developer.log('========================================');
      developer.log('VISION ANALYSIS');
      developer.log('URL: $uri');
      developer.log('Style Type: $styleType');
      developer.log('File: ${imageFile.name}');
      developer.log('========================================');

      final bytes = await imageFile.readAsBytes();

      if (bytes.isEmpty) {
        developer.log(
          'ERROR: Vision image is empty.',
        );
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.fields['style_type'] = styleType;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
          contentType: _getImageContentType(
            imageFile.name,
          ),
        ),
      );

      final streamedResponse = await request
          .send()
          .timeout(_requestTimeout);

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      developer.log(
        'Vision Status: ${response.statusCode}',
      );

      developer.log(
        'Vision Body: ${response.body}',
      );

      return _decodeMapResponse(
        response,
        operation: 'Vision analysis',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Vision analysis failed',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // GENERATE OUTFIT OPTIONS
  //
  // PERSONAL:
  //     selected_item_ids may contain items.
  //
  // PERSONAL WITH NOTHING SELECTED:
  //     selected_item_ids is sent as an empty list.
  //     Backend can curate from the entire personal wardrobe.
  //
  // COMMERCIAL:
  //     selected_item_ids is empty.
  //
  // OPEN WORLD:
  //     selected_item_ids is empty.
  // ==========================================================

  Future<Map<String, dynamic>?> generateOutfitOptions({
    required String userImagePath,
    required String styleType,
    required String wardrobeSource,
    List<String> selectedItemIds = const <String>[],
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/recommendation/options',
      );

      final requestBody = <String, dynamic>{
        'user_image_path': userImagePath,
        'style_type': styleType,
        'wardrobe_source': wardrobeSource,

        // Always send the list.
        // An empty list means "curate from personal wardrobe".
        'selected_item_ids': selectedItemIds,
      };

      developer.log('========================================');
      developer.log('GENERATE OUTFIT OPTIONS');
      developer.log('URL: $uri');
      developer.log(
        'User Image Path: $userImagePath',
      );
      developer.log(
        'Style Type: $styleType',
      );
      developer.log(
        'Wardrobe Source: $wardrobeSource',
      );
      developer.log(
        'Selected Item IDs: $selectedItemIds',
      );
      developer.log(
        'Selected Count: ${selectedItemIds.length}',
      );
      developer.log(
        'Request: ${jsonEncode(requestBody)}',
      );
      developer.log('========================================');

      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_requestTimeout);

      developer.log(
        'Generate Outfit Options Status: '
        '${response.statusCode}',
      );

      developer.log(
        'Generate Outfit Options Body: '
        '${response.body}',
      );

      return _decodeMapResponse(
        response,
        operation: 'Generate outfit options',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Generate outfit options failed',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // RESPONSE DECODER
  // ==========================================================

  Map<String, dynamic>? _decodeMapResponse(
    http.Response response, {
    required String operation,
  }) {
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      developer.log(
        '$operation failed with HTTP '
        '${response.statusCode}',
      );

      developer.log(
        'Server response: ${response.body}',
      );

      return null;
    }

    if (response.body.trim().isEmpty) {
      developer.log(
        '$operation returned an empty response.',
      );

      return null;
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      developer.log(
        '$operation returned invalid JSON format.',
      );

      return null;
    } on FormatException catch (e, stackTrace) {
      developer.log(
        '$operation returned invalid JSON.',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }
}