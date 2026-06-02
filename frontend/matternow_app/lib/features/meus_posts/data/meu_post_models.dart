import '../../home/data/home_models.dart';

/// Estado em que se encontra um post no fluxo "Meus posts".
enum StatusPost { ativo, resolvido }

StatusPost _statusFromValor(int? v) {
  switch (v) {
    case 1: return StatusPost.resolvido;
    default: return StatusPost.ativo;
  }
}

/// Resumo de impacto exibido no topo da tela de "Meus posts".
class ImpactoComunidade {
  final int itensReaproveitados;
  final double faturamento;
  final int maesAjudadas;

  const ImpactoComunidade({
    required this.itensReaproveitados,
    required this.faturamento,
    required this.maesAjudadas,
  });

  factory ImpactoComunidade.fromJson(Map<String, dynamic> json) =>
      ImpactoComunidade(
        itensReaproveitados: (json['itensReaproveitados'] as int?) ?? 0,
        faturamento: (json['faturamento'] as num?)?.toDouble() ?? 0,
        maesAjudadas: (json['maesAjudadas'] as int?) ?? 0,
      );

  static const vazio = ImpactoComunidade(
    itensReaproveitados: 0,
    faturamento: 0,
    maesAjudadas: 0,
  );
}

/// Um post (venda/doação/pergunta/dica) publicado pelo usuário atual.
class MeuPost {
  final String id;
  final TipoAnuncio tipo;
  final String titulo;
  final String? descricao;
  final String? fotoUrl;
  final StatusPost status;
  final int visualizacoes;
  final int curtidas;
  final int comentarios;
  final int favoritos;
  final int ajudouMaes;
  final DateTime criadoEm;
  final DateTime? resolvidoEm;
  final String? autorNome;
  final String? autorAvatarUrl;

  /// Texto opcional de um banner contextual exibido dentro do card (ex.:
  /// "Sua pergunta ajudou 18 mães. Marcar como resolvido?"). Replica o
  /// "Banner inside card" do Figma.
  final String? bannerInterno;

  const MeuPost({
    required this.id,
    required this.tipo,
    required this.titulo,
    this.descricao,
    this.fotoUrl,
    required this.status,
    this.visualizacoes = 0,
    this.curtidas = 0,
    this.comentarios = 0,
    this.favoritos = 0,
    this.ajudouMaes = 0,
    required this.criadoEm,
    this.resolvidoEm,
    this.autorNome,
    this.autorAvatarUrl,
    this.bannerInterno,
  });

  bool get resolvido => status == StatusPost.resolvido;

  factory MeuPost.fromJson(Map<String, dynamic> json) => MeuPost(
        id: json['id'] as String,
        tipo: _tipoFromValor(json['tipo'] as int?),
        titulo: (json['titulo'] as String?) ?? '',
        descricao: json['descricao'] as String?,
        fotoUrl: json['fotoUrl'] as String?,
        status: _statusFromValor(json['status'] as int?),
        visualizacoes: (json['visualizacoes'] as int?) ?? 0,
        curtidas: (json['curtidas'] as int?) ?? 0,
        comentarios: (json['comentarios'] as int?) ?? 0,
        favoritos: (json['favoritos'] as int?) ?? 0,
        ajudouMaes: (json['ajudouMaes'] as int?) ?? 0,
        criadoEm: DateTime.parse(json['criadoEm'] as String),
        resolvidoEm: json['resolvidoEm'] == null
            ? null
            : DateTime.parse(json['resolvidoEm'] as String),
        autorNome: json['autorNome'] as String?,
        autorAvatarUrl: json['autorAvatarUrl'] as String?,
        bannerInterno: json['bannerInterno'] as String?,
      );
}

// O backend devolve `tipo` como inteiro nas demais áreas; reaproveitamos a
// mesma convenção (consistente com `AnuncioFeed`).
TipoAnuncio _tipoFromValor(int? v) {
  switch (v) {
    case 1: return TipoAnuncio.venda;
    case 2: return TipoAnuncio.doacao;
    case 3: return TipoAnuncio.pergunta;
    case 4: return TipoAnuncio.dica;
    default: return TipoAnuncio.outro;
  }
}

/// Resposta consolidada do endpoint `GET /api/meus-posts`.
class MeusPostsResponse {
  final ImpactoComunidade impacto;
  final List<MeuPost> ativos;
  final List<MeuPost> resolvidos;

  const MeusPostsResponse({
    required this.impacto,
    required this.ativos,
    required this.resolvidos,
  });

  factory MeusPostsResponse.fromJson(Map<String, dynamic> json) =>
      MeusPostsResponse(
        impacto: json['impacto'] == null
            ? ImpactoComunidade.vazio
            : ImpactoComunidade.fromJson(json['impacto'] as Map<String, dynamic>),
        ativos: ((json['ativos'] as List<dynamic>?) ?? const [])
            .map((e) => MeuPost.fromJson(e as Map<String, dynamic>))
            .toList(),
        resolvidos: ((json['resolvidos'] as List<dynamic>?) ?? const [])
            .map((e) => MeuPost.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
