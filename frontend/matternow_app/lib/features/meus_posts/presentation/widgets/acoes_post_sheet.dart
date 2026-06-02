import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Ações disponíveis na bottom sheet "..." de um post.
enum AcaoPost { editar, resolver, excluir }

/// Bottom sheet de ações sobre um post (Editar / Marcar como resolvido /
/// Excluir) — replica o frame do Figma.
class AcoesPostSheet {
  AcoesPostSheet._();

  static Future<AcaoPost?> mostrar(BuildContext context) {
    return showModalBottomSheet<AcaoPost>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const _Conteudo(),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 48,
              height: 6,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            _Item(
              icone: Icons.edit_outlined,
              rotulo: 'Editar publicação',
              onTap: () => Navigator.of(context).pop(AcaoPost.editar),
            ),
            _Divisor(),
            _Item(
              icone: Icons.check_circle_outline,
              rotulo: 'Marcar como resolvido',
              onTap: () => Navigator.of(context).pop(AcaoPost.resolver),
            ),
            _Divisor(),
            _Item(
              icone: Icons.delete_outline,
              rotulo: 'Excluir publicação',
              corTexto: AppColors.error,
              corIcone: AppColors.error,
              onTap: () => Navigator.of(context).pop(AcaoPost.excluir),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icone,
    required this.rotulo,
    required this.onTap,
    this.corTexto,
    this.corIcone,
  });

  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;
  final Color? corTexto;
  final Color? corIcone;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Row(
          children: [
            Icon(icone, size: 20, color: corIcone ?? const Color(0xFF374151)),
            const SizedBox(width: 16),
            Text(
              rotulo,
              style: TextStyle(
                color: corTexto ?? const Color(0xFF1F2937),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divisor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF3F4F6),
      indent: 28,
      endIndent: 28,
    );
  }
}
