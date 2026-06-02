import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import 'widgets/matternow_logo.dart';
import 'widgets/registration_success_modal.dart';

/// Tela de confirmação da conta cadastrada — replica o frame "9 - cadastro"
/// do Figma. Mostra a identidade que será criada e, ao confirmar, efetiva o
/// cadastro no backend.
class AccountConfirmationPage extends StatefulWidget {
  const AccountConfirmationPage({super.key, required this.authRepository});
  final AuthRepository authRepository;

  @override
  State<AccountConfirmationPage> createState() => _AccountConfirmationPageState();
}

class _AccountConfirmationPageState extends State<AccountConfirmationPage> {
  bool _enviando = false;
  String? _erro;

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first.characters.first.toUpperCase();
    return (partes.first.characters.first + partes.last.characters.first).toUpperCase();
  }

  Future<void> _confirmar(CadastroPendente dados) async {
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      // Cadastro via Google ainda não tem endpoint dedicado — geramos uma senha
      // temporária aleatória só para preencher o backend atual. Quando o login
      // social estiver implementado de fato, isto será substituído por um
      // endpoint específico de OAuth.
      final senha = dados.senha ?? _senhaTemporaria();

      await widget.authRepository.registrar(
        nome: dados.nome,
        email: dados.email,
        telefone: dados.telefone,
        senha: senha,
      );
      if (!mounted) return;
      await RegistrationSuccessModal.mostrar(context);
    } on AuthFailure catch (e) {
      setState(() => _erro = e.mensagem);
    } catch (_) {
      setState(() => _erro = 'Não foi possível conectar ao servidor.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  // Apenas para o mock atual de "Continuar com Google".
  String _senhaTemporaria() {
    final base = DateTime.now().microsecondsSinceEpoch.toString();
    return 'G!1${base.substring(base.length - 6)}Aa';
  }

  @override
  Widget build(BuildContext context) {
    final dados = ModalRoute.of(context)?.settings.arguments as CadastroPendente?;
    if (dados == null) {
      return const Scaffold(
        body: Center(child: Text('Dados do cadastro não foram informados.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Center(child: MatterNowLogo()),
            const Spacer(),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                children: [
                  const Text(
                    'Entrar com o e-mail',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 0.8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            _iniciais(dados.nome),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dados.nome,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dados.email,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 12),
                    Text(_erro!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _enviando ? null : () => _confirmar(dados),
                    child: _enviando
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Confirmar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
