import 'package:flutter/material.dart';

import '../../../home/data/home_models.dart';

/// Card de um anúncio da comunidade — replica o design do Figma:
/// thumbnail à esquerda, badge com tipo, título, autor, e métricas
/// (visualizações, curtidas, comentários).
class AnuncioCard extends StatelessWidget {
  const AnuncioCard({super.key, required this.anuncio});

  final AnuncioFeed anuncio;

  ({Color fundo, Color texto, IconData? iconePlaceholder}) get _visual {
    switch (anuncio.tipo) {
      case TipoAnuncio.pergunta:
        return (
          fundo: const Color(0xFFEDE9FE),
          texto: const Color(0xFF7C3AED),
          iconePlaceholder: null, // sem ícone no placeholder
        );
      case TipoAnuncio.venda:
        return (
          fundo: const Color(0xFFD1FAE5),
          texto: const Color(0xFF059669),
          iconePlaceholder: Icons.shopping_bag_outlined,
        );
      case TipoAnuncio.doacao:
        return (
          fundo: const Color(0xFFFCE7F3),
          texto: const Color(0xFFDB2777),
          iconePlaceholder: Icons.shopping_bag_outlined,
        );
      case TipoAnuncio.dica:
        return (
          fundo: const Color(0xFFFEF3C7),
          texto: const Color(0xFFD97706),
          iconePlaceholder: Icons.lightbulb_outline,
        );
      case TipoAnuncio.outro:
        return (
          fundo: const Color(0xFFE5E7EB),
          texto: const Color(0xFF374151),
          iconePlaceholder: Icons.image_outlined,
        );
    }
  }

  String get _rotuloTipo {
    if (anuncio.tipoNome.isNotEmpty) return anuncio.tipoNome.toUpperCase();
    switch (anuncio.tipo) {
      case TipoAnuncio.pergunta: return 'PERGUNTA';
      case TipoAnuncio.venda: return 'VENDA';
      case TipoAnuncio.doacao: return 'DOAÇÃO';
      case TipoAnuncio.dica: return 'DICA';
      case TipoAnuncio.outro: return 'POST';
    }
  }

  String _tempoRelativo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 7) return 'há ${diff.inDays}d';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8E2), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(
            fotoUrl: anuncio.fotoUrl,
            placeholder: v.iconePlaceholder,
          ),
          const SizedBox(width: 16),
          Expanded(child: _Conteudo(
            anuncio: anuncio,
            corBadgeFundo: v.fundo,
            corBadgeTexto: v.texto,
            rotuloTipo: _rotuloTipo,
            tempoRelativo: _tempoRelativo(anuncio.criadoEm),
          )),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.fotoUrl, required this.placeholder});
  final String? fotoUrl;
  final IconData? placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        image: fotoUrl != null
            ? DecorationImage(image: NetworkImage(fotoUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: fotoUrl == null && placeholder != null
          ? Icon(placeholder, size: 28, color: const Color(0xFF9CA3AF))
          : null,
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({
    required this.anuncio,
    required this.corBadgeFundo,
    required this.corBadgeTexto,
    required this.rotuloTipo,
    required this.tempoRelativo,
  });

  final AnuncioFeed anuncio;
  final Color corBadgeFundo;
  final Color corBadgeTexto;
  final String rotuloTipo;
  final String tempoRelativo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Badge(rotulo: rotuloTipo, fundo: corBadgeFundo, texto: corBadgeTexto),
            const Spacer(),
            Text(
              tempoRelativo,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          anuncio.titulo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.32,
          ),
        ),
        const SizedBox(height: 8),
        if ((anuncio.autorNome ?? '').isNotEmpty) _Autor(nome: anuncio.autorNome!),
        const SizedBox(height: 6),
        _Metricas(
          visualizacoes: anuncio.visualizacoes,
          curtidas: anuncio.curtidas,
          comentarios: anuncio.comentarios,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.rotulo, required this.fundo, required this.texto});
  final String rotulo;
  final Color fundo;
  final Color texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rotulo,
        style: TextStyle(
          color: texto,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _Autor extends StatelessWidget {
  const _Autor({required this.nome});
  final String nome;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.person, size: 10, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            nome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF374151), fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _Metricas extends StatelessWidget {
  const _Metricas({
    required this.visualizacoes,
    required this.curtidas,
    required this.comentarios,
  });
  final int visualizacoes;
  final int curtidas;
  final int comentarios;

  String _formatar(int v) {
    if (v >= 1000) {
      final s = (v / 1000).toStringAsFixed(1);
      return '${s.replaceAll(RegExp(r'\.0$'), '')}k';
    }
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ItemMetrica(icone: Icons.visibility_outlined, valor: _formatar(visualizacoes)),
        const SizedBox(width: 16),
        _ItemMetrica(icone: Icons.thumb_up_alt_outlined, valor: _formatar(curtidas)),
        const SizedBox(width: 16),
        _ItemMetrica(icone: Icons.chat_bubble_outline, valor: _formatar(comentarios)),
      ],
    );
  }
}

class _ItemMetrica extends StatelessWidget {
  const _ItemMetrica({required this.icone, required this.valor});
  final IconData icone;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 14, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text(
          valor,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
      ],
    );
  }
}
