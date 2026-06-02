import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/home_header.dart';

/// Tela "Galeria de fotos" — replica o frame multi-seleção do Figma.
/// Por enquanto usa placeholders (cinza) com badge numerado mostrando a ordem
/// da seleção. Quando integrarmos com `image_picker`/`photo_manager`, basta
/// trocar [_imagens] por uma lista real.
class GaleriaFotosPage extends StatefulWidget {
  const GaleriaFotosPage({
    super.key,
    this.maxSelecao = 8,
    this.jaSelecionadas = const [],
  });

  /// Limite máximo de fotos selecionáveis (no Figma o anúncio aceita 0/8).
  final int maxSelecao;

  /// Caminhos já presentes na seleção; pré-marca esses índices.
  final List<String> jaSelecionadas;

  @override
  State<GaleriaFotosPage> createState() => _GaleriaFotosPageState();
}

class _GaleriaFotosPageState extends State<GaleriaFotosPage> {
  // Em produção isso vem do device. Aqui uso ids estáveis de placeholders
  // para manter a posição das seleções.
  final List<String> _imagens = List.generate(
    15,
    (i) => 'placeholder://galeria/${i + 1}',
  );

  late List<String> _selecao;

  @override
  void initState() {
    super.initState();
    _selecao = [...widget.jaSelecionadas];
  }

  void _toggle(String id) {
    setState(() {
      if (_selecao.contains(id)) {
        _selecao.remove(id);
      } else if (_selecao.length < widget.maxSelecao) {
        _selecao.add(id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Máximo de ${widget.maxSelecao} fotos.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          HomeHeader(
            altura: 60,
            titulo: 'Galeria de fotos',
            onVoltar: () => Navigator.of(context).maybePop(),
            notificacoes: 0,
            onConfig: () {},
            onNotificacoes: () {},
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: _imagens.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, i) {
                final id = _imagens[i];
                final indice = _selecao.indexOf(id);
                final selecionada = indice >= 0;
                return _ItemFoto(
                  selecionada: selecionada,
                  ordem: selecionada ? indice + 1 : null,
                  onTap: () => _toggle(id),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: _selecao.isEmpty
                          ? null
                          : () => Navigator.of(context).pop(_selecao),
                      child: const Text('Confirmar'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

class _ItemFoto extends StatelessWidget {
  const _ItemFoto({required this.selecionada, required this.ordem, required this.onTap});
  final bool selecionada;
  final int? ordem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(8),
              border: selecionada
                  ? Border.all(color: AppColors.primary, width: 3)
                  : null,
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, size: 28, color: Color(0xFF6B7280)),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _Badge(selecionada: selecionada, ordem: ordem),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.selecionada, this.ordem});
  final bool selecionada;
  final int? ordem;

  @override
  Widget build(BuildContext context) {
    if (selecionada) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$ordem',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
    );
  }
}
