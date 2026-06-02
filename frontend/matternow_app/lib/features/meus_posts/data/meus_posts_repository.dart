import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/auth_models.dart';
import 'meu_post_models.dart';

/// Repositório do fluxo "Meus posts". Quando o backend expuser
/// `GET /api/meus-posts`, esta classe estará pronta para consumi-lo.
class MeusPostsRepository {
  MeusPostsRepository({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _kTokenKey = 'matternow.jwt';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<MeusPostsResponse> obter() async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/meus-posts'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
      return MeusPostsResponse.fromJson(body);
    }
    _falhar(response);
  }

  Future<void> marcarComoResolvido(String postId) async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/meus-posts/$postId/resolver'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      _falhar(response);
    }
  }

  Future<void> excluir(String postId) async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/meus-posts/$postId'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) _falhar(response);
  }

  Never _falhar(http.Response response) {
    final corpo = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    throw AuthFailure(
      corpo['detail']?.toString() ??
          corpo['title']?.toString() ??
          'Falha na requisição.',
      statusCode: response.statusCode,
    );
  }
}
