import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/anunciar/data/anuncio_repository.dart';
import 'features/anunciar/presentation/doar_item_page.dart';
import 'features/anunciar/presentation/indicar_page.dart';
import 'features/anunciar/presentation/perguntar_page.dart';
import 'features/anunciar/presentation/vender_item_page.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/account_confirmation_page.dart';
import 'features/auth/presentation/auth_choice_page.dart';
import 'features/auth/presentation/forgot_password_page.dart';
import 'features/auth/presentation/invite_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/auth/presentation/reset_password_page.dart';
import 'features/auth/presentation/terms_page.dart';
import 'features/children/data/filhos_repository.dart';
import 'features/children/presentation/children_list_page.dart';
import 'features/community/data/community_repository.dart';
import 'features/community/presentation/community_page.dart';
import 'features/home/data/home_repository.dart';
import 'features/home/presentation/home_shell_page.dart';
import 'features/meus_posts/data/meus_posts_repository.dart';
import 'features/meus_posts/presentation/meus_posts_page.dart';
import 'features/meus_recebidos/data/meus_recebidos_repository.dart';
import 'features/meus_recebidos/presentation/meus_recebidos_page.dart';
import 'features/notifications/data/notificacoes_repository.dart';
import 'features/notifications/presentation/notificacoes_page.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/presentation/profile_edit_page.dart';
import 'features/profile/presentation/profile_page.dart';

void main() {
  runApp(const MatterNowApp());
}

class MatterNowApp extends StatelessWidget {
  const MatterNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final profileRepository = ProfileRepository();
    final filhosRepository = FilhosRepository();
    final homeRepository = HomeRepository();
    final notificacoesRepository = NotificacoesRepository();
    final communityRepository = CommunityRepository(homeRepository: homeRepository);
    final anuncioRepository = AnuncioRepository();
    final meusPostsRepository = MeusPostsRepository();
    final meusRecebidosRepository = MeusRecebidosRepository();

    return MaterialApp(
      title: 'MatterNow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: _RootGate(authRepository: authRepository, homeRepository: homeRepository),
      routes: {
        '/invite': (_) => const InvitePage(),
        '/auth-choice': (_) => const AuthChoicePage(),
        '/login': (_) => LoginPage(authRepository: authRepository),
        '/terms': (_) => TermsPage(authRepository: authRepository),
        '/register': (_) => RegisterPage(authRepository: authRepository),
        '/account-confirmation': (_) => AccountConfirmationPage(authRepository: authRepository),
        '/forgot-password': (_) => ForgotPasswordPage(authRepository: authRepository),
        '/reset-password': (_) => ResetPasswordPage(authRepository: authRepository),
        '/profile': (_) => ProfilePage(
              profileRepository: profileRepository,
              filhosRepository: filhosRepository,
              authRepository: authRepository,
            ),
        '/profile/edit': (_) => ProfileEditPage(repository: profileRepository),
        '/children': (_) => ChildrenListPage(repository: filhosRepository),
        '/notificacoes': (_) => NotificacoesPage(repository: notificacoesRepository),
        '/community': (_) => CommunityPage(repository: communityRepository),
        '/anunciar/vender': (_) => VenderItemPage(repository: anuncioRepository),
        '/anunciar/doar': (_) => DoarItemPage(repository: anuncioRepository),
        '/anunciar/perguntar': (_) => PerguntarPage(repository: anuncioRepository),
        '/anunciar/indicar': (_) => IndicarPage(repository: anuncioRepository),
        '/meus-posts': (_) => MeusPostsPage(repository: meusPostsRepository),
        '/meus-recebidos': (_) => MeusRecebidosPage(repository: meusRecebidosRepository),
        '/home': (_) => HomeShellPage(authRepository: authRepository, homeRepository: homeRepository),
      },
    );
  }
}

class _RootGate extends StatefulWidget {
  const _RootGate({required this.authRepository, required this.homeRepository});
  final AuthRepository authRepository;
  final HomeRepository homeRepository;

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  late Future<bool> _autenticadoFuture;

  @override
  void initState() {
    super.initState();
    _autenticadoFuture = widget.authRepository.isAutenticado();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _autenticadoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == true) {
          return HomeShellPage(authRepository: widget.authRepository, homeRepository: widget.homeRepository);
        }
        return const AuthChoicePage();
      },
    );
  }
}
