import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/filho_models.dart';

/// Modal de seleção de faixa etária — replica o frame com sobreposição
/// "Faixa etária" do Figma.
class FaixaEtariaPicker {
  FaixaEtariaPicker._();

  static Future<String?> mostrar(BuildContext context, {String? selecionado}) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => _Dialogo(selecionadoInicial: selecionado),
    );
  }
}

class _Dialogo extends StatefulWidget {
  const _Dialogo({this.selecionadoInicial});
  final String? selecionadoInicial;

  @override
  State<_Dialogo> createState() => _DialogoState();
}

class _DialogoState extends State<_Dialogo> {
  late final FixedExtentScrollController _ctrl;
  late int _indice;

  @override
  void initState() {
    super.initState();
    _indice = FaixaEtariaCatalogo.opcoes.indexOf(widget.selecionadoInicial ?? '');
    if (_indice < 0) _indice = 2;
    _ctrl = FixedExtentScrollController(initialItem: _indice);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                const Text(
                  'Faixa etária',
                  style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  CupertinoPicker(
                    scrollController: _ctrl,
                    itemExtent: 36,
                    onSelectedItemChanged: (i) => setState(() => _indice = i),
                    children: [
                      for (final opcao in FaixaEtariaCatalogo.opcoes)
                        Center(child: Text(opcao, style: const TextStyle(color: AppColors.text, fontSize: 14))),
                    ],
                  ),
                  Center(
                    child: IgnorePointer(
                      child: Container(
                        height: 36,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.primary, width: 1),
                            bottom: BorderSide(color: AppColors.primary, width: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(FaixaEtariaCatalogo.opcoes[_indice]),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: const BorderSide(color: AppColors.primary, width: 0.5),
                foregroundColor: AppColors.primary,
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
