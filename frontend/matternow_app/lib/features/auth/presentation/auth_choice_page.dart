import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/auth_models.dart';
import 'widgets/matternow_logo.dart';

/// Tela inicial de boas-vindas — replica o frame "2 - cadastro" do Figma
/// (variante de seleção entre entrar e criar conta).
class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  /// Mock do fluxo de cadastro via Google. A conta real será obtida via
  /// `google_sign_in` quando o app expor o OAuth client; por ora preenchemos
  /// dados fictícios e seguimos para os Termos.
  void _continuarComGoogle(BuildContext context) {
    const dados = CadastroPendente(
      origem: CadastroOrigem.google,
      nome: 'Courtney Heny',
      email: 'courtneyh21@gmail.com',
    );
    Navigator.of(context).pushNamed('/terms', arguments: dados);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Center(child: MatterNowLogo()),
              const SizedBox(height: 32),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bem-vinda',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text('💛', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Pronta pra comprar, vender e doar itens infantis com praticidade?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed('/register'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: const BorderSide(color: AppColors.primary, width: 0.5),
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontSize: 14),
                ),
                child: const Text('Criar conta'),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _continuarComGoogle(context),
                icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                label: const Text('Continuar com Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: const BorderSide(color: AppColors.border, width: 0.3),
                  foregroundColor: AppColors.text,
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Acesso sem cadastro — placeholder para fluxo futuro de "guest".
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Modo visitante em breve.')),
                  );
                },
                child: const Text(
                  'Explorar sem cadastro',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _Termos(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Termos extends StatelessWidget {
  const _Termos();

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      color: AppColors.text,
      fontSize: 11,
      height: 1.56,
    );
    final linkStyle = baseStyle.copyWith(decoration: TextDecoration.underline);

    return Opacity(
      opacity: 0.7,
      child: Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: 'Ao continuar, você concorda com os '),
            TextSpan(text: 'Termos de Uso', style: linkStyle),
            const TextSpan(text: '  e a '),
            TextSpan(text: 'Política de Privacidade', style: linkStyle),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
