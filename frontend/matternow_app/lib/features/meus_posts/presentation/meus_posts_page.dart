import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_models.dart';
import '../../home/presentation/widgets/bottom_nav.dart';
import '../../home/presentation/widgets/home_header.dart';
import '../data/meu_post_models.dart';
import '../data/meus_posts_repository.dart';
import 'meu_impacto_page.dart';
import 'widgets/acoes_post_sheet.dart';
import 'widgets/impacto_card.dart';
import 'widgets/meu_post_card.dart';

/// Tela "Meus posts" — replica os frames do Figma com:
/// - Cabeçalho verde
/// - Abas Ativos / Resolvidos
/// - Card de impacto da comunidade
/// - Lista de cards de cada publicação com ações
class MeusPostsPage extends StatefulWidget {
  const MeusPostsPage({super.key, required this.repository});
  final MeusPostsRepository repository;

  @override
  State<MeusPostsPage> createState() => _MeusPostsPageState();
}

class _MeusPostsPageState extends State<MeusPostsPage> {
  static const _alturaCabecalho = 60.0;

  Future<MeusPostsResponse>? _futuro;
  bool _verResolvidos = false;

  @override
  void initState() {
    super.initState();
    _futuro = widget.repository.obter();
  }

  void _recarregar() {
    setState(() => _futuro = widget.repository.obter());
  }

  Future<void> _abrirAcoes(MeuPost post) async {
    final acao = await AcoesPostSheet.mostrar(context);
    if (!mounted || acao == null) return;
    switch (acao) {
      case AcaoPost.editar:
        await _editar(post);
        break;
      case AcaoPost.resolver:
        await _resolver(post);
        break;
      case AcaoPost.excluir:
        await _excluir(post);
        break;
    }
  }

  Future<void> _editar(MeuPost post) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edição em breve.')),
    );
  }

  Future<void> _resolver(MeuPost post) async {
    try {
      await widget.repository.marcarComoResolvido(post.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicação resolvida! 🎉')),
      );
      _recarregar();
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível resolver agora.')),
      );
    }
  }

  Future<void> _excluir(MeuPost post) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir publicação?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirma != true) return;
    try {
      await widget.repository.excluir(post.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicação excluída.')),
      );
      _recarregar();
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir agora.')),
      );
    }
  }

  void _abrirImpacto(ImpactoComunidade impacto) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MeuImpactoPage(impacto: impacto),
    ));
  }

  void _trocarAba(int i) {
    if (i == 4) {
      Navigator.of(context).pushNamed('/profile');
      return;
    }
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          HomeHeader(
            altura: _alturaCabecalho,
            titulo: 'Meus posts',
            onVoltar: () => Navigator.of(context).maybePop(),
            notificacoes: 1,
            onConfig: () {},
            onNotificacoes: () => Navigator.of(context).pushNamed('/notificacoes'),
          ),
          Expanded(
            child: FutureBuilder<MeusPostsResponse>(
              future: _futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final mensagem = snapshot.error is AuthFailure
                      ? (snapshot.error as AuthFailure).mensagem
                      : 'Não foi possível carregar seus posts.';
                  return _ErroBox(mensagem: mensagem, onTentar: _recarregar);
                }
                final dados = snapshot.data ?? const MeusPostsResponse(
                  impacto: ImpactoComunidade.vazio,
                  ativos: [],
                  resolvidos: [],
                );
                return _Conteudo(
                  dados: dados,
                  verResolvidos: _verResolvidos,
                  onTrocarAba: (v) => setState(() => _verResolvidos = v),
                  onAcoes: _abrirAcoes,
                  onMarcarResolvido: _resolver,
                  onAbrirImpacto: () => _abrirImpacto(dados.impacto),
                );
              },
            ),
          ),
          HomeBottomNav(
            indice: 4,
            onChanged: _trocarAba,
            onAnunciar: () => Navigator.of(context).pushNamed('/anunciar/vender'),
          ),
        ],
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({
    required this.dados,
    required this.verResolvidos,
    required this.onTrocarAba,
    required this.onAcoes,
    required this.onMarcarResolvido,
    required this.onAbrirImpacto,
  });

  final MeusPostsResponse dados;
  final bool verResolvidos;
  final ValueChanged<bool> onTrocarAba;
  final void Function(MeuPost) onAcoes;
  final void Function(MeuPost) onMarcarResolvido;
  final VoidCallback onAbrirImpacto;

  @override
  Widget build(BuildContext context) {
    final lista = verResolvidos ? dados.resolvidos : dados.ativos;
    return Column(
      children: [
        _Tabs(
          atual: verResolvidos ? 1 : 0,
          ativosCount: dados.ativos.length,
          resolvidosCount: dados.resolvidos.length,
          onSelecionar: (i) => onTrocarAba(i == 1),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(13, 14, 13, 24),
            children: [
              ImpactoCard(impacto: dados.impacto, onVerMais: onAbrirImpacto),
              const SizedBox(height: 16),
              if (lista.isEmpty)
                _Vazio(verResolvidos: verResolvidos)
              else
                for (final post in lista)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MeuPostCard(
                      post: post,
                      onAcoes: post.resolvido ? null : () => onAcoes(post),
                      onMarcarResolvido:
                          post.resolvido ? null : () => onMarcarResolvido(post),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.atual,
    required this.ativosCount,
    required this.resolvidosCount,
    required this.onSelecionar,
  });

  final int atual;
  final int ativosCount;
  final int resolvidosCount;
  final ValueChanged<int> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabBotao(
              rotulo: 'Ativos ($ativosCount)',
              ativo: atual == 0,
              onTap: () => onSelecionar(0),
            ),
          ),
          Expanded(
            child: _TabBotao(
              rotulo: 'Resolvidos ($resolvidosCount)',
              ativo: atual == 1,
              onTap: () => onSelecionar(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBotao extends StatelessWidget {
  const _TabBotao({required this.rotulo, required this.ativo, required this.onTap});
  final String rotulo;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ativo ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          rotulo,
          style: TextStyle(
            color: ativo ? AppColors.primary : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio({required this.verResolvidos});
  final bool verResolvidos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Icon(
            verResolvidos ? Icons.check_circle_outline : Icons.notes_outlined,
            size: 48,
            color: AppColors.text.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            verResolvidos
                ? 'Você ainda não tem posts resolvidos.'
                : 'Você ainda não tem posts ativos.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            verResolvidos
                ? 'Quando você resolver uma publicação, ela aparece aqui.'
                : 'Anuncie um item ou compartilhe uma dúvida para começar.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, height: 1.4),
          ),
          if (!verResolvidos) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              ),
              onPressed: () => Navigator.of(context).pushNamed('/anunciar/vender'),
              child: const Text('Anunciar item'),
            ),
          ],
        ],
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
            Text(mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.text, fontSize: 13)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onTentar, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
