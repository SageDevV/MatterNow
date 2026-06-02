import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'widgets/avatar_catalog.dart';

/// Categorias de avatar suportadas — replicam os frames "Avatar" do Figma.
enum AvatarCategoria { animais, pessoas }

/// Tela genérica de seleção de avatar. Replica os frames "Quem é você aqui?"
/// (pessoas) e "Escolher o mais fofo" (animais). Recebe a categoria via
/// `arguments` da rota.
class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key, required this.categoria, this.selecionadoInicial});

  final AvatarCategoria categoria;
  final String? selecionadoInicial;

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  static const _alturaCabecalho = 80.0;
  String? _selecionado;

  @override
  void initState() {
    super.initState();
    _selecionado = widget.selecionadoInicial;
  }

  List<({String id, String emoji})> get _opcoes => widget.categoria == AvatarCategoria.animais
      ? AvatarCatalog.animais
      : AvatarCatalog.pessoas;

  String get _titulo => 'Avatar';
  String get _subtitulo => widget.categoria == AvatarCategoria.animais
      ? 'Escolher o mais fofo'
      : 'Quem é você aqui?';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Cabecalho(altura: _alturaCabecalho, titulo: _titulo, onVoltar: () => Navigator.of(context).pop()),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(21, 24, 21, 16),
                child: Column(
                  children: [
                    Text(
                      _subtitulo,
                      style: const TextStyle(color: AppColors.text, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: _opcoes.length,
                        itemBuilder: (context, i) {
                          final opcao = _opcoes[i];
                          final selecionado = opcao.id == _selecionado;
                          return _AvatarCard(
                            emoji: opcao.emoji,
                            selecionado: selecionado,
                            onTap: () => setState(() => _selecionado = opcao.id),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _selecionado == null
                          ? null
                          : () => Navigator.of(context).pop(_selecionado),
                      child: const Text('Confirmar'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.primaryDark, fontSize: 12),
                      ),
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

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.emoji, required this.selecionado, required this.onTap});
  final String emoji;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selecionado ? AppColors.primary : AppColors.border.withValues(alpha: 0.3),
                width: selecionado ? 1.5 : 0.5,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 48)),
          ),
          if (selecionado)
            const Positioned(
              top: 6,
              right: 6,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Color(0xFF2EAE7A),
                child: Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.altura, required this.titulo, required this.onVoltar});
  final double altura;
  final String titulo;
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
          Text(titulo,
              style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: -0.42)),
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
