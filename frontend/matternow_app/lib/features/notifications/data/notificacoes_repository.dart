import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/auth_models.dart';
import 'notificacao_models.dart';

class NotificacoesRepository {
  NotificacoesRepository({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _kTokenKey = 'matternow.jwt';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<List<Notificacao>> listar() async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/notificacoes'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => Notificacao.fromJson(e as Map<String, dynamic>)).toList();
    }
    _falhar(response);
  }

  Future<void> marcarTodasComoLidas() async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/notificacoes/marcar-lidas'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) _falhar(response);
  }

  Never _falhar(http.Response response) {
    final corpo = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    throw AuthFailure(
      corpo['detail']?.toString() ?? corpo['title']?.toString() ?? 'Falha na requisição.',
      statusCode: response.statusCode,
    );
  }
}
