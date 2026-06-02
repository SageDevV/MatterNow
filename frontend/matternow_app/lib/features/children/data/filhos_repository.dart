import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/auth_models.dart';
import 'filho_models.dart';

class FilhosRepository {
  FilhosRepository({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _kTokenKey = 'matternow.jwt';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<List<Filho>> listar() async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/filhos'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    return _processarLista(response);
  }

  Future<Filho> criar({
    required String nome,
    String? avatar,
    DateTime? dataNascimento,
    String? faixaEtaria,
    String? tamanhoRoupa,
    GeneroFilho genero = GeneroFilho.naoInformar,
    double? pesoKg,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/filhos'),
      headers: await _headers(),
      body: jsonEncode(_payload(
        nome: nome,
        avatar: avatar,
        dataNascimento: dataNascimento,
        faixaEtaria: faixaEtaria,
        tamanhoRoupa: tamanhoRoupa,
        genero: genero,
        pesoKg: pesoKg,
      )),
    );
    return _processarItem(response);
  }

  Future<Filho> atualizar({
    required String id,
    required String nome,
    String? avatar,
    DateTime? dataNascimento,
    String? faixaEtaria,
    String? tamanhoRoupa,
    GeneroFilho genero = GeneroFilho.naoInformar,
    double? pesoKg,
  }) async {
    final response = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}/api/filhos/$id'),
      headers: await _headers(),
      body: jsonEncode(_payload(
        nome: nome,
        avatar: avatar,
        dataNascimento: dataNascimento,
        faixaEtaria: faixaEtaria,
        tamanhoRoupa: tamanhoRoupa,
        genero: genero,
        pesoKg: pesoKg,
      )),
    );
    return _processarItem(response);
  }

  Future<void> remover(String id) async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/filhos/$id'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) _falhar(response);
  }

  // --- privado ---------------------------------------------------------------

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: _kTokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _payload({
    required String nome,
    String? avatar,
    DateTime? dataNascimento,
    String? faixaEtaria,
    String? tamanhoRoupa,
    required GeneroFilho genero,
    double? pesoKg,
  }) =>
      {
        'nome': nome,
        if (avatar != null) 'avatar': avatar,
        if (dataNascimento != null)
          'dataNascimento':
              '${dataNascimento.year.toString().padLeft(4, '0')}-${dataNascimento.month.toString().padLeft(2, '0')}-${dataNascimento.day.toString().padLeft(2, '0')}',
        if (faixaEtaria != null) 'faixaEtaria': faixaEtaria,
        if (tamanhoRoupa != null) 'tamanhoRoupa': tamanhoRoupa,
        'genero': genero.valor,
        if (pesoKg != null) 'pesoKg': pesoKg,
      };

  List<Filho> _processarLista(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => Filho.fromJson(e as Map<String, dynamic>)).toList();
    }
    _falhar(response);
  }

  Filho _processarItem(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
      return Filho.fromJson(body);
    }
    _falhar(response);
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
