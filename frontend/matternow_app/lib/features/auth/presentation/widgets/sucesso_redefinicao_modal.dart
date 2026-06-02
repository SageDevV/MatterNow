import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Modal de sucesso após a senha ser alterada — replica a sobreposição do
/// frame "5 - cadastro" do Figma. Exibe um check, mensagem e botão para
/// retornar à página inicial.
class SucessoRedefinicaoModal {
  SucessoRedefinicaoModal._();

  static Future<void> mostrar(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const _Conteudo(),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo();

  static const _verde = Color(0xFF2EAE7A);
  static const _verdeFundo = Color(0xFFB8E0C8);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => route.isFirst);
                  },
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.textMuted,
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: _verdeFundo,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check, color: _verde, size: 56),
              ),
              const SizedBox(height: 16),
              const Text(
                'Senha alterada com sucesso',
                textAlign: TextAlign.center,
                style: TextStyle(color: _verde, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // fecha modal
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => route.isFirst);
                },
                child: const Text('Página inicial'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
