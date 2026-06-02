import '../../home/data/home_models.dart';
import '../../home/data/home_repository.dart';

/// Repositório da comunidade. Por enquanto reaproveita o endpoint `/feed/home`
/// (que já devolve os anúncios da comunidade); pode ser substituído por
/// `/api/comunidade` quando o backend expuser um endpoint dedicado.
class CommunityRepository {
  CommunityRepository({HomeRepository? homeRepository})
      : _homeRepository = homeRepository ?? HomeRepository();

  final HomeRepository _homeRepository;

  Future<List<AnuncioFeed>> listar() async {
    final dados = await _homeRepository.obter();
    // O backend retorna `comunidade` (feed) e `recomendacoes` (produtos sugeridos).
    // Para a tela de Comunidade unificamos os dois em uma lista só.
    return [...dados.comunidade, ...dados.recomendacoes];
  }
}
