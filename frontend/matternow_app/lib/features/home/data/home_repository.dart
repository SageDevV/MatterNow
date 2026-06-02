import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/auth_models.dart';
import 'home_models.dart';

class HomeRepository {
  HomeRepository({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _kTokenKey = 'matternow.jwt';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<HomeData> obter() async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/feed/home'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return HomeData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    final corpo = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    throw AuthFailure(
      corpo['detail']?.toString() ?? corpo['title']?.toString() ?? 'Falha na requisição.',
      statusCode: response.statusCode,
    );
  }
}
