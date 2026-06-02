import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import 'widgets/registration_success_modal.dart';

/// Tela de Termos de Uso e Política de Privacidade — replica o frame
/// "10 - cadastro" do Figma. Recebe os dados do cadastro pendente e, ao
/// confirmar, encaminha para a etapa de confirmação da conta.
class TermsPage extends StatefulWidget {
  const TermsPage({super.key, required this.authRepository});
  final AuthRepository authRepository;

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  static const _alturaCabecalho = 80.0;
  bool _aceito = false;
  bool _enviando = false;
  String? _erro;

  Future<void> _confirmar(CadastroPendente dados) async {
    // Cadastro via Google passa por uma etapa adicional de confirmação da
    // identidade (frame "9 - cadastro"). Cadastro manual vai direto ao
    // backend e exibe a tela de sucesso (frame "8 - cadastro").
    if (dados.viaGoogle) {
      Navigator.of(context).pushNamed('/account-confirmation', arguments: dados);
      return;
    }

    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await widget.authRepository.registrar(
        nome: dados.nome,
        email: dados.email,
        telefone: dados.telefone,
        senha: dados.senha!,
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

  @override
  Widget build(BuildContext context) {
    final dados = ModalRoute.of(context)?.settings.arguments as CadastroPendente?;

    return Scaffold(
      body: Column(
        children: [
          _Cabecalho(altura: _alturaCabecalho, onVoltar: () => Navigator.of(context).pop()),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(child: _CardTermos()),
                    const SizedBox(height: 16),
                    _AceiteCheckbox(
                      valor: _aceito,
                      onChanged: (v) => setState(() => _aceito = v ?? false),
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: 8),
                      Text(_erro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error, fontSize: 12)),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: !_aceito || _enviando || dados == null
                          ? null
                          : () => _confirmar(dados),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTermos extends StatelessWidget {
  const _CardTermos();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
      child: const Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(right: 8),
          child: _TextoTermos(),
        ),
      ),
    );
  }
}

class _TextoTermos extends StatelessWidget {
  const _TextoTermos();

  static const _titulo = TextStyle(
    color: AppColors.text,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  static const _corpo = TextStyle(
    color: AppColors.text,
    fontSize: 11,
    height: 1.6,
  );

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Termos de Uso e Política de Privacidade da Maternow',
          style: _titulo,
        ),
        SizedBox(height: 16),
        Center(child: Text('Termos de Uso - Maternow', style: _titulo)),
        Text('Última atualização em 07/11/2025.', style: _corpo),
        SizedBox(height: 12),
        Text('Bem-vinda à Maternow!', style: _corpo),
        Text(
          'Esses Termos de Uso descrevem as regras que orientam o uso do nosso aplicativo, que conecta mães e famílias interessadas em comprar, vender ou trocar itens infantis usados e em bom estado de conservação e usabilidade, de forma prática, segura e colaborativa.',
          style: _corpo,
        ),
        SizedBox(height: 12),
        Text(
          'Ao criar uma conta e utilizar a Maternow, você concorda integralmente com estes Termos. Caso não concorde, pedimos que não prossiga com o cadastro nem utilize nossos serviços.',
          style: _corpo,
        ),
        SizedBox(height: 16),
        _Secao(
          numero: '1.',
          titulo: 'Sobre a Maternow',
          texto:
              'A Maternow é uma plataforma digital que facilita a interação entre usuários (vendedores e compradores) para o comércio, troca ou doação de produtos infantis usados ou novos.',
        ),
        _Secao(
          numero: '2.',
          titulo: 'Cadastro e conta',
          texto:
              'Para utilizar os serviços é necessário criar uma conta com informações verdadeiras. Você é responsável por manter a confidencialidade da sua senha e por todas as atividades realizadas em sua conta.',
        ),
        _Secao(
          numero: '3.',
          titulo: 'Anúncios e transações',
          texto:
              'Os anúncios são de responsabilidade dos próprios usuários. A Maternow atua como intermediadora e não se responsabiliza por defeitos dos produtos, descumprimentos de combinados ou problemas externos à plataforma.',
        ),
        _Secao(
          numero: '4.',
          titulo: 'Dados pessoais e LGPD',
          texto:
              'Seus dados são tratados conforme a Lei Geral de Proteção de Dados (Lei 13.709/2018). Coletamos apenas o necessário para criação e manutenção da conta e para viabilizar as transações entre usuários.',
        ),
        _Secao(
          numero: '5.',
          titulo: 'Conduta esperada',
          texto:
              'É proibido publicar conteúdo ofensivo, ilegal ou que viole direitos de terceiros. A Maternow pode suspender ou encerrar contas que descumpram estas regras.',
        ),
        SizedBox(height: 12),
        Text(
          'Estes Termos podem ser atualizados periodicamente. Mudanças relevantes serão comunicadas dentro do aplicativo.',
          style: _corpo,
        ),
      ],
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.numero, required this.titulo, required this.texto});
  final String numero;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(numero, style: _TextoTermos._corpo.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titulo,
                  style: _TextoTermos._corpo.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2),
            child: Text(texto, style: _TextoTermos._corpo),
          ),
        ],
      ),
    );
  }
}

class _AceiteCheckbox extends StatelessWidget {
  const _AceiteCheckbox({required this.valor, required this.onChanged});
  final bool valor;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25,
          height: 25,
          child: Checkbox(
            value: valor,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!valor),
            child: const Text(
              'Li e concordo com os Termos de Uso e a Política de Privacidade da Maternow, autorizando o uso dos meus dados para criação e manutenção da minha conta, conforme a LGPD.',
              style: TextStyle(color: AppColors.text, fontSize: 11, height: 1.5),
            ),
          ),
        ),
      ],
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
            'Termos e políticas',
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
