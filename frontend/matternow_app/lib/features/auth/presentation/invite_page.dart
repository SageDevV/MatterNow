import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tela de convite — primeira tela exibida quando o usuário ainda não tem conta.
/// Replica o frame "1 - cadastro" do Figma.
class InvitePage extends StatelessWidget {
  const InvitePage({
    super.key,
    this.nomeConvidador = 'Leila',
  });

  /// Nome de quem convidou. Virá do deep link no futuro.
  final String nomeConvidador;

  static const _alturaCabecalho = 80.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _Cabecalho(altura: _alturaCabecalho),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Você foi convidada (o)\npara a Maternow',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.invite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.14,
                        letterSpacing: -0.48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/welcome_invite.png',
                        height: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 12,
                          height: 1.56,
                          letterSpacing: -0.36,
                        ),
                        children: [
                          TextSpan(
                            text: '$nomeConvidador ',
                            style: const TextStyle(color: AppColors.inviter),
                          ),
                          const TextSpan(
                            text:
                                'te convidou para fazer parte da Maternow, uma comunidade de mães confiáveis que desapegam de itens infantis e se ajudam no dia a dia',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/auth-choice'),
                      child: const Text('Visitar'),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/login'),
                        child: const Text(
                          'Já tenho conta',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.altura});

  final double altura;

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: altura + paddingTop,
      padding: EdgeInsets.only(top: paddingTop),
      color: AppColors.primary.withValues(alpha: 0.9),
      alignment: Alignment.center,
      child: const Text(
        'Cadastro inicial',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          letterSpacing: -0.42,
          height: 1.56,
        ),
      ),
    );
  }
}
