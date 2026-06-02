import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/home_models.dart';

/// Tela "Home - primeiro acesso" — replica o frame do Figma para usuárias
/// que ainda não interagiram com a comunidade.
class HomeFirstAccessPage extends StatelessWidget {
  const HomeFirstAccessPage({super.key, required this.dados});
  final HomeData dados;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F7F8),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Center(child: _IlustracaoBemvinda()),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Bem-vinda à Maternow!',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Comece explorando a comunidade ou anuncie algo que seu pequeno não usa mais. Estamos felizes em ter você aqui!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/community'),
            child: const Text('Explorar Comunidade'),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(
                child: _CardDestaque(
                  cor: Color(0xFFEDE7F8),
                  icone: Icons.shield_outlined,
                  corIcone: Color(0xFF6552B4),
                  titulo: 'Segurança',
                  texto: 'Comunidade feita por\ne para mães.',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _CardDestaque(
                  cor: Color(0xFFD9F0E2),
                  icone: Icons.eco_outlined,
                  corIcone: Color(0xFF2EAE7A),
                  titulo: 'Sustentável',
                  texto: 'Passe adiante o que\nnão serve mais.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IlustracaoBemvinda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder estilizado: círculo com gradiente em tom rosado e o emoji
    // representando mãe e bebê. Mantém a paleta da arte original do Figma.
    return Container(
      width: 192,
      height: 192,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFAD7C8), Color(0xFFF5BFB1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: Colors.white, width: 6),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text('👩‍🍼', style: TextStyle(fontSize: 90)),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              width: 36,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFF7B500),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.favorite, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDestaque extends StatelessWidget {
  const _CardDestaque({
    required this.cor,
    required this.icone,
    required this.corIcone,
    required this.titulo,
    required this.texto,
  });

  final Color cor;
  final IconData icone;
  final Color corIcone;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: corIcone, size: 18),
              const SizedBox(width: 8),
              Text(titulo,
                  style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(texto, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }
}
