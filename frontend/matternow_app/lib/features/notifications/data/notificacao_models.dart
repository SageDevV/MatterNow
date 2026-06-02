enum TipoNotificacao { info, favorito, curtida, avaliacao, mensagem }

TipoNotificacao _tipoFromValor(int? v) {
  switch (v) {
    case 1: return TipoNotificacao.favorito;
    case 2: return TipoNotificacao.curtida;
    case 3: return TipoNotificacao.avaliacao;
    case 4: return TipoNotificacao.mensagem;
    default: return TipoNotificacao.info;
  }
}

class Notificacao {
  final String id;
  final TipoNotificacao tipo;
  final String titulo;
  final String? subtitulo;
  final bool lida;
  final DateTime criadoEm;

  const Notificacao({
    required this.id,
    required this.tipo,
    required this.titulo,
    this.subtitulo,
    required this.lida,
    required this.criadoEm,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) => Notificacao(
        id: json['id'] as String,
        tipo: _tipoFromValor(json['tipo'] as int?),
        titulo: (json['titulo'] as String?) ?? '',
        subtitulo: json['subtitulo'] as String?,
        lida: (json['lida'] as bool?) ?? false,
        criadoEm: DateTime.parse(json['criadoEm'] as String),
      );
}
