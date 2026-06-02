class AuthResponse {
  final String usuarioId;
  final String nome;
  final String email;
  final String token;
  final DateTime expiraEm;

  AuthResponse({
    required this.usuarioId,
    required this.nome,
    required this.email,
    required this.token,
    required this.expiraEm,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        usuarioId: json['usuarioId'] as String,
        nome: json['nome'] as String,
        email: json['email'] as String,
        token: json['token'] as String,
        expiraEm: DateTime.parse(json['expiraEm'] as String),
      );
}

class AuthFailure implements Exception {
  final String mensagem;
  final int? statusCode;
  AuthFailure(this.mensagem, {this.statusCode});

  bool get sessaoExpirada => statusCode == 401;

  @override
  String toString() => mensagem;
}

/// Origem do cadastro em andamento.
enum CadastroOrigem { manual, google }

/// Dados coletados na tela de cadastro, mantidos enquanto o usuário lê e
/// aceita os Termos de Uso antes de chegarem ao backend.
class CadastroPendente {
  final CadastroOrigem origem;
  final String nome;
  final String email;
  final String? telefone;
  final String? senha;

  const CadastroPendente({
    required this.origem,
    required this.nome,
    required this.email,
    this.telefone,
    this.senha,
  });

  bool get viaGoogle => origem == CadastroOrigem.google;
}
