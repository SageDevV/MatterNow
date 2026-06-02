import 'package:flutter/material.dart';

import '../../home/presentation/widgets/home_header.dart';
import '../data/meu_post_models.dart';

/// Tela "Meus impacto" — replica o frame de insights do Figma com
/// gráfico em donut (proporção entre tipos de ajuda) e legenda lateral.
/// Por simplicidade, o donut é desenhado com `CustomPaint` em proporções
/// fixas; quando vier dado real do backend basta passar o `Map` via
/// construtor.
class MeuImpactoPage extends StatelessWidget {
  const MeuImpactoPage({
    super.key,
    required this.impacto,
    this.distribuicao = const {
      'Itens reaproveitados': (cor: Color(0xFF10B981), porcentagem: 50.0),
      'Mães ajudadas': (cor: Color(0xFFEF4444), porcentagem: 10.0),
      'Resolvidos': (cor: Color(0xFFF59E0B), porcentagem: 10.0),
      'Anunciados': (cor: Color(0xFF7C3AED), porcentagem: 30.0),
    },
  });

  final ImpactoComunidade impacto;
  final Map<String, ({Color cor, double porcentagem})> distribuicao;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          HomeHeader(
            altura: 60,
            titulo: 'Meu impacto',
            onVoltar: () => Navigator.of(context).maybePop(),
            notificacoes: 1,
            onConfig: () {},
            onNotificacoes: () => Navigator.of(context).pushNamed('/notificacoes'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  const Text(
                    'Você está fazendo a diferença!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Suas ações ajudam outras mães a economizar e a viverem uma maternidade mais leve.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Donut(distribuicao: distribuicao),
                  const SizedBox(height: 24),
                  _Legenda(distribuicao: distribuicao),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Donut extends StatelessWidget {
  const _Donut({required this.distribuicao});
  final Map<String, ({Color cor, double porcentagem})> distribuicao;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _DonutPainter(distribuicao: distribuicao),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.distribuicao});
  final Map<String, ({Color cor, double porcentagem})> distribuicao;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = size.width / 2 - 8;
    const espessura = 28.0;

    var startRad = -1.5708; // -90°
    final total = distribuicao.values
        .map((e) => e.porcentagem)
        .fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    for (final entry in distribuicao.values) {
      final sweep = (entry.porcentagem / total) * 6.28319; // 360°
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = espessura
        ..strokeCap = StrokeCap.butt
        ..color = entry.cor;
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: raio),
        startRad,
        sweep,
        false,
        paint,
      );
      startRad += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.distribuicao != distribuicao;
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.distribuicao});
  final Map<String, ({Color cor, double porcentagem})> distribuicao;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final e in distribuicao.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: e.value.cor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.key,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${e.value.porcentagem.toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.circle, size: 14, color: e.value.cor.withValues(alpha: 0.4)),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Text(
          '${impactoLine(distribuicao)} de impacto na comunidade',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
      ],
    );
  }

  String impactoLine(Map<String, ({Color cor, double porcentagem})> d) {
    final total = d.values.fold<double>(0, (a, b) => a + b.porcentagem);
    return '${total.toInt()}%';
  }
}

/// Constante exportada com o impacto da comunidade exibido na tela.
extension ImpactoFmt on ImpactoComunidade {
  String resumo() => '$itensReaproveitados itens · $maesAjudadas mães';
}
