/// Categorias do produto que podem ser anunciadas (corresponde ao Figma).
enum CategoriaProduto {
  carrinhoDeBebe,
  roupas,
  brinquedos,
  moveisInfantis,
  acessorios,
  higiene,
  outros,
}

extension CategoriaProdutoX on CategoriaProduto {
  String get rotulo {
    switch (this) {
      case CategoriaProduto.carrinhoDeBebe: return 'Carrinho de bebê';
      case CategoriaProduto.roupas: return 'Roupas';
      case CategoriaProduto.brinquedos: return 'Brinquedos';
      case CategoriaProduto.moveisInfantis: return 'Móveis infantis';
      case CategoriaProduto.acessorios: return 'Acessórios';
      case CategoriaProduto.higiene: return 'Higiene';
      case CategoriaProduto.outros: return 'Outros';
    }
  }

  /// Valor enviado ao backend (nome estável independente da ordenação do enum).
  String get valor {
    switch (this) {
      case CategoriaProduto.carrinhoDeBebe: return 'carrinho_de_bebe';
      case CategoriaProduto.roupas: return 'roupas';
      case CategoriaProduto.brinquedos: return 'brinquedos';
      case CategoriaProduto.moveisInfantis: return 'moveis_infantis';
      case CategoriaProduto.acessorios: return 'acessorios';
      case CategoriaProduto.higiene: return 'higiene';
      case CategoriaProduto.outros: return 'outros';
    }
  }
}

/// Faixas etárias compatíveis com o catálogo de filhos do app.
class FaixaEtariaAnuncio {
  FaixaEtariaAnuncio._();
  static const opcoes = [
    '1 - 2 anos',
    '2 - 3 anos',
    '4 - 5 anos',
    '6 - 8 anos',
    '9 - 12 anos',
  ];
}

enum EstadoProduto { novo, seminovo, usado }

extension EstadoProdutoX on EstadoProduto {
  String get rotulo {
    switch (this) {
      case EstadoProduto.novo: return 'Novo';
      case EstadoProduto.seminovo: return 'Seminovo';
      case EstadoProduto.usado: return 'Usado';
    }
  }

  String get valor {
    switch (this) {
      case EstadoProduto.novo: return 'novo';
      case EstadoProduto.seminovo: return 'seminovo';
      case EstadoProduto.usado: return 'usado';
    }
  }
}

/// Payload pronto para enviar ao backend ao publicar um anúncio.
class NovoAnuncio {
  final List<String> fotos;
  final CategoriaProduto categoria;
  final String faixaEtaria;
  final EstadoProduto estado;
  final String titulo;
  final String descricao;
  final double preco;
  final String? cep;

  const NovoAnuncio({
    required this.fotos,
    required this.categoria,
    required this.faixaEtaria,
    required this.estado,
    required this.titulo,
    required this.descricao,
    required this.preco,
    this.cep,
  });

  Map<String, dynamic> toJson() => {
        'tipo': 'venda',
        'fotos': fotos,
        'categoria': categoria.valor,
        'faixaEtaria': faixaEtaria,
        'estado': estado.valor,
        'titulo': titulo,
        'descricao': descricao,
        'preco': preco,
        if (cep != null) 'cep': cep,
      };
}

/// Payload de uma doação. Compartilha categoria/faixa etária/estado com a
/// venda, mas substitui o preço por uma "história de amor" (texto livre que
/// descreve a memória ligada ao item).
class NovaDoacao {
  final List<String> fotos;
  final CategoriaProduto categoria;
  final String faixaEtaria;
  final EstadoProduto estado;
  final String titulo;
  final String historia;
  final String? cep;

  const NovaDoacao({
    required this.fotos,
    required this.categoria,
    required this.faixaEtaria,
    required this.estado,
    required this.titulo,
    required this.historia,
    this.cep,
  });

  Map<String, dynamic> toJson() => {
        'tipo': 'doacao',
        'fotos': fotos,
        'categoria': categoria.valor,
        'faixaEtaria': faixaEtaria,
        'estado': estado.valor,
        'titulo': titulo,
        'historia': historia,
        if (cep != null) 'cep': cep,
      };
}

/// Temas disponíveis para uma pergunta na comunidade — replica os chips do
/// frame "Perguntar" do Figma. Difere de [CategoriaProduto] (produtos) porque
/// aqui o foco é o assunto da dúvida.
enum TemaPergunta {
  sono,
  amamentacao,
  saude,
  alimentacao,
  educacao,
  comportamento,
  itens,
  rotina,
  outros,
}

extension TemaPerguntaX on TemaPergunta {
  String get rotulo {
    switch (this) {
      case TemaPergunta.sono: return 'Sono';
      case TemaPergunta.amamentacao: return 'Amamentação';
      case TemaPergunta.saude: return 'Saúde';
      case TemaPergunta.alimentacao: return 'Alimentação';
      case TemaPergunta.educacao: return 'Educação';
      case TemaPergunta.comportamento: return 'Comportamento';
      case TemaPergunta.itens: return 'Itens';
      case TemaPergunta.rotina: return 'Rotina';
      case TemaPergunta.outros: return 'Outros';
    }
  }

  /// Emoji exibido junto do chip. `null` em "Outros" (que mostra `+`).
  String? get emoji {
    switch (this) {
      case TemaPergunta.sono: return '🌙';
      case TemaPergunta.amamentacao: return '🤱';
      case TemaPergunta.saude: return '🩺';
      case TemaPergunta.alimentacao: return '🥣';
      case TemaPergunta.educacao: return '📚';
      case TemaPergunta.comportamento: return '🙂';
      case TemaPergunta.itens: return '📦';
      case TemaPergunta.rotina: return '⏰';
      case TemaPergunta.outros: return null;
    }
  }

  /// Valor estável enviado ao backend.
  String get valor {
    switch (this) {
      case TemaPergunta.sono: return 'sono';
      case TemaPergunta.amamentacao: return 'amamentacao';
      case TemaPergunta.saude: return 'saude';
      case TemaPergunta.alimentacao: return 'alimentacao';
      case TemaPergunta.educacao: return 'educacao';
      case TemaPergunta.comportamento: return 'comportamento';
      case TemaPergunta.itens: return 'itens';
      case TemaPergunta.rotina: return 'rotina';
      case TemaPergunta.outros: return 'outros';
    }
  }
}

/// Payload de uma pergunta enviada à comunidade. O fluxo é mais leve: não
/// exige fotos nem estado do produto.
class NovaPergunta {
  final TemaPergunta tema;
  final String pergunta;
  final String? detalhes;
  final String faixaEtaria;
  final List<String> fotos;

  const NovaPergunta({
    required this.tema,
    required this.pergunta,
    required this.faixaEtaria,
    this.detalhes,
    this.fotos = const [],
  });

  Map<String, dynamic> toJson() => {
        'tipo': 'pergunta',
        'tema': tema.valor,
        'pergunta': pergunta,
        if (detalhes != null) 'detalhes': detalhes,
        'faixaEtaria': faixaEtaria,
        'fotos': fotos,
      };
}

/// Payload de uma "Dica de mãe" (indicação) compartilhada na comunidade.
/// Reutiliza os mesmos temas de [TemaPergunta] mas com tipo `dica` no
/// backend e CTA própria.
class NovaDica {
  final TemaPergunta tema;
  final String dica;
  final String? detalhes;
  final String faixaEtaria;
  final List<String> fotos;

  const NovaDica({
    required this.tema,
    required this.dica,
    required this.faixaEtaria,
    this.detalhes,
    this.fotos = const [],
  });

  Map<String, dynamic> toJson() => {
        'tipo': 'dica',
        'tema': tema.valor,
        'dica': dica,
        if (detalhes != null) 'detalhes': detalhes,
        'faixaEtaria': faixaEtaria,
        'fotos': fotos,
      };
}
