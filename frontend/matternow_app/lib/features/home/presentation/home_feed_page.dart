import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/home_models.dart';

/// Tela "Início" com conteúdo — replica o frame da home com quick actions,
/// cards da comunidade e recomendações.
class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key, required this.dados});
  final HomeData dados;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F7F8),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'O que você quer fazer hoje?',
              style: TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          const _QuickActions(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Na comunidade',
                  style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/community'),
                  child: const Row(
                    children: [
                      Text('Ver mais', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (dados.comunidade.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                'Quando alguém da comunidade postar, aparece aqui.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            )
          else
            for (final a in dados.comunidade.take(2))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _CardComunidade(anuncio: a),
              ),
          const SizedBox(height: 8),
          if (dados.recomendacoes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recomendações${dados.nomeFilhoFoco == null ? '' : ' para ${dados.nomeFilhoFoco}'}',
                style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 156,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: dados.recomendacoes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _CardProduto(anuncio: dados.recomendacoes[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const _acoes = [
    (emoji: '💰', label: 'Vender', rota: '/anunciar/vender'),
    (emoji: '🎁', label: 'Doar', rota: '/anunciar/doar'),
    (emoji: '💬', label: 'Perguntar', rota: '/anunciar/perguntar'),
    (emoji: '⭐', label: 'Dica de mãe', rota: '/anunciar/indicar'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < _acoes.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _BotaoAcao(
                emoji: _acoes[i].emoji,
                label: _acoes[i].label,
                rota: _acoes[i].rota,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BotaoAcao extends StatelessWidget {
  const _BotaoAcao({required this.emoji, required this.label, this.rota});
  final String emoji;
  final String label;
  final String? rota;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: rota == null
          ? () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label em breve.')),
              )
          : () => Navigator.of(context).pushNamed(rota!),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1))],
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _CardComunidade extends StatelessWidget {
  const _CardComunidade({required this.anuncio});
  final AnuncioFeed anuncio;

  Color get _corTag {
    switch (anuncio.tipo) {
      case TipoAnuncio.pergunta: return const Color(0xFFE8DBFF);
      case TipoAnuncio.venda: return const Color(0xFFD9F0E2);
      case TipoAnuncio.doacao: return const Color(0xFFFCE9C5);
      case TipoAnuncio.dica: return const Color(0xFFFCE9F2);
      default: return const Color(0xFFE5E5E5);
    }
  }

  Color get _corTextoTag {
    switch (anuncio.tipo) {
      case TipoAnuncio.pergunta: return const Color(0xFF6552B4);
      case TipoAnuncio.venda: return const Color(0xFF2EAE7A);
      case TipoAnuncio.doacao: return const Color(0xFFE39A23);
      case TipoAnuncio.dica: return const Color(0xFFC73E80);
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 1))],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: anuncio.tipo == TipoAnuncio.venda
                ? const Icon(Icons.image_outlined, color: AppColors.textMuted)
                : const SizedBox(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: _corTag, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        anuncio.tipoNome,
                        style: TextStyle(color: _corTextoTag, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Spacer(),
                    Text(_tempoRelativo(anuncio.criadoEm),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  anuncio.titulo,
                  style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w600, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const CircleAvatar(radius: 8, backgroundColor: Color(0xFFEFEFEF), child: Icon(Icons.person, size: 10)),
                    const SizedBox(width: 6),
                    Text(anuncio.autorNome ?? 'Anônimo',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Metrica(icone: Icons.visibility_outlined, valor: anuncio.visualizacoes),
                    const SizedBox(width: 12),
                    _Metrica(icone: Icons.thumb_up_alt_outlined, valor: anuncio.curtidas),
                    const SizedBox(width: 12),
                    _Metrica(icone: Icons.chat_bubble_outline, valor: anuncio.comentarios),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _tempoRelativo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 7) return 'há ${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({required this.icone, required this.valor});
  final IconData icone;
  final int valor;

  String _formatar(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(_formatar(valor), style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}

class _CardProduto extends StatelessWidget {
  const _CardProduto({required this.anuncio});
  final AnuncioFeed anuncio;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 110, height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
              ),
              Positioned(
                top: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border, size: 14, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(anuncio.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w600)),
          if (anuncio.valor != null)
            Text('R\$ ${anuncio.valor!.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
          if (anuncio.localizacao != null)
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 10, color: AppColors.textMuted),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(anuncio.localizacao!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
