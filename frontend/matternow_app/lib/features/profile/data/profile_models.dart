class Perfil {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? localizacao;
  final String? avatar;
  final List<String> interesses;
  // Estatísticas de impacto exibidas na tela "Perfil".
  final int maesAjudadas;
  final double economizou;
  final int desapegosRealizados;

  const Perfil({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.localizacao,
    this.avatar,
    this.interesses = const [],
    this.maesAjudadas = 0,
    this.economizou = 0,
    this.desapegosRealizados = 0,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) => Perfil(
        id: json['id'] as String,
        nome: json['nome'] as String? ?? '',
        email: json['email'] as String? ?? '',
        telefone: json['telefone'] as String?,
        localizacao: json['localizacao'] as String?,
        avatar: json['avatar'] as String?,
        interesses: (json['interesses'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        maesAjudadas: (json['maesAjudadas'] as num?)?.toInt() ?? 0,
        economizou: (json['economizou'] as num?)?.toDouble() ?? 0,
        desapegosRealizados: (json['desapegosRealizados'] as num?)?.toInt() ?? 0,
      );

  Perfil copyWith({
    String? nome,
    String? localizacao,
    String? avatar,
    List<String>? interesses,
  }) =>
      Perfil(
        id: id,
        nome: nome ?? this.nome,
        email: email,
        telefone: telefone,
        localizacao: localizacao ?? this.localizacao,
        avatar: avatar ?? this.avatar,
        interesses: interesses ?? this.interesses,
        maesAjudadas: maesAjudadas,
        economizou: economizou,
        desapegosRealizados: desapegosRealizados,
      );
}

/// Catálogo fixo de interesses (deve coincidir com o backend para filtros).
class InteressesCatalogo {
  InteressesCatalogo._();

  static const roupasCalcados = 'roupas_calcados';
  static const carrinhoBebeConforto = 'carrinho_bebe_conforto';
  static const bercosMobilias = 'bercos_mobilias';
  static const fraldasEnxoval = 'fraldas_enxoval';
  static const brinquedosLivros = 'brinquedos_livros';
  static const alimentacaoHigiene = 'alimentacao_higiene';

  static const todos = [
    (id: roupasCalcados, label: 'Roupas e calçados'),
    (id: carrinhoBebeConforto, label: 'Carrinho e bebê conforto'),
    (id: bercosMobilias, label: 'Berços e mobílias'),
    (id: fraldasEnxoval, label: 'Fraldas e enxoval'),
    (id: brinquedosLivros, label: 'Brinquedos e livros'),
    (id: alimentacaoHigiene, label: 'Alimentação e higiene'),
  ];
}
