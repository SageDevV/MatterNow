import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/auth_models.dart';
import 'profile_models.dart';

class ProfileRepository {
  ProfileRepository({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _kTokenKey = 'matternow.jwt';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<Perfil> obterMeuPerfil() async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/me'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    return _processar(response);
  }

  Future<Perfil> atualizarPerfil({
    String? nome,
    String? localizacao,
    String? avatar,
    List<String>? interesses,
  }) async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/me'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (nome != null) 'nome': nome,
        if (localizacao != null) 'localizacao': localizacao,
        if (avatar != null) 'avatar': avatar,
        if (interesses != null) 'interesses': interesses,
      }),
    );
    return _processar(response);
  }

  Perfil _processar(http.Response response) {
    final corpo = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Perfil.fromJson(corpo);
    }
    throw AuthFailure(
      corpo['detail']?.toString() ?? corpo['title']?.toString() ?? 'Falha na requisição.',
      statusCode: response.statusCode,
    );
  }
}
