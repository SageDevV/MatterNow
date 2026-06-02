import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _kTokenKey = 'matternow.jwt';
  static const _kUserKey = 'matternow.user';
  static const _kLastAccountKey = 'matternow.lastAccount';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<AuthResponse> registrar({
    required String nome,
    required String email,
    String? telefone,
    required String senha,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        if (telefone != null && telefone.trim().isNotEmpty) 'telefone': telefone.trim(),
        'senha': senha,
      }),
    );
    return _processarResposta(response);
  }

  Future<AuthResponse> login({required String email, required String senha}) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    return _processarResposta(response);
  }

  /// Solicita o envio de um código de recuperação por e-mail.
  /// O backend sempre responde 204 mesmo quando o e-mail não existe.
  Future<void> esqueceuSenha({required String email}) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 204) _falharCom(response);
  }

  /// Redefine a senha usando o código recebido por e-mail.
  Future<void> redefinirSenha({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/reset-password'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'codigo': codigo,
        'novaSenha': novaSenha,
      }),
    );
    if (response.statusCode != 204) _falharCom(response);
  }

  Never _falharCom(http.Response response) {
    final corpo = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    throw AuthFailure(
      corpo['detail']?.toString() ??
          corpo['title']?.toString() ??
          _primeiroErroDeValidacao(corpo) ??
          'Falha na requisição.',
      statusCode: response.statusCode,
    );
  }

  Future<AuthResponse> _processarResposta(http.Response response) async {
    final corpo = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final auth = AuthResponse.fromJson(corpo);
      await _persistir(auth);
      return auth;
    }

    final detalhe = corpo['detail'] ?? corpo['title'] ?? _primeiroErroDeValidacao(corpo) ?? 'Falha na requisição.';
    throw AuthFailure(detalhe.toString(), statusCode: response.statusCode);
  }

  String? _primeiroErroDeValidacao(Map<String, dynamic> corpo) {
    final errors = corpo['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final primeiro = errors.values.first;
      if (primeiro is List && primeiro.isNotEmpty) return primeiro.first.toString();
    }
    return null;
  }

  Future<void> _persistir(AuthResponse auth) async {
    await _storage.write(key: _kTokenKey, value: auth.token);
    final perfil = jsonEncode({'id': auth.usuarioId, 'nome': auth.nome, 'email': auth.email});
    await _storage.write(key: _kUserKey, value: perfil);
    // Mantém um snapshot leve da última conta usada — sobrevive ao logout para
    // alimentar o seletor de conta na tela de login.
    await _storage.write(key: _kLastAccountKey, value: perfil);
  }

  Future<bool> isAutenticado() async {
    final token = await _storage.read(key: _kTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String>?> usuarioCorrente() async {
    final raw = await _storage.read(key: _kUserKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Última conta usada nesse dispositivo. Persiste mesmo após logout.
  Future<Map<String, String>?> ultimaConta() async {
    final raw = await _storage.read(key: _kLastAccountKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> esquecerUltimaConta() => _storage.delete(key: _kLastAccountKey);

  Future<void> sair() async {
    await _storage.delete(key: _kTokenKey);
    await _storage.delete(key: _kUserKey);
  }
}
