import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_models.dart';
import '../../home/data/home_models.dart';
import '../../home/presentation/widgets/bottom_nav.dart';
import '../../home/presentation/widgets/home_header.dart';
import '../data/community_models.dart';
import '../data/community_repository.dart';
import 'widgets/anuncio_card.dart';
import 'widgets/community_empty_states.dart';

/// Tela "Comunidade" — replica os frames do Figma com:
/// - Cabeçalho verde + barra de busca
/// - Abas (Todas, Vendas, Doações, Perguntas, Indicações)
/// - Lista de anúncios filtrada pela aba ativa
/// - Estados vazios ilustrados por aba
class CommunityPage extends StatefulWidget {
  const CommunityPage({
    super.key,
    required this.repository,
    this.categoriaInicial = CategoriaComunidade.todas,
  });

  final CommunityRepository repository;
  final CategoriaComunidade categoriaInicial;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  static const _alturaCabecalho = 60.0;

  late CategoriaComunidade _categoria;
  final _buscaCtrl = TextEditingController();
  Future<List<AnuncioFeed>>? _futuro;

  @override
  void initState() {
    super.initState();
    _categoria = widget.categoriaInicial;
    _futuro = widget.repository.listar();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  void _trocarAba(int i) {
    if (i == 4) {
      Navigator.of(context).pushNamed('/profile');
      return;
    }
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _abrirAnunciar() {
    Navigator.of(context).pushNamed('/anunciar/vender');
  }

  void _abrirAnunciarPorCategoria() {
    final rota = switch (_categoria) {
      CategoriaComunidade.doacoes => '/anunciar/doar',
      CategoriaComunidade.perguntas => '/anunciar/perguntar',
      CategoriaComunidade.indicacoes => '/anunciar/indicar',
      _ => '/anunciar/vender',
    };
    Navigator.of(context).pushNamed(rota);
  }

  List<AnuncioFeed> _filtrar(List<AnuncioFeed> lista) {
    final termo = _buscaCtrl.text.trim().toLowerCase();
    return lista.where(_categoria.aceita).where((a) {
      if (termo.isEmpty) return true;
      return a.titulo.toLowerCase().contains(termo) ||
          (a.descricao?.toLowerCase().contains(termo) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          HomeHeader(
            altura: _alturaCabecalho,
            titulo: 'Comunidade',
            onVoltar: () => Navigator.of(context).maybePop(),
            notificacoes: 1,
            onConfig: () {},
            onNotificacoes: () => Navigator.of(context).pushNamed('/notificacoes'),
          ),
          _BarraBusca(
            controller: _buscaCtrl,
            onChanged: (_) => setState(() {}),
          ),
          _BarraAbas(
            atual: _categoria,
            onSelecionar: (c) => setState(() => _categoria = c),
          ),
          Expanded(
            child: FutureBuilder<List<AnuncioFeed>>(
              future: _futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final mensagem = snapshot.error is AuthFailure
                      ? (snapshot.error as AuthFailure).mensagem
                      : 'Não foi possível carregar a comunidade.';
                  return _ErroBox(
                    mensagem: mensagem,
                    onTentar: () => setState(
                      () => _futuro = widget.repository.listar(),
                    ),
                  );
                }
                final filtrados = _filtrar(snapshot.data ?? const []);
                if (filtrados.isEmpty) {
                  return CommunityEmptyState(
                    categoria: _categoria,
                    onAnunciar: _abrirAnunciarPorCategoria,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(9, 12, 8, 24),
                  itemCount: filtrados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => AnuncioCard(anuncio: filtrados[i]),
                );
              },
            ),
          ),
          HomeBottomNav(
            indice: 0,
            onChanged: _trocarAba,
            onAnunciar: _abrirAnunciar,
          ),
        ],
      ),
    );
  }
}

class _BarraBusca extends StatelessWidget {
  const _BarraBusca({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F0),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Buscar na comunidade',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarraAbas extends StatelessWidget {
  const _BarraAbas({required this.atual, required this.onSelecionar});
  final CategoriaComunidade atual;
  final ValueChanged<CategoriaComunidade> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7F6),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final c in CategoriaComunidade.values) _Aba(
              categoria: c,
              ativa: c == atual,
              onTap: () => onSelecionar(c),
            ),
          ],
        ),
      ),
    );
  }
}

class _Aba extends StatelessWidget {
  const _Aba({required this.categoria, required this.ativa, required this.onTap});
  final CategoriaComunidade categoria;
  final bool ativa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ativa ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            categoria.rotulo,
            style: TextStyle(
              color: ativa ? AppColors.primary : const Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: ativa ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErroBox extends StatelessWidget {
  const _ErroBox({required this.mensagem, required this.onTentar});
  final String mensagem;
  final VoidCallback onTentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text, fontSize: 13),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onTentar, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
