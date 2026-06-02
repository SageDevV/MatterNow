import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/bottom_nav.dart';
import '../../home/presentation/widgets/home_header.dart';
import '../data/recebido_models.dart';

/// Tela de sucesso exibida após concluir uma avaliação.
/// Mostra ilustração, mensagem de agradecimento e resumo do item avaliado.
class AvaliacaoConcluidaPage extends StatelessWidget {
  const AvaliacaoConcluidaPage({super.key, required this.recebido});

  final Recebido recebido;

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final dataFormatada =
        '${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}/${hoje.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          HomeHeader(
            altura: 60,
            titulo: 'Meus recebidos',
            onVoltar: () => Navigator.of(context).pop(),
            notificacoes: 1,
            onConfig: () {},
            onNotificacoes: () =>
                Navigator.of(context).pushNamed('/notificacoes'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  Container(
                    width: 168,
                    height: 168,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7E8),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '🎉',
                      style: TextStyle(fontSize: 96),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Obrigada pela sua avaliação!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sua opinião fortalece a comunidade e ajuda outras mães a confiarem nas trocas. 💛',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ResumoItem(recebido: recebido, data: dataFormatada),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side:
                            const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999)),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Voltar para meus recebidos'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          HomeBottomNav(
            indice: 4,
            onChanged: (i) {
              if (i == 4) return;
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            onAnunciar: () {},
          ),
        ],
      ),
    );
  }
}

class _ResumoItem extends StatelessWidget {
  const _ResumoItem({required this.recebido, required this.data});
  final Recebido recebido;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF1F0),
              borderRadius: BorderRadius.circular(12),
              image: recebido.fotoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(recebido.fotoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: recebido.fotoUrl == null
                ? const Icon(Icons.image_outlined,
                    color: Color(0xFF9CA3AF))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recebido.titulo,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recebido.parceiroRotulo,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Avaliado em: $data',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
