import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/auth_models.dart';

class PreferenciasNotificacao {
  final bool email;
  final bool push;
  final bool mensagens;

  const PreferenciasNotificacao({
    this.email = false,
    this.push = false,
    this.mensagens = false,
  });

  factory PreferenciasNotificacao.fromJson(Map<String, dynamic> json) =>
      PreferenciasNotificacao(
        email: (json['email'] as bool?) ?? false,
        push: (json['push'] as bool?) ?? false,
        mensagens: (json['mensagens'] as bool?) ?? false,
      );

  List<String> toChaves() {
    final r = <String>[];
    if (email) r.add('email');
    if (push) r.add('push');
    if (mensagens) r.add('messages');
    return r;
  }
}

class SettingsRepository {
  SettingsRepository({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _kTokenKey = 'matternow.jwt';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: _kTokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> atualizarEmail(String email) async {
    final r = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/me/email'),
      headers: await _headers(),
      body: jsonEncode({'email': email}),
    );
    if (r.statusCode != 204) _falhar(r);
  }

  Future<void> alterarSenha({required String senhaAtual, required String novaSenha}) async {
    final r = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/me/password'),
      headers: await _headers(),
      body: jsonEncode({'senhaAtual': senhaAtual, 'novaSenha': novaSenha}),
    );
    if (r.statusCode != 204) _falhar(r);
  }

  Future<PreferenciasNotificacao> obterNotificacoes() async {
    final r = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/me/notifications'),
      headers: await _headers(),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return PreferenciasNotificacao.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    }
    _falhar(r);
  }

  Future<PreferenciasNotificacao> atualizarNotificacoes(PreferenciasNotificacao prefs) async {
    final r = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/me/notifications'),
      headers: await _headers(),
      body: jsonEncode({'chaves': prefs.toChaves()}),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return PreferenciasNotificacao.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    }
    _falhar(r);
  }

  Future<void> cancelarConta() async {
    final r = await _client.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios/me'),
      headers: await _headers(),
    );
    if (r.statusCode != 204) _falhar(r);
  }

  Never _falhar(http.Response r) {
    final body = r.body.isEmpty ? <String, dynamic>{} : jsonDecode(r.body) as Map<String, dynamic>;
    throw AuthFailure(
      body['detail']?.toString() ?? body['title']?.toString() ?? 'Falha na requisição.',
      statusCode: r.statusCode,
    );
  }
}
