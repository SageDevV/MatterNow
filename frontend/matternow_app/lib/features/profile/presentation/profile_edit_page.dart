import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_models.dart';
import '../data/profile_models.dart';
import '../data/profile_repository.dart';
import 'foto_preview_page.dart';
import 'widgets/avatar_catalog.dart';
import 'widgets/foto_picker_modal.dart';

/// Tela "Meu cadastro" — replica o frame de edição do Figma.
/// Permite definir nome, localização, avatar/foto e categorias de interesse.
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key, required this.repository});
  final ProfileRepository repository;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  static const _alturaCabecalho = 80.0;

  final _nomeCtrl = TextEditingController();
  final _localizacaoCtrl = TextEditingController();
  final Set<String> _interesses = {};
  String? _avatar;
  String? _email;
  bool _carregando = true;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _localizacaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final perfil = await widget.repository.obterMeuPerfil();
      if (!mounted) return;
      setState(() {
        _nomeCtrl.text = perfil.nome;
        _localizacaoCtrl.text = perfil.localizacao ?? '';
        _email = perfil.email;
        _avatar = perfil.avatar;
        _interesses
          ..clear()
          ..addAll(perfil.interesses);
        _carregando = false;
      });
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar seu perfil.';
        _carregando = false;
      });
    }
  }

  Future<void> _abrirSeletorFoto() async {
    final escolha = await FotoPickerModal.mostrar(context);
    if (!mounted || escolha == null) return;

    switch (escolha) {
      case FotoCamera():
      case FotoGaleria():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload de foto chega na próxima versão.')),
        );
        break;
      case FotoAvatar(:final avatarId):
        final ok = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => FotoPreviewPage(avatarEmoji: AvatarCatalog.emoji(avatarId))),
        );
        if (!mounted) return;
        if (ok == true) setState(() => _avatar = avatarId);
        break;
    }
  }

  Future<void> _salvar() async {
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await widget.repository.atualizarPerfil(
        nome: _nomeCtrl.text.trim(),
        localizacao: _localizacaoCtrl.text.trim(),
        avatar: _avatar,
        interesses: _interesses.toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível salvar seu perfil.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _toggleInteresse(String id) {
    setState(() {
      if (_interesses.contains(id)) {
        _interesses.remove(id);
      } else {
        _interesses.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Cabecalho(altura: _alturaCabecalho, onVoltar: () => Navigator.of(context).pop()),
          Expanded(child: _carregando ? _loading() : _conteudo()),
        ],
      ),
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());

  Widget _conteudo() {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Seu perfil',
                style: TextStyle(color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: _AvatarBotao(emoji: AvatarCatalog.emoji(_avatar), onTap: _abrirSeletorFoto)),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _abrirSeletorFoto,
                child: const Text('Adicionar foto',
                    style: TextStyle(color: AppColors.primaryDark, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 24),
            _CampoBordado(
              icone: Icons.person_outline,
              child: TextField(
                controller: _nomeCtrl,
                style: const TextStyle(color: AppColors.text, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Nome ou apelido',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _CampoBordado(
              icone: Icons.place_outlined,
              child: TextField(
                controller: _localizacaoCtrl,
                style: const TextStyle(color: AppColors.text, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Sua localização',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _CampoBordado(
              icone: Icons.mail_outline,
              child: Text(
                _email ?? '',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Seus interesses',
              style: TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _GridInteresses(
              selecionados: _interesses,
              onToggle: _toggleInteresse,
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'A Maternow personaliza tudo por fase e idade',
                style: TextStyle(color: AppColors.text, fontSize: 11),
              ),
            ),
            if (_erro != null) ...[
              const SizedBox(height: 16),
              Text(_erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _salvando ? null : _salvar,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: const BorderSide(color: AppColors.primary, width: 0.8),
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontSize: 14),
              ),
              child: _salvando
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarBotao extends StatelessWidget {
  const _AvatarBotao({required this.emoji, required this.onTap});
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.08),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1),
        ),
        alignment: Alignment.center,
        child: emoji.isEmpty
            ? const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 30)
            : Text(emoji, style: const TextStyle(fontSize: 56)),
      ),
    );
  }
}

class _CampoBordado extends StatelessWidget {
  const _CampoBordado({required this.icone, required this.child});
  final IconData icone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icone, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 14),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _GridInteresses extends StatelessWidget {
  const _GridInteresses({required this.selecionados, required this.onToggle});
  final Set<String> selecionados;
  final void Function(String) onToggle;

  // Emojis pra ilustrar cada categoria — substituível por imagens reais depois.
  static const _emojis = {
    InteressesCatalogo.roupasCalcados: '👕',
    InteressesCatalogo.carrinhoBebeConforto: '🚼',
    InteressesCatalogo.bercosMobilias: '🛏️',
    InteressesCatalogo.fraldasEnxoval: '🍼',
    InteressesCatalogo.brinquedosLivros: '🧸',
    InteressesCatalogo.alimentacaoHigiene: '🍽️',
  };

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: InteressesCatalogo.todos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (context, i) {
        final cat = InteressesCatalogo.todos[i];
        final selecionado = selecionados.contains(cat.id);
        return _CardInteresse(
          emoji: _emojis[cat.id] ?? '✨',
          label: cat.label,
          selecionado: selecionado,
          onTap: () => onToggle(cat.id),
        );
      },
    );
  }
}

class _CardInteresse extends StatelessWidget {
  const _CardInteresse({
    required this.emoji,
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionado ? AppColors.primary.withValues(alpha: 0.18) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selecionado ? AppColors.primary : AppColors.border.withValues(alpha: 0.3),
          width: selecionado ? 1 : 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 11,
                    fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CircleAvatar(
                radius: 9,
                backgroundColor: selecionado ? const Color(0xFF2EAE7A) : Colors.white,
                child: selecionado
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1),
                        ),
                      ),
              ),
            ],
          ),
        ),
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
          const Text('Meu cadastro',
              style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: -0.42)),
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
