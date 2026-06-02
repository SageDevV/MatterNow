import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/community_models.dart';

/// Estados vazios da Comunidade — replica os três frames ilustrados do Figma:
/// • Geral / Vendas / Doações: cesta com balão de coração + "Anunciar item"
/// • Perguntas: ícone de interrogação em halo laranja + "Fazer uma pergunta"
/// • Indicações: lâmpada + box "INSPIRAÇÃO" + "Compartilhar dica"
class CommunityEmptyState extends StatelessWidget {
  const CommunityEmptyState({
    super.key,
    required this.categoria,
    required this.onAnunciar,
  });

  final CategoriaComunidade categoria;
  final VoidCallback onAnunciar;

  _ConteudoVazio get _conteudo {
    switch (categoria) {
      case CategoriaComunidade.todas:
      case CategoriaComunidade.vendas:
      case CategoriaComunidade.doacoes:
        return const _ConteudoVazio(
          ilustracao: _IlustracaoCesta(),
          titulo: 'Ainda não há desapegos\npor aqui',
          subtitulo:
              'Que tal ser a primeira a postar um item que seu pequeno não usa mais e ajudar outra mãe?',
          rotuloBotao: 'Anunciar item',
          iconeBotao: Icons.add_circle_outline,
          inspiracao: null,
        );
      case CategoriaComunidade.perguntas:
        return const _ConteudoVazio(
          ilustracao: _IlustracaoInterrogacao(),
          titulo: 'Ainda não há perguntas por aqui',
          subtitulo:
              'Que tal ser a primeira a tirar uma dúvida ou pedir um conselho para outras mães?',
          rotuloBotao: 'Fazer uma pergunta',
          iconeBotao: Icons.add_circle_outline,
          inspiracao: null,
        );
      case CategoriaComunidade.indicacoes:
        return const _ConteudoVazio(
          ilustracao: _IlustracaoLampada(),
          titulo: 'Ainda não há dicas por aqui',
          subtitulo:
              'Que tal compartilhar um segredinho ou uma experiência que ajudou você na maternidade?',
          rotuloBotao: 'Compartilhar dica',
          iconeBotao: Icons.add_circle_outline,
          inspiracao:
              '"Sua experiência pode ser a luz que outra mãe precisa hoje."',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _conteudo;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        children: [
          c.ilustracao,
          const SizedBox(height: 32),
          Text(
            c.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 28 / 24,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            c.subtitulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 32),
          _BotaoAcao(
            rotulo: c.rotuloBotao,
            icone: c.iconeBotao,
            onTap: onAnunciar,
          ),
          if (c.inspiracao != null) ...[
            const SizedBox(height: 24),
            _CaixaInspiracao(texto: c.inspiracao!),
          ],
        ],
      ),
    );
  }
}

class _ConteudoVazio {
  final Widget ilustracao;
  final String titulo;
  final String subtitulo;
  final String rotuloBotao;
  final IconData iconeBotao;
  final String? inspiracao;

  const _ConteudoVazio({
    required this.ilustracao,
    required this.titulo,
    required this.subtitulo,
    required this.rotuloBotao,
    required this.iconeBotao,
    required this.inspiracao,
  });
}

class _BotaoAcao extends StatelessWidget {
  const _BotaoAcao({required this.rotulo, required this.icone, required this.onTap});
  final String rotulo;
  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              rotulo,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 24 / 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaixaInspiracao extends StatelessWidget {
  const _CaixaInspiracao({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8E2),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('✨', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'INSPIRAÇÃO',
                style: TextStyle(
                  color: Color(0xFFD97706),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------- Ilustrações ---------------------------------
//
// O Figma usa imagens vetoriais para as três ilustrações. Para evitar adicionar
// novos assets nesta etapa, replicamos a essência visual com primitives nativas
// (ícones + camadas de halo), preservando proporções e cores do design.

class _IlustracaoCesta extends StatelessWidget {
  const _IlustracaoCesta();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      height: 192,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Balão de coração com cordinha.
          Positioned(
            top: 8,
            child: Column(
              children: [
                const Icon(
                  Icons.favorite,
                  size: 56,
                  color: Color(0xFFF8B6B6),
                ),
                Container(
                  width: 1,
                  height: 64,
                  color: const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
          // Cesta estilizada.
          Positioned(
            bottom: 8,
            child: Container(
              width: 168,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEAE3D2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border.all(color: const Color(0xFFA8B89A), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IlustracaoInterrogacao extends StatelessWidget {
  const _IlustracaoInterrogacao();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      height: 192,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
            ),
          ),
          Container(
            width: 144,
            height: 144,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                '?',
                style: TextStyle(
                  color: Color(0xFFD97706),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IlustracaoLampada extends StatelessWidget {
  const _IlustracaoLampada();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Center(
        child: Icon(
          Icons.lightbulb_outline,
          size: 64,
          color: AppColors.text.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
