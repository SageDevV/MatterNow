import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/data/auth_repository.dart';
import '../../children/data/filho_models.dart';
import '../../children/data/filhos_repository.dart';
import '../../home/presentation/widgets/bottom_nav.dart';
import '../../home/presentation/widgets/home_header.dart';
import '../data/profile_models.dart';
import '../data/profile_repository.dart';
import 'profile_edit_page.dart';
import 'widgets/avatar_catalog.dart';
import 'widgets/invite_modal.dart';

/// Tela "Perfil" — replica os frames de visão geral do perfil no Figma:
/// card do usuário, grade de estatísticas, "Meus filhos" e atalhos
/// (Meus posts, Favoritos, Meus recebidos).
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.profileRepository,
    required this.filhosRepository,
    required this.authRepository,
  });

  final ProfileRepository profileRepository;
  final FilhosRepository filhosRepository;
  final AuthRepository authRepository;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _alturaCabecalho = 60.0;
  Future<_DadosPerfil>? _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _carregar();
  }

  Future<_DadosPerfil> _carregar() async {
    // Carrega perfil e filhos em paralelo para reduzir tempo de espera.
    final results = await Future.wait([
      widget.profileRepository.obterMeuPerfil(),
      widget.filhosRepository.listar(),
    ]);
    return _DadosPerfil(perfil: results[0] as Perfil, filhos: results[1] as List<Filho>);
  }

  void _trocarAba(int i) {
    if (i == 4) return; // já estamos no perfil.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _editarPerfil() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileEditPage(repository: widget.profileRepository),
      ),
    );
    if (!mounted) return;
    setState(() => _futuro = _carregar());
  }

  Future<void> _abrirFilhos() async {
    await Navigator.of(context).pushNamed('/children');
    if (!mounted) return;
    setState(() => _futuro = _carregar());
  }

  Future<void> _sair() async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você será desconectada deste dispositivo.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Sair')),
        ],
      ),
    );
    if (confirma != true) return;
    await widget.authRepository.sair();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/auth-choice', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          HomeHeader(
            altura: _alturaCabecalho,
            titulo: 'Perfil',
            onVoltar: () => Navigator.of(context).maybePop(),
            notificacoes: 1,
            onConfig: () {},
            onNotificacoes: () => Navigator.of(context).pushNamed('/notificacoes'),
          ),
          Expanded(
            child: FutureBuilder<_DadosPerfil>(
              future: _futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final err = snapshot.error;
                  final mensagem =
                      err is AuthFailure ? err.mensagem : 'Não foi possível carregar seu perfil.';
                  return _ErroBox(
                    mensagem: mensagem,
                    onTentar: () => setState(() => _futuro = _carregar()),
                  );
                }
                final dados = snapshot.data!;
                return _Conteudo(
                  perfil: dados.perfil,
                  filhos: dados.filhos,
                  onEditarPerfil: _editarPerfil,
                  onConvidar: () => InviteModal.mostrar(context),
                  onAbrirFilhos: _abrirFilhos,
                  onSair: _sair,
                );
              },
            ),
          ),
          HomeBottomNav(
            indice: 4,
            onChanged: _trocarAba,
            onAnunciar: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fluxo de anunciar em breve.')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DadosPerfil {
  final Perfil perfil;
  final List<Filho> filhos;
  const _DadosPerfil({required this.perfil, required this.filhos});
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({
    required this.perfil,
    required this.filhos,
    required this.onEditarPerfil,
    required this.onConvidar,
    required this.onAbrirFilhos,
    required this.onSair,
  });

  final Perfil perfil;
  final List<Filho> filhos;
  final VoidCallback onEditarPerfil;
  final VoidCallback onConvidar;
  final VoidCallback onAbrirFilhos;
  final VoidCallback onSair;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(11, 16, 11, 24),
      children: [
        _CardUsuario(
          perfil: perfil,
          onEditar: onEditarPerfil,
          onConvidar: onConvidar,
        ),
        const SizedBox(height: 14),
        _GridEstatisticas(perfil: perfil),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Meus filhos',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _CardFilhos(filhos: filhos, onAbrir: onAbrirFilhos),
        const SizedBox(height: 14),
        _CardAtalhos(filhos: filhos, perfil: perfil),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: onSair,
            child: const Text(
              'Sair da conta',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardUsuario extends StatelessWidget {
  const _CardUsuario({required this.perfil, required this.onEditar, required this.onConvidar});
  final Perfil perfil;
  final VoidCallback onEditar;
  final VoidCallback onConvidar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -54,
            left: 0,
            right: 0,
            child: Center(
              child: _AvatarCirculo(
                emoji: AvatarCatalog.emoji(perfil.avatar),
                onEditar: onEditar,
              ),
            ),
          ),
          Positioned(
            top: -16,
            right: 0,
            child: _BotaoConvidar(onTap: onConvidar),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                perfil.nome.isEmpty ? 'Sua conta' : perfil.nome,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 28 / 20,
                ),
              ),
              if ((perfil.localizacao ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.primaryDark),
                    const SizedBox(width: 4),
                    Text(
                      perfil.localizacao!,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarCirculo extends StatelessWidget {
  const _AvatarCirculo({required this.emoji, required this.onEditar});
  final String emoji;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF2F9F8), width: 4),
          ),
          alignment: Alignment.center,
          child: emoji.isEmpty
              ? const Icon(Icons.person, color: AppColors.textMuted, size: 36)
              : Text(emoji, style: const TextStyle(fontSize: 44)),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: InkWell(
            onTap: onEditar,
            customBorder: const CircleBorder(),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [
                  BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.edit, size: 12, color: Color(0xFF6B7280)),
            ),
          ),
        ),
      ],
    );
  }
}

class _BotaoConvidar extends StatelessWidget {
  const _BotaoConvidar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.qr_code_2, size: 18, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Convidar',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridEstatisticas extends StatelessWidget {
  const _GridEstatisticas({required this.perfil});
  final Perfil perfil;

  String _formatarMoeda(double valor) {
    final inteiro = valor.toInt();
    final s = inteiro.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CardStat(
            valor: perfil.maesAjudadas.toString(),
            rotulo: 'Mães ajudadas',
            corBorda: const Color(0xFFFFF7ED),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _CardStat(
            prefixo: 'R\$',
            valor: _formatarMoeda(perfil.economizou),
            rotulo: 'Economizou',
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _CardStat(
            valor: perfil.desapegosRealizados.toString(),
            rotulo: 'Desapegos realizados',
          ),
        ),
      ],
    );
  }
}

class _CardStat extends StatelessWidget {
  const _CardStat({
    this.prefixo,
    required this.valor,
    required this.rotulo,
    this.corBorda,
  });

  final String? prefixo;
  final String valor;
  final String rotulo;
  final Color? corBorda;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: corBorda != null ? Border.all(color: corBorda!, width: 1.5) : null,
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 1.5, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (prefixo != null) ...[
                Text(
                  prefixo!,
                  style: const TextStyle(
                    color: Color(0xFF66C2B9),
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 2),
              ],
              Text(
                valor,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            rotulo,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 11,
              height: 1.18,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFilhos extends StatelessWidget {
  const _CardFilhos({required this.filhos, required this.onAbrir});
  final List<Filho> filhos;
  final VoidCallback onAbrir;

  String _idade(Filho f) {
    if (f.dataNascimento == null) return '';
    final agora = DateTime.now();
    final anos = agora.year - f.dataNascimento!.year -
        ((agora.month < f.dataNascimento!.month ||
                (agora.month == f.dataNascimento!.month && agora.day < f.dataNascimento!.day))
            ? 1
            : 0);
    if (anos >= 1) return anos == 1 ? '1 ano' : '$anos anos';
    final meses = (agora.year - f.dataNascimento!.year) * 12 +
        (agora.month - f.dataNascimento!.month);
    if (meses >= 1) return meses == 1 ? '1 mês' : '$meses meses';
    return 'Recém-nascido';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          for (final f in filhos)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      AvatarCatalog.emoji(f.avatar).isEmpty
                          ? '👶'
                          : AvatarCatalog.emoji(f.avatar),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.nome,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_idade(f).isNotEmpty)
                          Text(
                            _idade(f),
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _BotaoEditarFilho(onTap: onAbrir),
                ],
              ),
            ),
          if (filhos.isNotEmpty)
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          InkWell(
            onTap: onAbrir,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.add, color: AppColors.primary, size: 14),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Adicionar filho',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoEditarFilho extends StatelessWidget {
  const _BotaoEditarFilho({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, size: 12, color: Color(0xFF4B5563)),
              SizedBox(width: 6),
              Text(
                'Editar',
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardAtalhos extends StatelessWidget {
  const _CardAtalhos({required this.filhos, required this.perfil});
  final List<Filho> filhos;
  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    final totalPosts = perfil.desapegosRealizados;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          _LinhaAtalho(
            icone: Icons.person_outline,
            titulo: 'Meus posts',
            subtitulo: 'Comunidade Maternow',
            trailing: Text(
              '$totalPosts posts',
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
            onTap: () => Navigator.of(context).pushNamed('/meus-posts'),
            primeiro: true,
          ),
          const Divider(height: 1, color: Color(0xFFF9FAFB)),
          _LinhaAtalho(
            icone: Icons.favorite_border,
            titulo: 'Favoritos',
            onTap: () => _placeholder(context, 'Favoritos'),
          ),
          const Divider(height: 1, color: Color(0xFFF9FAFB)),
          _LinhaAtalho(
            icone: Icons.inventory_2_outlined,
            titulo: 'Meus recebidos',
            onTap: () => Navigator.of(context).pushNamed('/meus-recebidos'),
            ultimo: true,
          ),
        ],
      ),
    );
  }

  void _placeholder(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label em breve.')),
    );
  }
}

class _LinhaAtalho extends StatelessWidget {
  const _LinhaAtalho({
    required this.icone,
    required this.titulo,
    this.subtitulo,
    this.trailing,
    required this.onTap,
    this.primeiro = false,
    this.ultimo = false,
  });

  final IconData icone;
  final String titulo;
  final String? subtitulo;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool primeiro;
  final bool ultimo;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: primeiro ? const Radius.circular(20) : Radius.zero,
        bottom: ultimo ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icone, color: const Color(0xFF374151), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitulo!,
                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}

class _ErroBox extends StatelessWidget {
  const _ErroBox({required this.mensagem, required this.onTentar});
  final String mensagem;
  final VoidCallback onTentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text, fontSize: 13),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onTentar, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
