import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class ApiService {
  // Use the same PC IP that opens FastAPI Swagger on your phone.
  static const String baseUrl = 'http://xxxxxxxxxxxxxx:8000';

  Future<File> _convertToJpg(File source) async {
    final bytes = await source.readAsBytes();

    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw const FormatException(
        'Unable to decode the selected image.',
      );
    }

    final jpgBytes = Uint8List.fromList(
      img.encodeJpg(decoded, quality: 95),
    );

    final output = File(
      '${Directory.systemTemp.path}/ai_styling_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await output.writeAsBytes(jpgBytes);

    return output;
  }

  Future<Map<String, dynamic>> uploadUserImage(
    File image,
  ) async {
    final convertedFile = await _convertToJpg(image);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/recommendation/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'user_image',
          convertedFile.path,
          filename: 'user_image.jpg',
          contentType: null,
        ),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Image upload failed '
          '(${response.statusCode}): $body',
        );
      }

      return _decodeObject(body);
    } finally {
      if (await convertedFile.exists()) {
        await convertedFile.delete();
      }
    }
  }

  Future<Map<String, dynamic>> generateAiStyle(
    String userImagePath,
  ) {
    return _postJson(
      '/recommendation/ai-style',
      {
        'user_image_path': userImagePath,
      },
    );
  }

  Future<Map<String, dynamic>> generateWardrobeStyle({
    required String userImagePath,
    required String wardrobeSource,
  }) {
    return _postJson(
      '/recommendation/wardrobe-style',
      {
        'user_image_path': userImagePath,
        'wardrobe_source': wardrobeSource,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getWardrobe(
    String source,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wardrobe/$source'),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Unable to load wardrobe '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final data = _decodeObject(response.body);
    final rawItems = data['items'];

    if (rawItems is! List) {
      return <Map<String, dynamic>>[];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  Future<Map<String, dynamic>> addWardrobeItem({
    required String source,
    required File image,
  }) async {
    final convertedFile = await _convertToJpg(image);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/wardrobe/add/$source'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          convertedFile.path,
          filename: 'wardrobe_item.jpg',
          contentType: null,
        ),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Unable to add wardrobe item '
          '(${response.statusCode}): $body',
        );
      }

      return _decodeObject(body);
    } finally {
      if (await convertedFile.exists()) {
        await convertedFile.delete();
      }
    }
  }

  Future<Map<String, dynamic>> deleteWardrobeItem({
    required String source,
    required String itemId,
  }) async {
    if (itemId.trim().isEmpty) {
      throw const FormatException(
        'Wardrobe item ID is empty.',
      );
    }

    final response = await http.delete(
      Uri.parse(
        '$baseUrl/wardrobe/$source/${Uri.encodeComponent(itemId)}',
      ),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Unable to delete wardrobe item '
        '(${response.statusCode}): ${response.body}',
      );
    }

    return _decodeObject(response.body);
  }

  String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return imagePath;
    }

    final normalized =
        imagePath.replaceAll('\\', '/');

    if (normalized.startsWith('/')) {
      return '$baseUrl$normalized';
    }

    return '$baseUrl/$normalized';
  }

  Future<Map<String, dynamic>> _postJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Request failed '
        '(${response.statusCode}): ${response.body}',
      );
    }

    return _decodeObject(response.body);
  }

  Map<String, dynamic> _decodeObject(
    String body,
  ) {
    final decoded = jsonDecode(body);

    if (decoded is! Map) {
      throw const FormatException(
        'Expected a JSON object from the server.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }
}