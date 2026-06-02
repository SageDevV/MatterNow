import 'package:flutter/material.dart';

import '../../auth/data/auth_models.dart';
import '../../auth/data/auth_repository.dart';
import '../data/home_models.dart';
import '../data/home_repository.dart';
import 'home_feed_page.dart';
import 'home_first_access_page.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/home_header.dart';

/// Shell da home — orquestra header, navegação inferior e roteamento entre
/// "primeiro acesso" e "feed". Substitui a HomePage placeholder.
class HomeShellPage extends StatefulWidget {
  const HomeShellPage({
    super.key,
    required this.authRepository,
    required this.homeRepository,
  });
  final AuthRepository authRepository;
  final HomeRepository homeRepository;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  static const _alturaCabecalho = 60.0;

  int _aba = 0;
  Future<HomeData>? _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = widget.homeRepository.obter();
  }

  void _trocarAba(int i) {
    if (i == 4) {
      // "Meu perfil" leva para a tela de perfil já existente.
      Navigator.of(context).pushNamed('/profile');
      return;
    }
    setState(() => _aba = i);
  }

  void _abrirAnunciar() {
    Navigator.of(context).pushNamed('/anunciar/vender');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<HomeData>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Column(
              children: [
                HomeHeader(
                  altura: _alturaCabecalho,
                  saudacao: '...',
                ),
                Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            );
          }

          if (snapshot.hasError) {
            final err = snapshot.error;
            if (err is AuthFailure && err.sessaoExpirada) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await widget.authRepository.sair();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/auth-choice', (_) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sua sessão expirou. Entre novamente.')),
                );
              });
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final mensagem = err is AuthFailure ? err.mensagem : 'Não foi possível carregar a home.';
            return Column(
              children: [
                const HomeHeader(altura: _alturaCabecalho, titulo: 'Início'),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 12),
                          Text(mensagem, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => setState(() => _futuro = widget.homeRepository.obter()),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final dados = snapshot.data!;
          return Column(
            children: [
              HomeHeader(
                altura: _alturaCabecalho,
                saudacao: dados.primeiroAcesso ? 'Olá, ${dados.saudacaoNome} 👋' : null,
                titulo: dados.primeiroAcesso ? null : 'Início',
                notificacoes: dados.primeiroAcesso ? 0 : 1,
                onConfig: () {},
                onNotificacoes: () => Navigator.of(context).pushNamed('/notificacoes'),
              ),
              Expanded(
                child: _conteudoPorAba(dados),
              ),
              HomeBottomNav(indice: _aba, onChanged: _trocarAba, onAnunciar: _abrirAnunciar),
            ],
          );
        },
      ),
    );
  }

  Widget _conteudoPorAba(HomeData dados) {
    switch (_aba) {
      case 0:
        return dados.primeiroAcesso
            ? HomeFirstAccessPage(dados: dados)
            : HomeFeedPage(dados: dados);
      case 1:
        return const _Placeholder(label: 'Buscar');
      case 3:
        return const _Placeholder(label: 'Chat');
      default:
        return const SizedBox();
    }
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$label em breve', style: const TextStyle(color: Color(0xFF777777), fontSize: 14)),
    );
  }
}
