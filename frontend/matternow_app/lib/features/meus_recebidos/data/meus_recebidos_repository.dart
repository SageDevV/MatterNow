import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/auth_models.dart';
import 'recebido_models.dart';

/// Repositório do fluxo "Meus recebidos". Quando o backend expuser
/// `GET /api/meus-recebidos` esta classe estará pronta para consumi-lo.
/// Endpoints esperados:
/// * `GET    /api/meus-recebidos`
/// * `POST   /api/meus-recebidos/{id}/confirmar-recebimento`
/// * `POST   /api/meus-recebidos/{id}/avaliar`  (body: AvaliacaoRecebido)
class MeusRecebidosRepository {
  MeusRecebidosRepository({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _kTokenKey = 'matternow.jwt';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<MeusRecebidosResponse> obter() async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/meus-recebidos'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
      return MeusRecebidosResponse.fromJson(body);
    }
    _falhar(response);
  }

  Future<void> confirmarRecebimento(String id) async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.post(
      Uri.parse(
          '${ApiConfig.baseUrl}/api/meus-recebidos/$id/confirmar-recebimento'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      _falhar(response);
    }
  }

  Future<void> avaliar(String id, AvaliacaoRecebido avaliacao) async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/meus-recebidos/$id/avaliar'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(avaliacao.toJson()),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      _falhar(response);
    }
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
