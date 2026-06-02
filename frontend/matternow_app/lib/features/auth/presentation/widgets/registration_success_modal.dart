import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Modal de sucesso pós-cadastro — replica o frame "8 - cadastro" do Figma.
/// Apresenta a ilustração de boas-vindas e leva à página inicial do app.
class RegistrationSuccessModal {
  RegistrationSuccessModal._();

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
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
                  },
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.textMuted,
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Image.asset(
                'assets/images/registration_success.png',
                height: 170,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bem Vinda!',
                style: TextStyle(
                  color: AppColors.invite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Seu perfil está prontinho',
                style: TextStyle(color: AppColors.text, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // fecha modal
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
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
