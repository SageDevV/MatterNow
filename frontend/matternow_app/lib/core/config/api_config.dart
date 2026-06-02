import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Endpoint do backend. Use --dart-define=MATTERNOW_API_URL=http://... para sobrescrever.
class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    const override = String.fromEnvironment('MATTERNOW_API_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'http://localhost:5080';
    if (Platform.isAndroid) return 'http://10.0.2.2:5080'; // emulador Android
    return 'http://localhost:5080';
  }
}
