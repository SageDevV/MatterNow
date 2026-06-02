import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

/// Tela de recuperação de senha — primeiro passo do fluxo.
/// Replica o frame "3 - cadastro" do Figma.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, required this.authRepository});
  final AuthRepository authRepository;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const _alturaCabecalho = 80.0;

  final _formKey = GlobalKey<FormState>();
  final _identificadorCtrl = TextEditingController();

  bool _enviando = false;
  bool _enviado = false;
  String? _erro;

  @override
  void dispose() {
    _identificadorCtrl.dispose();
    super.dispose();
  }

  String? _validar(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Informe seu e-mail ou telefone';
    }
    return null;
  }

  Future<void> _enviar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _enviando = true;
      _enviado = false;
      _erro = null;
    });

    final identificador = _identificadorCtrl.text.trim();
    try {
      await widget.authRepository.esqueceuSenha(email: identificador);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _erro = e.mensagem;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _erro = 'Não foi possível conectar ao servidor.';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _enviando = false;
      _enviado = true;
    });

    // Aguarda o usuário ver o feedback "Código enviado!" e segue para a próxima etapa,
    // levando o e-mail informado.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.of(context).pushNamed('/reset-password', arguments: identificador);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Cabecalho(altura: _alturaCabecalho, onVoltar: () => Navigator.of(context).pop()),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Esqueceu sua senha?',
                        style: TextStyle(
                          color: AppColors.invite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Enviaremos um código de verificação para\no seu e-mail ou telefone',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _identificadorCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'E-mail ou  telefone com DDD'),
                        validator: _validar,
                        onChanged: (_) {
                          if (_enviado) setState(() => _enviado = false);
                        },
                      ),
                      const SizedBox(height: 64),
                      OutlinedButton(
                        onPressed: _enviando ? null : _enviar,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: const BorderSide(color: AppColors.primary, width: 0.5),
                          foregroundColor: AppColors.primary,
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        child: _enviando
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              )
                            : const Text('Enviar'),
                      ),
                      const SizedBox(height: 32),
                      AnimatedOpacity(
                        opacity: _enviado ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Text(
                          'Código enviado!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (_erro != null) ...[
                        const SizedBox(height: 12),
                        Text(_erro!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error, fontSize: 12)),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
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
          const Text(
            'Recuperar senha',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: -0.42,
            ),
          ),
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
