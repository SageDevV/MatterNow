import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Barra inferior do app — replica o frame "Navigation Button List" do Figma.
/// O botão central (+ Anunciar) aparece destacado em círculo verde flutuante.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.indice,
    required this.onChanged,
    this.onAnunciar,
  });

  final int indice;
  final ValueChanged<int> onChanged;
  final VoidCallback? onAnunciar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 86,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0x14000000))),
                ),
                child: Row(
                  children: [
                    Expanded(child: _Item(index: 0, atual: indice, icone: Icons.home_outlined, label: 'Início', onTap: onChanged)),
                    Expanded(child: _Item(index: 1, atual: indice, icone: Icons.search, label: 'Buscar', onTap: onChanged)),
                    const Expanded(child: SizedBox()),
                    Expanded(child: _Item(index: 3, atual: indice, icone: Icons.chat_bubble_outline, label: 'Chat', onTap: onChanged)),
                    Expanded(child: _Item(index: 4, atual: indice, icone: Icons.person_outline, label: 'Meu perfil', onTap: onChanged)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: onAnunciar,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.index, required this.atual, required this.icone, required this.label, required this.onTap});
  final int index;
  final int atual;
  final IconData icone;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final ativo = index == atual;
    final cor = ativo ? AppColors.primary : AppColors.textMuted;
    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: cor, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: cor, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
