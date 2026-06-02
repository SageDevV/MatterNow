import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../auth/data/auth_models.dart';
import 'anuncio_models.dart';

/// Repositório do fluxo de "Vender item". Quando o backend expuser
/// `POST /api/anuncios`, esta classe estará pronta para enviar o payload.
class AnuncioRepository {
  AnuncioRepository({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _kTokenKey = 'matternow.jwt';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  /// Publica um novo anúncio na comunidade. Retorna o id atribuído pelo
  /// backend. Lança [AuthFailure] em caso de erro.
  Future<String> publicar(NovoAnuncio anuncio) async {
    return _post(anuncio.toJson());
  }

  /// Publica uma nova doação na comunidade. Retorna o id atribuído pelo
  /// backend. Reaproveita o mesmo endpoint `POST /api/anuncios` enviando
  /// `tipo=doacao` no payload.
  Future<String> doar(NovaDoacao doacao) async {
    return _post(doacao.toJson());
  }

  /// Publica uma nova pergunta na comunidade. Reaproveita o mesmo endpoint
  /// enviando `tipo=pergunta` no payload.
  Future<String> perguntar(NovaPergunta pergunta) async {
    return _post(pergunta.toJson());
  }

  /// Publica uma nova "Dica de mãe" na comunidade. Reaproveita o mesmo
  /// endpoint enviando `tipo=dica` no payload.
  Future<String> compartilharDica(NovaDica dica) async {
    return _post(dica.toJson());
  }

  Future<String> _post(Map<String, dynamic> payload) async {
    final token = await _storage.read(key: _kTokenKey);
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/anuncios'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return '';
      final corpo = jsonDecode(response.body) as Map<String, dynamic>;
      return (corpo['id'] as String?) ?? '';
    }

    final corpo = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    throw AuthFailure(
      corpo['detail']?.toString() ??
          corpo['title']?.toString() ??
          'Não foi possível publicar o anúncio.',
      statusCode: response.statusCode,
    );
  }
}
