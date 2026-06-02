import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tela de pré-visualização da foto escolhida — replica o frame "Foto do
/// perfil" do Figma. Por enquanto trabalha apenas com avatar emoji enquanto
/// o backend de upload de foto não é integrado.
class FotoPreviewPage extends StatelessWidget {
  const FotoPreviewPage({super.key, this.avatarEmoji, this.imagemBytes});

  final String? avatarEmoji;
  final List<int>? imagemBytes;

  static const _alturaCabecalho = 80.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Cabecalho(altura: _alturaCabecalho, onVoltar: () => Navigator.of(context).pop()),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(21, 24, 21, 16),
                child: Column(
                  children: [
                    const Text(
                      'Gostou da foto?',
                      style: TextStyle(color: AppColors.text, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        avatarEmoji ?? '🙂',
                        style: const TextStyle(fontSize: 110),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _AcaoFoto(icone: Icons.refresh, texto: 'Tirar outra'),
                        _AcaoFoto(icone: Icons.crop, texto: 'Recortar'),
                        _AcaoFoto(icone: Icons.delete_outline, texto: 'Excluir'),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Confirmar'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.primaryDark, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcaoFoto extends StatelessWidget {
  const _AcaoFoto({required this.icone, required this.texto});
  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(texto, style: const TextStyle(color: AppColors.text, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.altura, required this.onVoltar});
  final double altura;
  final VoidCallback onVoltar;

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: altura + paddingTop,
      padding: EdgeInsets.only(top: paddingTop),
      color: AppColors.primary,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text('Foto do perfil',
              style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: -0.42)),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onVoltar,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: 'Voltar',
            ),
          ),
        ],
      ),
    );
  }
}
