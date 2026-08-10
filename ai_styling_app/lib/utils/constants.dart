import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    // Android emulator
    // return 'http://10.0.2.2:8000';

    // Physical phone (replace with your laptop IPv4 address)
    return 'http://10.144.195.115:8000';
  }
}