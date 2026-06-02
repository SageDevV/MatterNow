import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

/// Tela de cadastro completa — replica o frame "6 - cadastro" do Figma.
/// Coleta os dados e encaminha para `/terms` onde o usuário aceita as
/// políticas e a conta é efetivamente criada no backend.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.authRepository});
  final AuthRepository authRepository;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const _alturaCabecalho = 80.0;

  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();

  bool _ocultarSenha = true;
  bool _ocultarConfirma = true;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');

  @override
  void initState() {
    super.initState();
    _senhaCtrl.addListener(() => setState(() {})); // refresca os checks de força
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
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
  String? _validarNome(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe um nome ou apelido';
    if (v.trim().length < 2) return 'Nome muito curto';
    return null;
  }

  String? _validarEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe seu e-mail';
    if (!_emailRegex.hasMatch(v.trim())) return 'E-mail inválido';
    return null;
  }

  String? _validarSenha(String? v) {
    if (v == null || v.isEmpty) return 'Informe uma senha';
    if (!_senhaForte) return 'A senha não atende aos requisitos';
    return null;
  }

  String? _validarConfirma(String? v) {
    if (v != _senhaCtrl.text) return 'As senhas não coincidem';
    return null;
  }

  // --- Ação ------------------------------------------------------------------
  void _continuar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final dados = CadastroPendente(
      origem: CadastroOrigem.manual,
      nome: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefone: _telefoneCtrl.text.trim(),
      senha: _senhaCtrl.text,
    );
    Navigator.of(context).pushNamed('/terms', arguments: dados);
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
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Queremos te conhecer melhor para\noferecer uma experiência mais afetiva',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.invite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const _Rotulo('Como você gostaria de ser chamada (o)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nomeCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(hintText: 'Nome ou apelido'),
                        validator: _validarNome,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'Seu e-mail'),
                        validator: _validarEmail,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _telefoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(hintText: 'Telefone'),
                      ),
                      const SizedBox(height: 24),
                      const _Rotulo('Para sua segurança crie uma senha'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _senhaCtrl,
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
                          hintText: 'Confirmar senha',
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
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _continuar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                        ),
                        child: const Text('Ler termos de uso e privacidade'),
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

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        texto,
        style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w600),
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
            'Cadastrar',
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
