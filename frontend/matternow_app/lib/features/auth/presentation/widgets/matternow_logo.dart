import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Logotipo "MATTER NOW" em duas linhas, replicando o design do Figma
/// (texto roxo gradiente, posicionamento centralizado).
class MatterNowLogo extends StatelessWidget {
  const MatterNowLogo({super.key, this.size = 1});

  final double size;

  @override
  Widget build(BuildContext context) {
    final fontSize = 44 * size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, Color(0xFF6B3FA0)],
          ).createShader(rect),
          child: Text(
            'MATTER',
            style: GoogleFonts.bangers(
              fontSize: fontSize,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B3FA0), AppColors.primaryDark],
          ).createShader(rect),
          child: Text(
            'NOW',
            style: GoogleFonts.bangers(
              fontSize: fontSize,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}
