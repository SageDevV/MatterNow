import '../../home/data/home_models.dart';

/// Categorias visíveis na barra de abas da Comunidade — replica o Figma.
enum CategoriaComunidade { todas, vendas, doacoes, perguntas, indicacoes }

extension CategoriaComunidadeX on CategoriaComunidade {
  String get rotulo {
    switch (this) {
      case CategoriaComunidade.todas: return 'Todas';
      case CategoriaComunidade.vendas: return 'Vendas';
      case CategoriaComunidade.doacoes: return 'Doações';
      case CategoriaComunidade.perguntas: return 'Perguntas';
      case CategoriaComunidade.indicacoes: return 'Indicações';
    }
  }

  /// Retorna `true` se o anúncio se encaixa na categoria selecionada.
  bool aceita(AnuncioFeed a) {
    switch (this) {
      case CategoriaComunidade.todas: return true;
      case CategoriaComunidade.vendas: return a.tipo == TipoAnuncio.venda;
      case CategoriaComunidade.doacoes: return a.tipo == TipoAnuncio.doacao;
      case CategoriaComunidade.perguntas: return a.tipo == TipoAnuncio.pergunta;
      case CategoriaComunidade.indicacoes: return a.tipo == TipoAnuncio.dica;
    }
  }
}
