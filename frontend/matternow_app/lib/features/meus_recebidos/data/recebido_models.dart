/// Tipo de origem de um item recebido — reaproveitado em badges.
enum TipoRecebido { venda, doacao }

extension TipoRecebidoX on TipoRecebido {
  String get rotulo {
    switch (this) {
      case TipoRecebido.venda: return 'VENDA';
      case TipoRecebido.doacao: return 'DOAÇÃO';
    }
  }

  String get valor {
    switch (this) {
      case TipoRecebido.venda: return 'venda';
      case TipoRecebido.doacao: return 'doacao';
    }
  }
}

TipoRecebido _tipoFromValor(int? v) {
  switch (v) {
    case 1: return TipoRecebido.venda;
    case 2: return TipoRecebido.doacao;
    default: return TipoRecebido.doacao;
  }
}

/// Status do item dentro do fluxo "Meus recebidos".
enum StatusRecebido { pendente, recebido }

StatusRecebido _statusFromValor(int? v) {
  switch (v) {
    case 1: return StatusRecebido.recebido;
    default: return StatusRecebido.pendente;
  }
}

/// Item recebido (comprado ou doado) que aparece na tela "Meus recebidos".
class Recebido {
  final String id;
  final TipoRecebido tipo;
  final String titulo;
  final String? fotoUrl;
  final String parceiroNome;
  final int parceiroAjudouMaes;
  final StatusRecebido status;
  final DateTime? recebidoEm;
  final DateTime? avaliadoEm;

  const Recebido({
    required this.id,
    required this.tipo,
    required this.titulo,
    this.fotoUrl,
    required this.parceiroNome,
    this.parceiroAjudouMaes = 0,
    required this.status,
    this.recebidoEm,
    this.avaliadoEm,
  });

  bool get pendente => status == StatusRecebido.pendente;

  /// Rótulo do "papel" do parceiro: "Doador(a)" para doação, "Vendedor(a)"
  /// para venda. Reflete os textos do Figma.
  String get parceiroRotulo => tipo == TipoRecebido.doacao
      ? 'Doador(a): $parceiroNome'
      : 'Vendedor(a): $parceiroNome';

  factory Recebido.fromJson(Map<String, dynamic> json) => Recebido(
        id: json['id'] as String,
        tipo: _tipoFromValor(json['tipo'] as int?),
        titulo: (json['titulo'] as String?) ?? '',
        fotoUrl: json['fotoUrl'] as String?,
        parceiroNome: (json['parceiroNome'] as String?) ?? '',
        parceiroAjudouMaes: (json['parceiroAjudouMaes'] as int?) ?? 0,
        status: _statusFromValor(json['status'] as int?),
        recebidoEm: json['recebidoEm'] == null
            ? null
            : DateTime.parse(json['recebidoEm'] as String),
        avaliadoEm: json['avaliadoEm'] == null
            ? null
            : DateTime.parse(json['avaliadoEm'] as String),
      );
}

/// Estado do produto avaliado pelo recebedor — espelha os chips do Figma.
enum EstadoAvaliacao { excelente, bom, ruim, comDefeito }

extension EstadoAvaliacaoX on EstadoAvaliacao {
  String get rotulo {
    switch (this) {
      case EstadoAvaliacao.excelente: return '✨ Excelente';
      case EstadoAvaliacao.bom: return '🙂 Bom';
      case EstadoAvaliacao.ruim: return '😕 Ruim';
      case EstadoAvaliacao.comDefeito: return '⚠️ Com defeito';
    }
  }

  String get valor {
    switch (this) {
      case EstadoAvaliacao.excelente: return 'excelente';
      case EstadoAvaliacao.bom: return 'bom';
      case EstadoAvaliacao.ruim: return 'ruim';
      case EstadoAvaliacao.comDefeito: return 'com_defeito';
    }
  }
}

/// Payload de uma avaliação de item recebido.
class AvaliacaoRecebido {
  final EstadoAvaliacao estado;
  final bool marcouAjudou;

  const AvaliacaoRecebido({
    required this.estado,
    required this.marcouAjudou,
  });

  Map<String, dynamic> toJson() => {
        'estado': estado.valor,
        'marcouAjudou': marcouAjudou,
      };
}

/// Resposta de `GET /api/meus-recebidos` — separa pendentes do histórico
/// já confirmado para acelerar a renderização.
class MeusRecebidosResponse {
  final List<Recebido> pendentes;
  final List<Recebido> historico;

  const MeusRecebidosResponse({
    required this.pendentes,
    required this.historico,
  });

  bool get vazio => pendentes.isEmpty && historico.isEmpty;

  factory MeusRecebidosResponse.fromJson(Map<String, dynamic> json) =>
      MeusRecebidosResponse(
        pendentes: ((json['pendentes'] as List<dynamic>?) ?? const [])
            .map((e) => Recebido.fromJson(e as Map<String, dynamic>))
            .toList(),
        historico: ((json['historico'] as List<dynamic>?) ?? const [])
            .map((e) => Recebido.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static const vazio_ = MeusRecebidosResponse(pendentes: [], historico: []);
}
