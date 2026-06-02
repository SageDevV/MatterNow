import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Modal "Data de nascimento" — replica a sobreposição do Figma com 3 colunas
/// (Dia / Mês / Ano).
class DataNascimentoPicker {
  DataNascimentoPicker._();

  static Future<DateTime?> mostrar(BuildContext context, {DateTime? selecionado}) {
    return showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => _Dialogo(selecionadoInicial: selecionado),
    );
  }
}

class _Dialogo extends StatefulWidget {
  const _Dialogo({this.selecionadoInicial});
  final DateTime? selecionadoInicial;

  @override
  State<_Dialogo> createState() => _DialogoState();
}

class _DialogoState extends State<_Dialogo> {
  late int _dia;
  late int _mes;
  late int _ano;

  static const int _anoMin = 2000;
  late final int _anoMax;

  late final FixedExtentScrollController _ctrlDia;
  late final FixedExtentScrollController _ctrlMes;
  late final FixedExtentScrollController _ctrlAno;

  @override
  void initState() {
    super.initState();
    final base = widget.selecionadoInicial ?? DateTime(2020, 4, 24);
    _anoMax = DateTime.now().year;
    _dia = base.day.clamp(1, 31);
    _mes = base.month.clamp(1, 12);
    _ano = base.year.clamp(_anoMin, _anoMax);

    _ctrlDia = FixedExtentScrollController(initialItem: _dia - 1);
    _ctrlMes = FixedExtentScrollController(initialItem: _mes - 1);
    _ctrlAno = FixedExtentScrollController(initialItem: _ano - _anoMin);
  }

  @override
  void dispose() {
    _ctrlDia.dispose();
    _ctrlMes.dispose();
    _ctrlAno.dispose();
    super.dispose();
  }

  int _diasNoMes(int mes, int ano) =>
      DateTime(ano, mes + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final maxDia = _diasNoMes(_mes, _ano);
    final diaAjustado = _dia > maxDia ? maxDia : _dia;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                const Text(
                  'Data de nascimento',
                  style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Cabecalho('Dia'),
                _Cabecalho('Mês'),
                _Cabecalho('Ano'),
              ],
            ),
            const SizedBox(height: 4),
            // ignore: prefer_const_constructors
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: _ctrlDia,
                          itemExtent: 32,
                          onSelectedItemChanged: (i) => setState(() => _dia = i + 1),
                          children: [
                            for (var d = 1; d <= maxDia; d++)
                              Center(child: Text('$d', style: _estilo(d == diaAjustado))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: _ctrlMes,
                          itemExtent: 32,
                          onSelectedItemChanged: (i) => setState(() => _mes = i + 1),
                          children: [
                            for (var m = 1; m <= 12; m++)
                              Center(child: Text('$m', style: _estilo(m == _mes))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: _ctrlAno,
                          itemExtent: 32,
                          onSelectedItemChanged: (i) => setState(() => _ano = _anoMin + i),
                          children: [
                            for (var y = _anoMin; y <= _anoMax; y++)
                              Center(child: Text('$y', style: _estilo(y == _ano))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: IgnorePointer(
                      child: Container(
                        height: 32,
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
              onPressed: () => Navigator.of(context).pop(DateTime(_ano, _mes, diaAjustado)),
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

  TextStyle _estilo(bool selecionado) => TextStyle(
        color: selecionado ? AppColors.primary : AppColors.text,
        fontSize: 14,
        fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
      );
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(texto,
            style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
