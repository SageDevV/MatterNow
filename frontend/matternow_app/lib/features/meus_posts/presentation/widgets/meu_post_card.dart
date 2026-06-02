import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/data/home_models.dart';
import '../../data/meu_post_models.dart';

/// Card de um post do usuário — replica o design do Figma "Card: Pergunta"
/// com:
/// - Thumbnail com badge de tipo sobreposto no canto
/// - Título, autor (avatar + nome), tempo relativo
/// - Métricas (views/curtidas/comentários)
/// - Banner interno opcional (ex.: "Sua dica ajudou 18 mães...")
/// - Cartela lateral "AJUDOU N MÃES" para resolvidos
/// - Estado RESOLVIDO com pílula verde
class MeuPostCard extends StatelessWidget {
  const MeuPostCard({
    super.key,
    required this.post,
    this.onMarcarResolvido,
    this.onAcoes,
    this.onTap,
  });

  final MeuPost post;
  final VoidCallback? onMarcarResolvido;
  final VoidCallback? onAcoes;
  final VoidCallback? onTap;

  // ----------------------- estilo do badge -----------------------
  ({Color fundo, Color texto, String rotulo, IconData? icone}) get _visual {
    switch (post.tipo) {
      case TipoAnuncio.venda:
        return (
          fundo: const Color(0xFFD1FAE5),
          texto: const Color(0xFF059669),
          rotulo: 'VENDA',
          icone: Icons.shopping_bag_outlined,
        );
      case TipoAnuncio.doacao:
        return (
          fundo: const Color(0xFFFCE7F3),
          texto: const Color(0xFFDB2777),
          rotulo: 'DOAÇÃO',
          icone: Icons.shopping_bag_outlined,
        );
      case TipoAnuncio.pergunta:
        return (
          fundo: const Color(0xFFEDE9FE),
          texto: const Color(0xFF7C3AED),
          rotulo: 'PERGUNTA',
          icone: null,
        );
      case TipoAnuncio.dica:
        return (
          fundo: const Color(0xFFFEF3C7),
          texto: const Color(0xFFD97706),
          rotulo: 'DICA',
          icone: Icons.lightbulb_outline,
        );
      case TipoAnuncio.outro:
        return (
          fundo: const Color(0xFFE5E7EB),
          texto: const Color(0xFF374151),
          rotulo: 'POST',
          icone: Icons.image_outlined,
        );
    }
  }

  String _tempoRelativo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 7) return 'há ${diff.inDays} dias';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8E2), width: 1),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Thumbnail(
                      fotoUrl: post.fotoUrl,
                      placeholder: v.icone,
                      badgeRotulo: v.rotulo,
                      badgeFundo: v.fundo,
                      badgeTexto: v.texto,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _Conteudo(
                        post: post,
                        tempoRelativo: _tempoRelativo(post.criadoEm),
                        onAcoes: onAcoes,
                      ),
                    ),
                    if (post.resolvido && post.ajudouMaes > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: _CartelaAjudou(qtd: post.ajudouMaes),
                      ),
                  ],
                ),
              ),
              if (post.bannerInterno != null) ...[
                const SizedBox(height: 12),
                _BannerInterno(texto: post.bannerInterno!),
              ],
              const SizedBox(height: 10),
              _Metricas(
                visualizacoes: post.visualizacoes,
                curtidas: post.curtidas,
                comentarios: post.comentarios,
              ),
              if (!post.resolvido && onMarcarResolvido != null) ...[
                const SizedBox(height: 10),
                _BotaoResolver(onTap: onMarcarResolvido!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.fotoUrl,
    required this.placeholder,
    required this.badgeRotulo,
    required this.badgeFundo,
    required this.badgeTexto,
  });
  final String? fotoUrl;
  final IconData? placeholder;
  final String badgeRotulo;
  final Color badgeFundo;
  final Color badgeTexto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              image: fotoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(fotoUrl!), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: fotoUrl == null && placeholder != null
                ? Icon(placeholder, size: 28, color: const Color(0xFF9CA3AF))
                : null,
          ),
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeFundo,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeRotulo,
                style: TextStyle(
                  color: badgeTexto,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({
    required this.post,
    required this.tempoRelativo,
    required this.onAcoes,
  });

  final MeuPost post;
  final String tempoRelativo;
  final VoidCallback? onAcoes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                post.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.32,
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (post.resolvido)
              const _BadgeResolvido()
            else if (onAcoes != null)
              InkWell(
                onTap: onAcoes,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.more_horiz,
                      size: 18, color: Color(0xFF6B7280)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        _LinhaAutor(
          autorNome: post.autorNome,
          avatarUrl: post.autorAvatarUrl,
          tempoRelativo: tempoRelativo,
        ),
      ],
    );
  }
}

class _LinhaAutor extends StatelessWidget {
  const _LinhaAutor({
    required this.autorNome,
    required this.avatarUrl,
    required this.tempoRelativo,
  });

  final String? autorNome;
  final String? avatarUrl;
  final String tempoRelativo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
            image: avatarUrl != null
                ? DecorationImage(
                    image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                : null,
          ),
          alignment: Alignment.center,
          child: avatarUrl == null
              ? const Icon(Icons.person, size: 10, color: Color(0xFF9CA3AF))
              : null,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            autorNome ?? 'Você',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          tempoRelativo,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
        ),
      ],
    );
  }
}

class _BadgeResolvido extends StatelessWidget {
  const _BadgeResolvido();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF059669)),
          SizedBox(width: 4),
          Text(
            'RESOLVIDO',
            style: TextStyle(
              color: Color(0xFF059669),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerInterno extends StatelessWidget {
  const _BannerInterno({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Text('💛', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: Color(0xFF0F766E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
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
        _ItemMetrica(
            icone: Icons.visibility_outlined, valor: _formatar(visualizacoes)),
        const SizedBox(width: 16),
        _ItemMetrica(
            icone: Icons.thumb_up_alt_outlined, valor: _formatar(curtidas)),
        const SizedBox(width: 16),
        _ItemMetrica(
            icone: Icons.chat_bubble_outline, valor: _formatar(comentarios)),
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

class _BotaoResolver extends StatelessWidget {
  const _BotaoResolver({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: const Text(
          'Marcar como resolvido',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CartelaAjudou extends StatelessWidget {
  const _CartelaAjudou({required this.qtd});
  final int qtd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'AJUDOU',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$qtd',
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            qtd == 1 ? 'MÃE' : 'MÃES',
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          const Icon(Icons.favorite, size: 12, color: Color(0xFFEF4444)),
        ],
      ),
    );
  }
}
