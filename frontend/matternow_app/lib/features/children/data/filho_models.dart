enum GeneroFilho {
  naoInformar(0),
  menina(1),
  menino(2);

  final int valor;
  const GeneroFilho(this.valor);

  static GeneroFilho fromValor(int? v) {
    if (v == GeneroFilho.menina.valor) return GeneroFilho.menina;
    if (v == GeneroFilho.menino.valor) return GeneroFilho.menino;
    return GeneroFilho.naoInformar;
  }
}

class Filho {
  final String id;
  final String nome;
  final String? avatar;
  final DateTime? dataNascimento;
  final String? faixaEtaria;
  final String? tamanhoRoupa;
  final GeneroFilho genero;
  final double? pesoKg;

  const Filho({
    required this.id,
    required this.nome,
    this.avatar,
    this.dataNascimento,
    this.faixaEtaria,
    this.tamanhoRoupa,
    this.genero = GeneroFilho.naoInformar,
    this.pesoKg,
  });

  factory Filho.fromJson(Map<String, dynamic> json) => Filho(
        id: json['id'] as String,
        nome: json['nome'] as String? ?? '',
        avatar: json['avatar'] as String?,
        dataNascimento: json['dataNascimento'] == null
            ? null
            : DateTime.parse(json['dataNascimento'] as String),
        faixaEtaria: json['faixaEtaria'] as String?,
        tamanhoRoupa: json['tamanhoRoupa'] as String?,
        genero: GeneroFilho.fromValor(json['genero'] as int?),
        pesoKg: (json['pesoKg'] as num?)?.toDouble(),
      );
}

/// Catálogos fixos.
class FaixaEtariaCatalogo {
  FaixaEtariaCatalogo._();
  static const opcoes = ['1 - 2 anos', '2 - 3 anos', '4 - 5 anos', '6 - 8 anos', '9 - 12 anos'];
}

class TamanhoRoupaCatalogo {
  TamanhoRoupaCatalogo._();
  static const opcoes = ['RN', '0-3 meses', '3-6 meses', 'Outro'];
}
