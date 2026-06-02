import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_models.dart';
import '../../home/presentation/widgets/bottom_nav.dart';
import '../../home/presentation/widgets/home_header.dart';
import '../data/anuncio_models.dart';
import '../data/anuncio_repository.dart';
import 'galeria_fotos_page.dart';
import 'widgets/faixa_etaria_modal.dart';
import 'widgets/foto_origem_modal.dart';

/// Tela "Perguntar" — replica o frame de pedido de ajuda à comunidade.
/// Diferente de Vender/Doar:
/// - Não tem categoria de produto, mas chips de tema (sono, amamentação, ...)
/// - Pergunta tem limite de 100 caracteres
/// - Detalhes opcionais
/// - Faixa etária reutiliza o mesmo modal wheel
/// - Fotos opcionais
/// - Card "Ambiente seguro e acolhedor"
/// - CTA "Pedir ajuda à comunidade 💛"
class PerguntarPage extends StatefulWidget {
  const PerguntarPage({super.key, required this.repository});
  final AnuncioRepository repository;

  @override
  State<PerguntarPage> createState() => _PerguntarPageState();
}

class _PerguntarPageState extends State<PerguntarPage> {
  static const _alturaCabecalho = 60.0;
  static const _maxFotos = 8;
  static const _maxPergunta = 100;

  final _formKey = GlobalKey<FormState>();
  final _perguntaCtrl = TextEditingController();
  final _detalhesCtrl = TextEditingController();

  final List<String> _fotos = [];
  TemaPergunta? _tema;
  String? _faixaEtaria;
  bool _publicando = false;

  @override
  void initState() {
    super.initState();
    _perguntaCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _perguntaCtrl.dispose();
    _detalhesCtrl.dispose();
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

  Future<void> _abrirFaixaEtaria() async {
    final escolhida = await FaixaEtariaModal.mostrar(context, selecionada: _faixaEtaria);
    if (!mounted || escolhida == null) return;
    setState(() => _faixaEtaria = escolhida);
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tema == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha o tema da sua pergunta.')),
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
      await widget.repository.perguntar(
        NovaPergunta(
          tema: _tema!,
          pergunta: _perguntaCtrl.text.trim(),
          detalhes: _detalhesCtrl.text.trim().isEmpty ? null : _detalhesCtrl.text.trim(),
          faixaEtaria: _faixaEtaria!,
          fotos: _fotos,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pergunta publicada! 💛')),
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
            titulo: 'Perguntar',
            onVoltar: () => Navigator.of(context).maybePop(),
            notificacoes: 1,
            onConfig: () {},
            onNotificacoes: () => Navigator.of(context).pushNamed('/notificacoes'),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text(
                        'Escolha o tema da sua pergunta',
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ChipsTema(
                      atual: _tema,
                      onSelect: (t) => setState(() => _tema = t),
                    ),
                    const SizedBox(height: 24),
                    _LabelComContador(
                      label: 'Qual a sua pergunta',
                      atual: _perguntaCtrl.text.length,
                      maximo: _maxPergunta,
                    ),
                    const SizedBox(height: 8),
                    _CampoTexto(
                      controller: _perguntaCtrl,
                      hint: 'Ex: Meu bebê não dorme à noite, o que faz',
                      maxLength: _maxPergunta,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Escreva sua pergunta.' : null,
                    ),
                    const SizedBox(height: 16),
                    const _LabelOpcional(
                      label: 'Conte mais detalhes',
                      opcional: true,
                    ),
                    const SizedBox(height: 8),
                    _CampoTexto(
                      controller: _detalhesCtrl,
                      hint: 'Descreva o que está acontecendo...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    const _Label('Faixa etária'),
                    const SizedBox(height: 8),
                    _CampoSelecao(
                      texto: _faixaEtaria ?? 'Selecione a faixa etária',
                      placeholder: _faixaEtaria == null,
                      onTap: _abrirFaixaEtaria,
                    ),
                    const SizedBox(height: 24),
                    _SecaoFotos(
                      fotos: _fotos,
                      onAdicionar: _adicionarFotos,
                      onRemover: (id) => setState(() => _fotos.remove(id)),
                    ),
                    const SizedBox(height: 24),
                    const _CardAmbienteSeguro(),
                    const SizedBox(height: 16),
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
// Componentes
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

class _LabelOpcional extends StatelessWidget {
  const _LabelOpcional({required this.label, required this.opcional});
  final String label;
  final bool opcional;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        children: [
          if (opcional)
            const TextSpan(
              text: ' (opcional)',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _LabelComContador extends StatelessWidget {
  const _LabelComContador({
    required this.label,
    required this.atual,
    required this.maximo,
  });

  final String label;
  final int atual;
  final int maximo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$atual/$maximo',
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ChipsTema extends StatelessWidget {
  const _ChipsTema({required this.atual, required this.onSelect});
  final TemaPergunta? atual;
  final ValueChanged<TemaPergunta> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (final tema in TemaPergunta.values)
          _ChipTema(
            tema: tema,
            ativo: tema == atual,
            onTap: () => onSelect(tema),
          ),
      ],
    );
  }
}

class _ChipTema extends StatelessWidget {
  const _ChipTema({required this.tema, required this.ativo, required this.onTap});
  final TemaPergunta tema;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final emoji = tema.emoji;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: ativo ? AppColors.primary : const Color(0xFFE5E7EB),
            width: ativo ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null)
              Text(emoji, style: const TextStyle(fontSize: 14))
            else
              const Icon(Icons.add, size: 14, color: Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              tema.rotulo,
              style: TextStyle(
                color: ativo ? AppColors.primary : const Color(0xFF1F2937),
                fontSize: 13,
                fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
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
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final int? maxLength;

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
        maxLength: maxLength,
        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          border: InputBorder.none,
          isDense: true,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
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

class _SecaoFotos extends StatelessWidget {
  const _SecaoFotos({
    required this.fotos,
    required this.onAdicionar,
    required this.onRemover,
  });

  final List<String> fotos;
  final VoidCallback onAdicionar;
  final ValueChanged<String> onRemover;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onAdicionar,
          borderRadius: BorderRadius.circular(12),
          child: const DottedSquare(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera_outlined,
                    size: 22, color: Color(0xFF6B7280)),
                SizedBox(height: 4),
                Text(
                  'FOTOS',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Adicione fotos, (opcional)',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class DottedSquare extends StatelessWidget {
  const DottedSquare({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9CA3AF),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: child,
    );
  }
}

class _CardAmbienteSeguro extends StatelessWidget {
  const _CardAmbienteSeguro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined,
              size: 20, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ambiente seguro e acolhedor',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Respeito e empatia sempre. Perguntas que desrespeitam nossas regras podem ser removidas.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              size: 20, color: Color(0xFF9CA3AF)),
        ],
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
                  Text('Pedir ajuda à comunidade'),
                  SizedBox(width: 8),
                  Text('💛', style: TextStyle(fontSize: 18)),
                ],
              ),
      ),
    );
  }
}
