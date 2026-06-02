import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Origem de uma nova foto: câmera ou galeria.
enum FotoOrigem { camera, galeria }

/// Diálogo "Adicionar foto" — replica o modal centralizado do Figma
/// com as duas opções (Tirar foto / Escolher da galeria) e Cancelar.
class FotoOrigemModal {
  FotoOrigemModal._();

  static Future<FotoOrigem?> mostrar(BuildContext context) {
    return showDialog<FotoOrigem>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const _Conteudo(),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'Adicionar foto',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Opcao(
              icone: Icons.photo_camera_outlined,
              texto: 'Tirar foto',
              onTap: () => Navigator.of(context).pop(FotoOrigem.camera),
            ),
            const SizedBox(height: 12),
            _Opcao(
              icone: Icons.photo_library_outlined,
              texto: 'Escolher da galeria',
              onTap: () => Navigator.of(context).pop(FotoOrigem.galeria),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Opcao extends StatelessWidget {
  const _Opcao({required this.icone, required this.texto, required this.onTap});
  final IconData icone;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icone, size: 22, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                texto,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
