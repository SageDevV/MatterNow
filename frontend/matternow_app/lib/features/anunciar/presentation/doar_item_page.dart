import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_models.dart';
import '../../home/presentation/widgets/bottom_nav.dart';
import '../../home/presentation/widgets/home_header.dart';
import '../data/anuncio_models.dart';
import '../data/anuncio_repository.dart';
import 'galeria_fotos_page.dart';
import 'widgets/bottom_sheet_picker.dart';
import 'widgets/faixa_etaria_modal.dart';
import 'widgets/foto_origem_modal.dart';

/// Tela "Doar item" — replica o frame do fluxo de doação do Figma. Reaproveita
/// os mesmos modais/seletores do fluxo de venda, mas substitui o preço por uma
/// "história de amor" (texto livre que descreve a memória ligada ao item).
class DoarItemPage extends StatefulWidget {
  const DoarItemPage({super.key, required this.repository});
  final AnuncioRepository repository;

  @override
  State<DoarItemPage> createState() => _DoarItemPageState();
}

class _DoarItemPageState extends State<DoarItemPage> {
  static const _alturaCabecalho = 60.0;
  static const _maxFotos = 8;

  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _historiaCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();

  final List<String> _fotos = [];
  CategoriaProduto? _categoria;
  String? _faixaEtaria;
  EstadoProduto _estado = EstadoProduto.usado;
  bool _publicando = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _historiaCtrl.dispose();
    _cepCtrl.dispose();
    super.dispose();
  }

  // ----------------------- handlers -----------------------

  Future<void> _adicionarFotos() async {
    final origem = await FotoOrigemModal.mostrar(context);
    if (!mounted || origem == null) return;

    if (origem == FotoOrigem.camera) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Câmera disponível em breve.')),
      );
      return;
    }

    final selecao = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => GaleriaFotosPage(
          maxSelecao: _maxFotos,
          jaSelecionadas: _fotos,
        ),
      ),
    );
    if (!mounted || selecao == null) return;
    setState(() {
      _fotos
        ..clear()
        ..addAll(selecao);
    });
  }

  Future<void> _abrirCategoria() async {
    final escolhido = await BottomSheetPicker.mostrar<CategoriaProduto>(
      context: context,
      tituloPlaceholder: 'Selecione uma categoria',
      selecionado: _categoria,
      opcoes: [
        for (final c in CategoriaProduto.values) (valor: c, rotulo: c.rotulo),
      ],
    );
    if (!mounted) return;
    setState(() => _categoria = escolhido);
  }

  Future<void> _abrirFaixaEtaria() async {
    final escolhida = await FaixaEtariaModal.mostrar(context, selecionada: _faixaEtaria);
    if (!mounted || escolhida == null) return;
    setState(() => _faixaEtaria = escolhida);
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma foto.')),
      );
      return;
    }
    if (_categoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha uma categoria.')),
      );
      return;
    }
    if (_faixaEtaria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha a faixa etária.')),
      );
      return;
    }

    setState(() => _publicando = true);
    try {
      await widget.repository.doar(
        NovaDoacao(
          fotos: _fotos,
          categoria: _categoria!,
          faixaEtaria: _faixaEtaria!,
          estado: _estado,
          titulo: _tituloCtrl.text.trim(),
          historia: _historiaCtrl.text.trim(),
          cep: _cepCtrl.text.isEmpty ? null : _cepCtrl.text,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doação publicada! 💛')),
      );
      Navigator.of(context).pop(true);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensagem)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível publicar agora.')),
      );
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  // ----------------------- UI -----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          HomeHeader(
            altura: _alturaCabecalho,
            titulo: 'Doar item',
            onVoltar: () => Navigator.of(context).maybePop(),
            notificacoes: 1,
            onConfig: () {},
            onNotificacoes: () => Navigator.of(context).pushNamed('/notificacoes'),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 4, 0, 12),
                      child: Center(
                        child: Text(
                          '🧡 Passe o amor adiante',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    _Label('Fotos do produto (${_fotos.length}/$_maxFotos)'),
                    const SizedBox(height: 8),
                    _CardFotos(
                      fotos: _fotos,
                      onAdicionar: _adicionarFotos,
                      onRemover: (id) => setState(() => _fotos.remove(id)),
                    ),
                    const SizedBox(height: 16),
                    const _Label('Categoria'),
                    const SizedBox(height: 8),
                    _CampoSelecao(
                      texto: _categoria?.rotulo ?? 'Selecione uma categoria',
                      placeholder: _categoria == null,
                      onTap: _abrirCategoria,
                    ),
                    const SizedBox(height: 16),
                    const _Label('Faixa etária'),
                    const SizedBox(height: 8),
                    _CampoSelecao(
                      texto: _faixaEtaria ?? 'Selecione a faixa etária',
                      placeholder: _faixaEtaria == null,
                      onTap: _abrirFaixaEtaria,
                    ),
                    const SizedBox(height: 16),
                    const _Label('Estado do produto'),
                    const SizedBox(height: 8),
                    _ChipsEstado(
                      atual: _estado,
                      onSelect: (v) => setState(() => _estado = v),
                    ),
                    const SizedBox(height: 16),
                    const _Label('Título do anúncio'),
                    const SizedBox(height: 8),
                    _CampoTexto(
                      controller: _tituloCtrl,
                      hint: 'Ex: Carrinho de bebê Chicco em ótimo est',
                      validator: (v) => (v ?? '').trim().isEmpty ? 'Informe um título.' : null,
                      sufixo: const Icon(Icons.auto_awesome,
                          size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    const _Label('História de amor'),
                    const SizedBox(height: 8),
                    _CampoTexto(
                      controller: _historiaCtrl,
                      hint: 'Conte um pouco sobre as memórias que este item carrega...',
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Conte uma memória ligada ao item.' : null,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    const _Label('Localização'),
                    const SizedBox(height: 8),
                    _CampoTexto(
                      controller: _cepCtrl,
                      hint: 'CEP: 00000-000',
                      keyboardType: TextInputType.number,
                      prefixo: const Icon(Icons.place_outlined,
                          size: 18, color: AppColors.primary),
                      formatters: [_CepFormatter()],
                    ),
                    const SizedBox(height: 24),
                    _BotaoPublicar(
                      carregando: _publicando,
                      onTap: _publicar,
                    ),
                  ],
                ),
              ),
            ),
          ),
          HomeBottomNav(
            indice: 2,
            onChanged: (i) {
              if (i == 4) {
                Navigator.of(context).pushNamed('/profile');
                return;
              }
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            onAnunciar: () {},
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Componentes auxiliares (locais para esta tela; espelham os do Vender)
// ============================================================

class _Label extends StatelessWidget {
  const _Label(this.texto);
  final String texto;
  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CardFotos extends StatelessWidget {
  const _CardFotos({
    required this.fotos,
    required this.onAdicionar,
    required this.onRemover,
  });

  final List<String> fotos;
  final VoidCallback onAdicionar;
  final ValueChanged<String> onRemover;

  @override
  Widget build(BuildContext context) {
    final vazio = fotos.isEmpty;
    return InkWell(
      onTap: onAdicionar,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          alignment: Alignment.center,
          child: vazio
              ? const _PlaceholderFotos()
              : _ThumbsHorizontais(
                  fotos: fotos,
                  onRemover: onRemover,
                  onAdicionar: onAdicionar,
                ),
        ),
      ),
    );
  }
}

class _PlaceholderFotos extends StatelessWidget {
  const _PlaceholderFotos();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.photo_camera_outlined,
              size: 24, color: AppColors.primary),
        ),
        const SizedBox(height: 10),
        const Text(
          'Adicionar fotos',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Tirar foto ou escolher da galeria',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
      ],
    );
  }
}

class _ThumbsHorizontais extends StatelessWidget {
  const _ThumbsHorizontais({
    required this.fotos,
    required this.onRemover,
    required this.onAdicionar,
  });

  final List<String> fotos;
  final ValueChanged<String> onRemover;
  final VoidCallback onAdicionar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fotos.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == fotos.length) {
            return InkWell(
              onTap: onAdicionar,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.add, color: AppColors.primary),
              ),
            );
          }
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined,
                    size: 24, color: Color(0xFF9CA3AF)),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: InkWell(
                  onTap: () => onRemover(fotos[i]),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.close,
                        size: 14, color: Color(0xFF6B7280)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CampoSelecao extends StatelessWidget {
  const _CampoSelecao({
    required this.texto,
    required this.placeholder,
    required this.onTap,
  });

  final String texto;
  final bool placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  color: placeholder
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: placeholder ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF9CA3AF), size: 22),
          ],
        ),
      ),
    );
  }
}

class _ChipsEstado extends StatelessWidget {
  const _ChipsEstado({required this.atual, required this.onSelect});
  final EstadoProduto atual;
  final ValueChanged<EstadoProduto> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in EstadoProduto.values)
          _Chip(
            label: e.rotulo,
            ativo: e == atual,
            onTap: () => onSelect(e),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.ativo, required this.onTap});
  final String label;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: ativo ? AppColors.primary : const Color(0xFFE5E7EB),
            width: ativo ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: ativo ? AppColors.primary : const Color(0xFF1F2937),
            fontSize: 14,
            fontWeight: ativo ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  const _CampoTexto({
    required this.controller,
    required this.hint,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixo,
    this.sufixo,
    this.formatters,
  });

  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final Widget? prefixo;
  final Widget? sufixo;
  final List<TextInputFormatter>? formatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          border: InputBorder.none,
          isDense: true,
          prefixIcon: prefixo,
          prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 24),
          suffixIcon: sufixo,
          suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _BotaoPublicar extends StatelessWidget {
  const _BotaoPublicar({required this.carregando, required this.onTap});
  final bool carregando;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: carregando ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: carregando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('💛', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Publicar Doação'),
                ],
              ),
      ),
    );
  }
}

/// Formata como CEP brasileiro: 00000-000.
class _CepFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digitos.length > 8 ? digitos.substring(0, 8) : digitos;
    final buf = StringBuffer();
    for (var i = 0; i < clipped.length; i++) {
      if (i == 5) buf.write('-');
      buf.write(clipped[i]);
    }
    final texto = buf.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
