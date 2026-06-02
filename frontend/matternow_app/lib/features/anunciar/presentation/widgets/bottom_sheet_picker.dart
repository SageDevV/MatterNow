import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bottom-sheet de seleção único — replica o "Selecione uma categoria" do Figma:
/// fundo escuro com lista vertical e radio à direita.
///
/// Genérico em [T]; o cliente passa as opções com label e o valor associado.
class BottomSheetPicker<T> {
  BottomSheetPicker._();

  static Future<T?> mostrar<T>({
    required BuildContext context,
    required String tituloPlaceholder,
    required List<({T valor, String rotulo})> opcoes,
    T? selecionado,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => _Conteudo<T>(
        tituloPlaceholder: tituloPlaceholder,
        opcoes: opcoes,
        selecionado: selecionado,
      ),
    );
  }
}

class _Conteudo<T> extends StatelessWidget {
  const _Conteudo({
    required this.tituloPlaceholder,
    required this.opcoes,
    required this.selecionado,
  });

  final String tituloPlaceholder;
  final List<({T valor, String rotulo})> opcoes;
  final T? selecionado;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2024),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SafeArea(
        top: false,
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: opcoes.length + 1,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFF2A2C32),
            indent: 20,
            endIndent: 20,
          ),
          itemBuilder: (_, i) {
            if (i == 0) {
              return _Item(
                rotulo: tituloPlaceholder,
                selecionado: selecionado == null,
                onTap: () => Navigator.of(context).pop(),
              );
            }
            final op = opcoes[i - 1];
            return _Item(
              rotulo: op.rotulo,
              selecionado: op.valor == selecionado,
              onTap: () => Navigator.of(context).pop(op.valor),
            );
          },
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.rotulo, required this.selecionado, required this.onTap});
  final String rotulo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                rotulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            _Radio(selecionado: selecionado),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selecionado});
  final bool selecionado;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selecionado ? AppColors.primary : const Color(0xFF6B7280),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selecionado
          ? Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
