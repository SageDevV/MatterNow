import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_models.dart';
import '../../home/presentation/widgets/bottom_nav.dart';
import '../../home/presentation/widgets/home_header.dart';
import '../data/meus_recebidos_repository.dart';
import '../data/recebido_models.dart';
import 'avaliacao_concluida_page.dart';
import 'widgets/avaliar_recebido_sheet.dart';
import 'widgets/recebido_card.dart';

/// Tela "Meus recebidos" — replica os frames do Figma com:
/// - Cabeçalho descritivo do fluxo
/// - Seção "pendentes" com badge de contagem e CTA "Recebi esse item"
/// - Seção "Histórico" com data de recebimento
/// - Estado vazio ilustrado convidando a explorar a comunidade
class MeusRecebidosPage extends StatefulWidget {
  const MeusRecebidosPage({super.key, required this.repository});

  final MeusRecebidosRepository repository;

  @override
  State<MeusRecebidosPage> createState() => _MeusRecebidosPageState();
}

class _MeusRecebidosPageState extends State<MeusRecebidosPage> {
  static const _alturaCabecalho = 60.0;
  Future<MeusRecebidosResponse>? _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = widget.repository.obter();
  }

  void _recarregar() {
    setState(() => _futuro = widget.repository.obter());
  }

  Future<void> _abrirAvaliacao(Recebido recebido) async {
    // Confirma o recebimento (idempotente do lado do backend) e em seguida
    // abre o bottom sheet de avaliação. Se a confirmação falhar, mostra o
    // erro mas mantém a UI no estado atual.
    try {
      await widget.repository.confirmarRecebimento(recebido.id);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensagem)),
      );
      return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível confirmar agora.')),
      );
      return;
    }

    if (!mounted) return;
    final avaliacao = await AvaliarRecebidoSheet.mostrar(
      context,
      recebido: recebido,
    );
    if (!mounted || avaliacao == null) return;

    try {
      await widget.repository.avaliar(recebido.id, avaliacao);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensagem)),
      );
      return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível enviar a avaliação.')),
      );
      return;
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AvaliacaoConcluidaPage(recebido: recebido),
      ),
    );
    if (!mounted) return;
    _recarregar();
  }

  void _trocarAba(int i) {
    if (i == 4) {
      Navigator.of(context).popUntil((r) => r.isFirst);
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
            titulo: 'Meus recebidos',
            onVoltar: () => Navigator.of(context).maybePop(),
            notificacoes: 1,
            onConfig: () {},
            onNotificacoes: () =>
                Navigator.of(context).pushNamed('/notificacoes'),
          ),
          Expanded(
            child: FutureBuilder<MeusRecebidosResponse>(
              future: _futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final mensagem = snapshot.error is AuthFailure
                      ? (snapshot.error as AuthFailure).mensagem
                      : 'Não foi possível carregar seus recebidos.';
                  return _ErroBox(mensagem: mensagem, onTentar: _recarregar);
                }
                final dados = snapshot.data ?? MeusRecebidosResponse.vazio_;
                if (dados.vazio) return const _EstadoVazio();
                return _Conteudo(
                  dados: dados,
                  onAvaliar: _abrirAvaliacao,
                );
              },
            ),
          ),
          HomeBottomNav(
            indice: 4,
            onChanged: _trocarAba,
            onAnunciar: () {},
          ),
        ],
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.dados, required this.onAvaliar});

  final MeusRecebidosResponse dados;
  final ValueChanged<Recebido> onAvaliar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _CabecalhoExplicativo(),
        const SizedBox(height: 16),
        if (dados.pendentes.isNotEmpty) ...[
          _RotuloSecao(
            titulo: 'pendentes',
            badge: '${dados.pendentes.length} ite${dados.pendentes.length == 1 ? 'm' : 'ns'}',
            destaque: true,
          ),
          const SizedBox(height: 8),
          for (final r in dados.pendentes) ...[
            RecebidoCard(
              recebido: r,
              onConfirmar: () => onAvaliar(r),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
        ],
        if (dados.historico.isNotEmpty) ...[
          const _RotuloSecao(titulo: 'HISTÓRICO'),
          const SizedBox(height: 8),
          for (final r in dados.historico) ...[
            RecebidoCard(recebido: r),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _CabecalhoExplicativo extends StatelessWidget {
  const _CabecalhoExplicativo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meus recebidos',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Aqui você vê os itens que recebeu de doação ou comprou. Confirme o recebimento e avalie para ajudar outras mães.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _RotuloSecao extends StatelessWidget {
  const _RotuloSecao({
    required this.titulo,
    this.badge,
    this.destaque = false,
  });

  final String titulo;
  final String? badge;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: destaque ? AppColors.primary : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: destaque ? 0 : 1.1,
          ),
        ),
        const Spacer(),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: destaque
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                color: destaque ? AppColors.primary : const Color(0xFF6B7280),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 168,
            height: 168,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6F5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              '🎁',
              style: TextStyle(fontSize: 84),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ainda não há recebidos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Você ainda não adquiriu nenhum item. Que tal explorar o que as outras mães estão vendendo e doando na comunidade?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 280,
            height: 48,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/community'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999)),
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              child: const Text('Explorar comunidade'),
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
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 13),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
                onPressed: onTentar,
                child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
