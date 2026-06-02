enum TipoAnuncio { venda, doacao, pergunta, dica, outro }

TipoAnuncio _tipoFromValor(int? v) {
  switch (v) {
    case 1: return TipoAnuncio.venda;
    case 2: return TipoAnuncio.doacao;
    case 3: return TipoAnuncio.pergunta;
    case 4: return TipoAnuncio.dica;
    default: return TipoAnuncio.outro;
  }
}

class AnuncioFeed {
  final String id;
  final TipoAnuncio tipo;
  final String tipoNome;
  final String titulo;
  final String? descricao;
  final double? valor;
  final String? localizacao;
  final String? fotoUrl;
  final String? tag;
  final int visualizacoes;
  final int curtidas;
  final int comentarios;
  final String? autorNome;
  final String? autorAvatar;
  final DateTime criadoEm;

  const AnuncioFeed({
    required this.id,
    required this.tipo,
    required this.tipoNome,
    required this.titulo,
    this.descricao,
    this.valor,
    this.localizacao,
    this.fotoUrl,
    this.tag,
    this.visualizacoes = 0,
    this.curtidas = 0,
    this.comentarios = 0,
    this.autorNome,
    this.autorAvatar,
    required this.criadoEm,
  });

  factory AnuncioFeed.fromJson(Map<String, dynamic> json) => AnuncioFeed(
        id: json['id'] as String,
        tipo: _tipoFromValor(json['tipo'] as int?),
        tipoNome: (json['tipoNome'] as String?) ?? '',
        titulo: (json['titulo'] as String?) ?? '',
        descricao: json['descricao'] as String?,
        valor: (json['valor'] as num?)?.toDouble(),
        localizacao: json['localizacao'] as String?,
        fotoUrl: json['fotoUrl'] as String?,
        tag: json['tag'] as String?,
        visualizacoes: (json['visualizacoes'] as int?) ?? 0,
        curtidas: (json['curtidas'] as int?) ?? 0,
        comentarios: (json['comentarios'] as int?) ?? 0,
        autorNome: json['autorNome'] as String?,
        autorAvatar: json['autorAvatar'] as String?,
        criadoEm: DateTime.parse(json['criadoEm'] as String),
      );
}

class HomeData {
  final bool primeiroAcesso;
  final String saudacaoNome;
  final List<AnuncioFeed> comunidade;
  final List<AnuncioFeed> recomendacoes;
  final String? nomeFilhoFoco;

  const HomeData({
    required this.primeiroAcesso,
    required this.saudacaoNome,
    required this.comunidade,
    required this.recomendacoes,
    this.nomeFilhoFoco,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
        primeiroAcesso: (json['primeiroAcesso'] as bool?) ?? false,
        saudacaoNome: (json['saudacaoNome'] as String?) ?? '',
        comunidade: ((json['comunidade'] as List<dynamic>?) ?? const [])
            .map((e) => AnuncioFeed.fromJson(e as Map<String, dynamic>))
            .toList(),
        recomendacoes: ((json['recomendacoes'] as List<dynamic>?) ?? const [])
            .map((e) => AnuncioFeed.fromJson(e as Map<String, dynamic>))
            .toList(),
        nomeFilhoFoco: json['nomeFilhoFoco'] as String?,
      );
}
