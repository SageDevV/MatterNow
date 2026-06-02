import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/anuncio_models.dart';

/// Modal "Faixa etária" — replica o frame com a roleta wheel-style do Figma.
class FaixaEtariaModal {
  FaixaEtariaModal._();

  static Future<String?> mostrar(BuildContext context, {String? selecionada}) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => _Conteudo(selecionada: selecionada),
    );
  }
}

class _Conteudo extends StatefulWidget {
  const _Conteudo({this.selecionada});
  final String? selecionada;

  @override
  State<_Conteudo> createState() => _ConteudoState();
}

class _ConteudoState extends State<_Conteudo> {
  static const _alturaItem = 36.0;
  late final FixedExtentScrollController _ctrl;
  late int _indice;

  @override
  void initState() {
    super.initState();
    _indice = FaixaEtariaAnuncio.opcoes.indexOf(widget.selecionada ?? '');
    if (_indice < 0) _indice = 2; // default: "4 - 5 anos"
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho: "Faixa etária" + close
            SizedBox(
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Faixa etária',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.close, size: 16, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Wheel
            SizedBox(
              height: _alturaItem * 5,
              child: Stack(
                children: [
                  ListWheelScrollView.useDelegate(
                    controller: _ctrl,
                    itemExtent: _alturaItem,
                    physics: const FixedExtentScrollPhysics(),
                    perspective: 0.003,
                    diameterRatio: 1.6,
                    onSelectedItemChanged: (i) => setState(() => _indice = i),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: FaixaEtariaAnuncio.opcoes.length,
                      builder: (_, i) {
                        final selecionado = i == _indice;
                        return Center(
                          child: Text(
                            FaixaEtariaAnuncio.opcoes[i],
                            style: TextStyle(
                              color: selecionado ? AppColors.primary : AppColors.text,
                              fontSize: selecionado ? 18 : 15,
                              fontWeight: selecionado ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Linhas que destacam o item central
                  IgnorePointer(
                    child: Center(
                      child: Container(
                        height: _alturaItem,
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
            const SizedBox(height: 20),
            // Botão "Salvar"
            InkWell(
              onTap: () => Navigator.of(context).pop(FaixaEtariaAnuncio.opcoes[_indice]),
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
