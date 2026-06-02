import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import 'widgets/account_picker_modal.dart';
import 'widgets/matternow_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authRepository});
  final AuthRepository authRepository;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _senhaFocus = FocusNode();
  bool _carregando = false;
  bool _ocultarSenha = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _oferecerUltimaConta());
  }

  Future<void> _oferecerUltimaConta() async {
    final ultima = await widget.authRepository.ultimaConta();
    if (!mounted || ultima == null) return;

    final escolhido = await AccountPickerModal.mostrar(
      context,
      nome: ultima['nome'] ?? '',
      email: ultima['email'] ?? '',
    );
    if (!mounted || escolhido == null) return;
    setState(() => _emailCtrl.text = escolhido);
    _senhaFocus.requestFocus();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await widget.authRepository.login(
        email: _emailCtrl.text.trim(),
        senha: _senhaCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } on AuthFailure catch (e) {
      setState(() => _erro = e.mensagem);
    } catch (_) {
      setState(() => _erro = 'Não foi possível conectar ao servidor.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Center(child: MatterNowLogo()),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Nome ou e-mail'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe seu e-mail' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _senhaCtrl,
                    focusNode: _senhaFocus,
                    obscureText: _ocultarSenha,
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Informe sua senha' : null,
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 8),
                    Text(_erro!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
                      child: const Text(
                        'Esqueci minha senha',
                        style: TextStyle(color: AppColors.primaryDark, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    child: _carregando
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 32),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.text)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('ou acesso com', style: TextStyle(fontSize: 11)),
                      ),
                      Expanded(child: Divider(color: AppColors.text)),
                    ],
                  ),                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                    label: const Text('Fazer login com o Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: const BorderSide(color: AppColors.border, width: 0.3),
                      foregroundColor: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Não tem cadastro? ', style: TextStyle(fontSize: 12)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/register'),
                        child: const Text(
                          'Clique Aqui!',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
