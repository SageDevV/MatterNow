import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/recebido_models.dart';

/// Card de um item recebido — usado tanto na seção "pendentes" (com botão
/// "Recebi esse item") quanto na seção "Histórico" (com data de recebimento).
class RecebidoCard extends StatelessWidget {
  const RecebidoCard({
    super.key,
    required this.recebido,
    this.onConfirmar,
  });

  final Recebido recebido;
  final VoidCallback? onConfirmar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Foto(
                fotoUrl: recebido.fotoUrl,
                badge: _Badge(tipo: recebido.tipo),
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
                            recebido.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (recebido.parceiroAjudouMaes > 0)
                          _ChipAjudou(qtd: recebido.parceiroAjudouMaes),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recebido.parceiroRotulo,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                    if (recebido.recebidoEm != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Recebido em: ${_formatarData(recebido.recebidoEm!)}',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (onConfirmar != null) ...[
            const SizedBox(height: 12),
            _BotaoRecebi(onTap: onConfirmar!),
          ],
        ],
      ),
    );
  }

  static String _formatarData(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }
}

class _Foto extends StatelessWidget {
  const _Foto({required this.fotoUrl, required this.badge});
  final String? fotoUrl;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF1F0),
              borderRadius: BorderRadius.circular(12),
              image: fotoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(fotoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: fotoUrl == null
                ? const Icon(Icons.image_outlined,
                    color: Color(0xFF9CA3AF), size: 28)
                : null,
          ),
          Positioned(top: 6, left: 6, child: badge),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.tipo});
  final TipoRecebido tipo;

  @override
  Widget build(BuildContext context) {
    final isVenda = tipo == TipoRecebido.venda;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isVenda ? const Color(0xFFD9F0E2) : const Color(0xFFFCE9C5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tipo.rotulo,
        style: TextStyle(
          color:
              isVenda ? const Color(0xFF2EAE7A) : const Color(0xFFE39A23),
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ChipAjudou extends StatelessWidget {
  const _ChipAjudou({required this.qtd});
  final int qtd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, size: 10, color: Color(0xFFE94E77)),
          const SizedBox(width: 4),
          Text(
            'Ajudou $qtd mães',
            style: const TextStyle(
              color: Color(0xFFE94E77),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoRecebi extends StatelessWidget {
  const _BotaoRecebi({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.check_circle_outline, size: 16),
        label: const Text('Recebi esse item'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
