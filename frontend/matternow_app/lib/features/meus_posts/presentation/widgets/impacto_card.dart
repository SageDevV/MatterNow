import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/meu_post_models.dart';

/// Card "Você está fazendo a diferença!" — replica o frame de impacto da
/// comunidade do Figma: três métricas (itens reaproveitados, faturamento
/// e mães ajudadas) e um link "Ver mais" que abre os insights detalhados.
class ImpactoCard extends StatelessWidget {
  const ImpactoCard({
    super.key,
    required this.impacto,
    this.onVerMais,
  });

  final ImpactoComunidade impacto;
  final VoidCallback? onVerMais;

  String _formatarMoeda(double valor) {
    final inteiro = valor.toInt();
    final s = inteiro.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'R\$ ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Você está fazendo a diferença! 💛',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onVerMais != null)
                InkWell(
                  onTap: onVerMais,
                  child: const Text(
                    'Ver mais',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ItemMetrica(
                  icone: Icons.recycling_outlined,
                  cor: const Color(0xFF10B981),
                  fundo: const Color(0xFFD1FAE5),
                  valor: impacto.itensReaproveitados.toString(),
                  rotulo: 'Itens reaproveitados',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ItemMetrica(
                  icone: Icons.attach_money,
                  cor: const Color(0xFFF59E0B),
                  fundo: const Color(0xFFFEF3C7),
                  valor: _formatarMoeda(impacto.faturamento),
                  rotulo: 'Faturamento',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ItemMetrica(
                  icone: Icons.favorite_border,
                  cor: const Color(0xFFEF4444),
                  fundo: const Color(0xFFFEE2E2),
                  valor: impacto.maesAjudadas.toString(),
                  rotulo: 'Mães ajudadas',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemMetrica extends StatelessWidget {
  const _ItemMetrica({
    required this.icone,
    required this.cor,
    required this.fundo,
    required this.valor,
    required this.rotulo,
  });

  final IconData icone;
  final Color cor;
  final Color fundo;
  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icone, size: 14, color: cor),
        ),
        const SizedBox(height: 8),
        Text(
          valor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          rotulo,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
