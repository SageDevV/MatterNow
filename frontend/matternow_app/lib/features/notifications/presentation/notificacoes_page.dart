import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_models.dart';
import '../../home/presentation/widgets/bottom_nav.dart';
import '../../home/presentation/widgets/home_header.dart';
import '../data/notificacao_models.dart';
import '../data/notificacoes_repository.dart';

/// Tela "Notificações" — replica os dois frames do Figma (estado vazio e lista).
class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key, required this.repository});
  final NotificacoesRepository repository;

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  static const _alturaCabecalho = 60.0;
  late Future<List<Notificacao>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _carregar();
  }

  Future<List<Notificacao>> _carregar() async {
    final lista = await widget.repository.listar();
    // Marca como lidas em segundo plano: a tela já foi aberta.
    _disparaMarcarLidas();
    return lista;
  }

  void _disparaMarcarLidas() {
    widget.repository.marcarTodasComoLidas().catchError((_) {});
  }

  void _trocarAba(int i) {
    // A tela de notificações é um destino próprio; ao tocar nas abas,
    // volta para a home e deixa a shell decidir o que mostrar.
    if (i == 4) {
      Navigator.of(context).pushNamed('/profile');
      return;
    }
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _abrirAnunciar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fluxo de anunciar em breve.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          HomeHeader(
            altura: _alturaCabecalho,
            titulo: 'Notificações',
            onVoltar: () => Navigator.of(context).maybePop(),
            notificacoes: 1,
            onConfig: () {},
            onNotificacoes: () {},
          ),
          Expanded(
            child: FutureBuilder<List<Notificacao>>(
              future: _futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final mensagem = snapshot.error is AuthFailure
                      ? (snapshot.error as AuthFailure).mensagem
                      : 'Não foi possível carregar.';
                  return _ErroBox(
                    mensagem: mensagem,
                    onTentar: () => setState(() => _futuro = _carregar()),
                  );
                }
                final lista = snapshot.data ?? [];
                if (lista.isEmpty) return const _Vazio();
                return _Lista(notificacoes: lista);
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

class _Lista extends StatelessWidget {
  const _Lista({required this.notificacoes});
  final List<Notificacao> notificacoes;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12, left: 4),
          child: Text(
            'Notificações',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final n in notificacoes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CardNotificacao(notificacao: n),
          ),
      ],
    );
  }
}

class _CardNotificacao extends StatelessWidget {
  const _CardNotificacao({required this.notificacao});
  final Notificacao notificacao;

  static const _corTitulo = Color(0xFF1F2937);
  static const _corSubtitulo = Color(0xFF718096);
  static const _corTempo = Color(0xFF9CA3AF);
  static const _corDot = Color(0xFF36C2B1);
  static const _corBorda = Color(0xFFE2E8E2);

  ({IconData icone, Color cor, Color fundo}) get _visual {
    switch (notificacao.tipo) {
      case TipoNotificacao.favorito:
        return (
          icone: Icons.favorite_border_rounded,
          cor: const Color(0xFFEF4444),
          fundo: const Color(0xFFFEE2E2),
        );
      case TipoNotificacao.curtida:
        return (
          icone: Icons.local_offer_outlined,
          cor: const Color(0xFF10B981),
          fundo: const Color(0xFFD1FAE5),
        );
      case TipoNotificacao.avaliacao:
        return (
          icone: Icons.star_rounded,
          cor: const Color(0xFFF59E0B),
          fundo: const Color(0xFFFEF3C7),
        );
      case TipoNotificacao.mensagem:
        return (
          icone: Icons.chat_bubble_outline_rounded,
          cor: AppColors.primary,
          fundo: const Color(0xFFE0F2F1),
        );
      case TipoNotificacao.info:
        return (
          icone: Icons.info_outline_rounded,
          cor: Colors.white,
          fundo: const Color(0xFF6B7280),
        );
    }
  }

  String _tempoRelativo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return h == 1 ? 'há 1 hora' : 'há $h horas';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return d == 1 ? 'há 1 dia' : 'há $d dias';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    final ehInfo = notificacao.tipo == TipoNotificacao.info;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _corBorda, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000), // rgba(0,0,0,0.05)
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: v.fundo,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(v.icone, color: v.cor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notificacao.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _corTitulo,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _tempoRelativo(notificacao.criadoEm),
                        style: const TextStyle(color: _corTempo, fontSize: 11),
                      ),
                    ),
                    if (!notificacao.lida) ...[
                      const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _corDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                if (notificacao.subtitulo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    notificacao.subtitulo!,
                    maxLines: ehInfo ? 4 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _corSubtitulo,
                      fontSize: 14,
                      height: 1.43, // 20/14
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12, left: 4),
            child: Text(
              'Notificações',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 80),
          Center(
            child: Icon(
              Icons.notifications_off_outlined,
              size: 96,
              color: AppColors.primary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'Tudo limpo por aqui!',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 32 / 24,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Você não tem nenhuma notificação no momento. Vamos explorar a comunidade?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF757575),
                fontSize: 16,
                height: 24 / 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 292,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0x1A000000),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                  ),
                ),
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false),
                child: const Text('Explorar Comunidade'),
              ),
            ),
          ),
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
