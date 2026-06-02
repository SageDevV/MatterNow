import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_models.dart';
import '../../profile/presentation/avatar_page.dart';
import '../../profile/presentation/foto_preview_page.dart';
import '../../profile/presentation/widgets/avatar_catalog.dart';
import '../../profile/presentation/widgets/foto_picker_modal.dart';
import '../data/filho_models.dart';
import '../data/filhos_repository.dart';
import 'widgets/data_nascimento_picker.dart';
import 'widgets/faixa_etaria_picker.dart';

/// Tela "Cadastro da criança" — replica o frame "Cadastro da criança" do
/// Figma. Cria ou edita um filho associado ao usuário autenticado.
class ChildFormPage extends StatefulWidget {
  const ChildFormPage({super.key, required this.repository, this.filho});
  final FilhosRepository repository;
  final Filho? filho;

  @override
  State<ChildFormPage> createState() => _ChildFormPageState();
}

class _ChildFormPageState extends State<ChildFormPage> {
  static const _alturaCabecalho = 80.0;

  // Tons fiéis ao Figma: cards em cinza muito claro, inputs brancos com borda fina.
  static const _bgCard = Color(0xFFF1F1F1);
  static const _bgInput = Colors.white;
  static const _bordaInput = Color(0xFFCCCCCC);
  static const _chipBege = Color(0xFFFCE9C5); // tons de bege quentes do Figma

  final _nomeCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();

  String? _avatar;
  DateTime? _dataNascimento;
  String? _faixaEtaria;
  String? _tamanhoRoupa;
  GeneroFilho _genero = GeneroFilho.naoInformar;

  bool _salvando = false;
  String? _erro;

  bool get _editando => widget.filho != null;

  @override
  void initState() {
    super.initState();
    final f = widget.filho;
    if (f != null) {
      _nomeCtrl.text = f.nome;
      _avatar = f.avatar;
      _dataNascimento = f.dataNascimento;
      _faixaEtaria = f.faixaEtaria;
      _tamanhoRoupa = f.tamanhoRoupa;
      _genero = f.genero;
      if (f.pesoKg != null) _pesoCtrl.text = f.pesoKg!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  // --- Foto / avatar ---------------------------------------------------------
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

  Future<void> _abrirAvatar() async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const AvatarPage(categoria: AvatarCategoria.animais)),
    );
    if (!mounted) return;
    if (id != null) setState(() => _avatar = id);
  }

  // --- Salvar ----------------------------------------------------------------
  Future<void> _salvar() async {
    if (_nomeCtrl.text.trim().isEmpty) {
      setState(() => _erro = 'Informe um nome ou apelido para a criança.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final pesoTexto = _pesoCtrl.text.trim().replaceAll(',', '.');
    final peso = pesoTexto.isEmpty ? null : double.tryParse(pesoTexto);

    try {
      if (_editando) {
        await widget.repository.atualizar(
          id: widget.filho!.id,
          nome: _nomeCtrl.text.trim(),
          avatar: _avatar,
          dataNascimento: _dataNascimento,
          faixaEtaria: _faixaEtaria,
          tamanhoRoupa: _tamanhoRoupa,
          genero: _genero,
          pesoKg: peso,
        );
      } else {
        await widget.repository.criar(
          nome: _nomeCtrl.text.trim(),
          avatar: _avatar,
          dataNascimento: _dataNascimento,
          faixaEtaria: _faixaEtaria,
          tamanhoRoupa: _tamanhoRoupa,
          genero: _genero,
          pesoKg: peso,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível salvar.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  // --- Build -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _Cabecalho(
            altura: _alturaCabecalho,
            onVoltar: () => Navigator.of(context).pop(),
            onSalvar: _salvando ? null : _salvar,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text(
                        'Esse perfil é do seu filho (a)',
                        style: TextStyle(color: AppColors.text, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Se quiser, você pode adicionar uma foto ou escolher um avatar.\nIsso ajuda a personalizar a experiência, e é totalmente opcional',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: _abrirSeletorFoto,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.08),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1),
                          ),
                          alignment: Alignment.center,
                          child: _avatar == null
                              ? const Icon(Icons.camera_alt_outlined, color: AppColors.primary)
                              : Text(AvatarCatalog.emoji(_avatar), style: const TextStyle(fontSize: 40)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _BotaoPilula(emoji: '📷', texto: 'Adicionar foto', onTap: _abrirSeletorFoto)),
                        const SizedBox(width: 12),
                        Expanded(child: _BotaoPilula(emoji: '🐻', texto: 'Escolher avatar', onTap: _abrirAvatar)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SecaoCard(
                      child: _InputBranco(
                        controller: _nomeCtrl,
                        hint: 'Nome ou apelido da criança',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SecaoCard(
                      titulo: 'Data de nascimento da criança',
                      child: _InputTap(
                        valor: _dataNascimento == null
                            ? null
                            : '${_dataNascimento!.day} de ${_nomeMes(_dataNascimento!.month)}',
                        placeholder: 'Selecionar data',
                        icone: Icons.calendar_month_outlined,
                        onTap: () async {
                          final r = await DataNascimentoPicker.mostrar(context, selecionado: _dataNascimento);
                          if (r != null) setState(() => _dataNascimento = r);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SecaoCard(
                      titulo: 'Qual a faixa etária',
                      sufixo: const Text(
                        'Isso ajuda a sugerir desapegos no tempo certo',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                      child: _InputTap(
                        valor: _faixaEtaria,
                        placeholder: 'Selecionar',
                        icone: Icons.expand_more,
                        onTap: () async {
                          final r = await FaixaEtariaPicker.mostrar(context, selecionado: _faixaEtaria);
                          if (r != null) setState(() => _faixaEtaria = r);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SecaoCard(
                      titulo: 'O filho (a) é:',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChipPlano(label: 'Menina', selecionado: _genero == GeneroFilho.menina,
                              onTap: () => setState(() => _genero = GeneroFilho.menina)),
                          _ChipPlano(label: 'Menino', selecionado: _genero == GeneroFilho.menino,
                              onTap: () => setState(() => _genero = GeneroFilho.menino)),
                          _ChipPlano(label: 'Não informar', selecionado: _genero == GeneroFilho.naoInformar,
                              onTap: () => setState(() => _genero = GeneroFilho.naoInformar)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SecaoCard(
                      titulo: 'Tamanho de roupa',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in TamanhoRoupaCatalogo.opcoes)
                            _ChipPlano(
                              label: t,
                              selecionado: _tamanhoRoupa == t,
                              onTap: () => setState(() => _tamanhoRoupa = _tamanhoRoupa == t ? null : t),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SecaoCard(
                      tituloComplemento: 'Peso aproximado',
                      sufixoTitulo: '(opcional)',
                      child: _InputBrancoComIcone(
                        controller: _pesoCtrl,
                        hint: 'Ex: 2,5 ..... 3kg',
                        sufixo: 'KG',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: 16),
                      Text(_erro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _nomeMes(int m) {
    const meses = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return meses[m - 1];
  }
}

// ---------------------------------------------------------------------------
// Componentes auxiliares
// ---------------------------------------------------------------------------

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.altura, required this.onVoltar, required this.onSalvar});
  final double altura;
  final VoidCallback onVoltar;
  final VoidCallback? onSalvar;

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
          // No Figma o título aparece em maiúsculas e em uma tonalidade levemente
          // mais clara que o branco puro.
          Text(
            'CADASTRO DA CRIANÇA',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onVoltar,
              icon: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.85)),
              tooltip: 'Voltar',
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.white.withValues(alpha: 0.18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onSalvar,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    child: Text(
                      'Salvar',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
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

/// Card cinza-claro usado como contêiner de cada seção.
class _SecaoCard extends StatelessWidget {
  const _SecaoCard({
    required this.child,
    this.titulo,
    this.tituloComplemento,
    this.sufixoTitulo,
    this.sufixo,
  });

  final Widget child;
  final String? titulo;
  final String? tituloComplemento;
  final String? sufixoTitulo;
  final Widget? sufixo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ChildFormPageState._bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null || tituloComplemento != null) ...[
            Row(
              children: [
                Text(
                  titulo ?? tituloComplemento ?? '',
                  style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (sufixoTitulo != null) ...[
                  const SizedBox(width: 6),
                  Text(sufixoTitulo!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ],
            ),
            const SizedBox(height: 10),
          ],
          child,
          if (sufixo != null) ...[
            const SizedBox(height: 8),
            sufixo!,
          ],
        ],
      ),
    );
  }
}

/// Input branco com borda cinza, igual ao Figma — usado dentro dos cards.
class _InputBranco extends StatelessWidget {
  const _InputBranco({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ChildFormPageState._bgInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _ChildFormPageState._bordaInput, width: 0.6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ),
    );
  }
}

class _InputBrancoComIcone extends StatelessWidget {
  const _InputBrancoComIcone({
    required this.controller,
    required this.hint,
    required this.sufixo,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String hint;
  final String sufixo;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ChildFormPageState._bgInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _ChildFormPageState._bordaInput, width: 0.6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(sufixo, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _InputTap extends StatelessWidget {
  const _InputTap({this.valor, required this.placeholder, required this.icone, required this.onTap});
  final String? valor;
  final String placeholder;
  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: _ChildFormPageState._bgInput,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _ChildFormPageState._bordaInput, width: 0.6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                valor ?? placeholder,
                style: TextStyle(
                  color: valor == null ? AppColors.textMuted : AppColors.text,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(icone, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Chip plano (sem borda) com fundo bege quando não selecionado.
class _ChipPlano extends StatelessWidget {
  const _ChipPlano({required this.label, required this.selecionado, required this.onTap});
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionado ? AppColors.primary : _ChildFormPageState._chipBege,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: selecionado ? Colors.white : AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pílula clicável usada nos botões "Adicionar foto" / "Escolher avatar".
class _BotaoPilula extends StatelessWidget {
  const _BotaoPilula({required this.emoji, required this.texto, required this.onTap});
  final String emoji;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.25), width: 0.6),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(texto, style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
