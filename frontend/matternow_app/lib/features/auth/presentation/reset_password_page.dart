import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import 'widgets/sucesso_redefinicao_modal.dart';

/// Segunda etapa do fluxo de recuperação de senha — replica o frame
/// "4 - cadastro" do Figma. Recebe o código enviado e cria a nova senha.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.authRepository});
  final AuthRepository authRepository;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  static const _alturaCabecalho = 80.0;

  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();

  bool _ocultarSenha = true;
  bool _ocultarConfirma = true;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _senhaCtrl.addListener(() => setState(() {})); // refresca os checks de força
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  // --- Regras de força da senha ----------------------------------------------

  bool get _temMin8 => _senhaCtrl.text.length >= 8;
  bool get _temMaiuscula => _senhaCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _temNumero => _senhaCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _temEspecial => _senhaCtrl.text.contains(RegExp(r'[!@#%\$&*\(\)\-_=+\[\]{};:,.<>?/\\|`~"]'));

  bool get _senhaForte => _temMin8 && _temMaiuscula && _temNumero && _temEspecial;

  // --- Validações ------------------------------------------------------------

  String? _validarCodigo(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe o código';
    return null;
  }

  String? _validarSenha(String? v) {
    if (v == null || v.isEmpty) return 'Informe a nova senha';
    if (!_senhaForte) return 'A senha não atende aos requisitos';
    return null;
  }

  String? _validarConfirma(String? v) {
    if (v != _senhaCtrl.text) return 'As senhas não coincidem';
    return null;
  }

  // --- Ação ------------------------------------------------------------------

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = ModalRoute.of(context)?.settings.arguments as String?;
    if (email == null || email.isEmpty) {
      setState(() => _erro = 'E-mail não informado. Refaça a etapa anterior.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      await widget.authRepository.redefinirSenha(
        email: email,
        codigo: _codigoCtrl.text.trim(),
        novaSenha: _senhaCtrl.text,
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = e.mensagem;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = 'Não foi possível conectar ao servidor.';
      });
      return;
    }

    if (!mounted) return;
    setState(() => _salvando = false);
    await SucessoRedefinicaoModal.mostrar(context);
  }

  // --- Build -----------------------------------------------------------------

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
                        'Código de verificação',
                        style: TextStyle(
                          color: AppColors.invite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Digite o número que foi enviado a você',
                        style: TextStyle(color: AppColors.text, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _codigoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Código'),
                        validator: _validarCodigo,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _senhaCtrl,
                        obscureText: _ocultarSenha,
                        decoration: InputDecoration(
                          hintText: 'Crie uma nova senha',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                          ),
                        ),
                        validator: _validarSenha,
                      ),
                      const SizedBox(height: 12),
                      _RegrasSenha(
                        min8: _temMin8,
                        maiuscula: _temMaiuscula,
                        numero: _temNumero,
                        especial: _temEspecial,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmaCtrl,
                        obscureText: _ocultarConfirma,
                        decoration: InputDecoration(
                          hintText: 'Confirmar nova senha',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarConfirma ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _ocultarConfirma = !_ocultarConfirma),
                          ),
                        ),
                        validator: _validarConfirma,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _salvando ? null : _salvar,
                        child: _salvando
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Salvar alterações'),
                      ),
                      const SizedBox(height: 24),
                      AnimatedOpacity(
                        opacity: _erro != null ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _erro ?? 'Ops...essa senha não deu certo.\nVamos tentar outra vez?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error, fontSize: 12, height: 1.4),
                        ),
                      ),
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

class _RegrasSenha extends StatelessWidget {
  const _RegrasSenha({
    required this.min8,
    required this.maiuscula,
    required this.numero,
    required this.especial,
  });

  final bool min8;
  final bool maiuscula;
  final bool numero;
  final bool especial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sua nova senha deve incluir:',
            style: TextStyle(color: AppColors.text, fontSize: 11, height: 1.6),
          ),
          _Regra(texto: 'Pelo menos 8 caracteres', ok: min8),
          _Regra(texto: '1 letra maiúscula', ok: maiuscula),
          _Regra(texto: '1 número', ok: numero),
          _Regra(texto: '1 caractere especial (ex. !@#%)', ok: especial),
        ],
      ),
    );
  }
}

class _Regra extends StatelessWidget {
  const _Regra({required this.texto, required this.ok});
  final String texto;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final cor = ok ? AppColors.primary : AppColors.text;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(Icons.check, size: 12, color: cor),
          const SizedBox(width: 6),
          Text(texto, style: TextStyle(color: cor, fontSize: 11, height: 1.4)),
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
            style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: -0.42),
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
