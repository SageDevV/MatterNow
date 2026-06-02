import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_models.dart';
import '../../profile/presentation/widgets/avatar_catalog.dart';
import '../data/filho_models.dart';
import '../data/filhos_repository.dart';
import 'child_form_page.dart';

/// Lista os filhos cadastrados do usuário e oferece o CTA "Adicionar mais
/// filhos" — replica o frame com a lista do Figma.
class ChildrenListPage extends StatefulWidget {
  const ChildrenListPage({super.key, required this.repository});
  final FilhosRepository repository;

  @override
  State<ChildrenListPage> createState() => _ChildrenListPageState();
}

class _ChildrenListPageState extends State<ChildrenListPage> {
  static const _alturaCabecalho = 80.0;

  late Future<List<Filho>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = widget.repository.listar();
  }

  void _recarregar() {
    setState(() => _futuro = widget.repository.listar());
  }

  Future<void> _abrirCadastro({Filho? filho}) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChildFormPage(repository: widget.repository, filho: filho),
      ),
    );
    if (ok == true) _recarregar();
  }

  Future<void> _remover(Filho f) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remover ${f.nome}?'),
        content: const Text('Os dados deste filho serão excluídos.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Remover')),
        ],
      ),
    );
    if (confirma != true) return;
    try {
      await widget.repository.remover(f.id);
      if (mounted) _recarregar();
    } on AuthFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
      }
    }
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
              child: FutureBuilder<List<Filho>>(
                future: _futuro,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    final mensagem = snapshot.error is AuthFailure
                        ? (snapshot.error as AuthFailure).mensagem
                        : 'Não foi possível carregar a lista.';
                    return _ErroBox(mensagem: mensagem, onTentar: _recarregar);
                  }
                  final filhos = snapshot.data ?? [];
                  return _Lista(
                    filhos: filhos,
                    onAdicionar: () => _abrirCadastro(),
                    onEditar: (f) => _abrirCadastro(filho: f),
                    onRemover: _remover,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({
    required this.filhos,
    required this.onAdicionar,
    required this.onEditar,
    required this.onRemover,
  });

  final List<Filho> filhos;
  final VoidCallback onAdicionar;
  final void Function(Filho) onEditar;
  final void Function(Filho) onRemover;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Center(
          child: Text(
            'Perfil do seu filho (a)',
            style: TextStyle(color: AppColors.invite, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Cadastre as crianças que você cuida\npara personalizar a experiência',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.text, fontSize: 12, height: 1.4),
          ),
        ),
        const SizedBox(height: 24),
        if (filhos.isEmpty)
          _Vazio(onAdicionar: onAdicionar)
        else ...[
          for (final f in filhos) _CardFilho(filho: f, onEditar: onEditar, onRemover: onRemover),
          const SizedBox(height: 16),
          _BotaoAdicionar(onTap: onAdicionar),
        ],
      ],
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio({required this.onAdicionar});
  final VoidCallback onAdicionar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Icon(Icons.child_care_outlined, size: 64, color: AppColors.textMuted),
        const SizedBox(height: 16),
        const Text('Você ainda não cadastrou ninguém.',
            style: TextStyle(color: AppColors.text, fontSize: 13)),
        const SizedBox(height: 24),
        _BotaoAdicionar(onTap: onAdicionar, primario: true),
      ],
    );
  }
}

class _CardFilho extends StatelessWidget {
  const _CardFilho({required this.filho, required this.onEditar, required this.onRemover});
  final Filho filho;
  final void Function(Filho) onEditar;
  final void Function(Filho) onRemover;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3), width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(AvatarCatalog.emoji(filho.avatar).isEmpty ? '👶' : AvatarCatalog.emoji(filho.avatar),
              style: const TextStyle(fontSize: 24)),
        ),
        title: Text(filho.nome,
            style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(_subtitulo(filho),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
          onSelected: (v) {
            if (v == 'editar') onEditar(filho);
            if (v == 'remover') onRemover(filho);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(value: 'remover', child: Text('Remover')),
          ],
        ),
      ),
    );
  }

  String _subtitulo(Filho f) {
    final partes = <String>[];
    if (f.faixaEtaria != null) partes.add(f.faixaEtaria!);
    if (f.tamanhoRoupa != null) partes.add(f.tamanhoRoupa!);
    if (f.dataNascimento != null) {
      final d = f.dataNascimento!;
      partes.add('${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}');
    }
    return partes.isEmpty ? 'Sem dados adicionais' : partes.join(' • ');
  }
}

class _BotaoAdicionar extends StatelessWidget {
  const _BotaoAdicionar({required this.onTap, this.primario = false});
  final VoidCallback onTap;
  final bool primario;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primario ? AppColors.primary : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primary, width: primario ? 0 : 0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: primario ? Colors.white : AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'Adicionar mais filhos',
                style: TextStyle(
                  color: primario ? Colors.white : AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
            Text(mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.text, fontSize: 13)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onTentar, child: const Text('Tentar novamente')),
          ],
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
          const Text('Meus filhos',
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
