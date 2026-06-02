import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modal "Junte-se a outras mães" — replica o frame de convite do Figma.
/// Mostra título, mensagem padrão, botão "Copiar link" e atalhos sociais.
class InviteModal extends StatelessWidget {
  const InviteModal({
    super.key,
    this.linkConvite = 'https://maternow.app/convite',
    this.mensagem =
        'Encontrei um app incrível de mães que desapegam de itens infantis e trocam experiências maternais entre si',
  });

  final String linkConvite;
  final String mensagem;

  static Future<void> mostrar(BuildContext context, {String? linkConvite, String? mensagem}) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => InviteModal(
        linkConvite: linkConvite ?? 'https://maternow.app/convite',
        mensagem: mensagem ??
            'Encontrei um app incrível de mães que desapegam de itens infantis e trocam experiências maternais entre si',
      ),
    );
  }

  Future<void> _copiarLink(BuildContext context) async {
    final texto = '$mensagem\n$linkConvite';
    await Clipboard.setData(ClipboardData(text: texto));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copiado!')),
    );
  }

  void _compartilhar(BuildContext context, String canal) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compartilhar via $canal em breve.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Junte-se a outras\nmães',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            _BotaoCopiarLink(onTap: () => _copiarLink(context)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BotaoSocial(
                  icone: Icons.facebook,
                  cor: const Color(0xFF1877F2),
                  rotulo: 'Facebook',
                  onTap: () => _compartilhar(context, 'Facebook'),
                ),
                _BotaoSocial(
                  icone: Icons.chat_bubble,
                  cor: const Color(0xFF25D366),
                  rotulo: 'Whatsapp',
                  onTap: () => _compartilhar(context, 'Whatsapp'),
                ),
                _BotaoSocial(
                  icone: Icons.camera_alt,
                  // Gradiente completo do Instagram exigiria pintura customizada;
                  // o tom rosa-cinza fica próximo o suficiente do design.
                  cor: const Color(0xFFE1306C),
                  rotulo: 'Instagram',
                  onTap: () => _compartilhar(context, 'Instagram'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BotaoCopiarLink extends StatelessWidget {
  const _BotaoCopiarLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link, size: 18, color: Color(0xFF6B7280)),
              SizedBox(width: 10),
              Text(
                'Copiar link',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotaoSocial extends StatelessWidget {
  const _BotaoSocial({
    required this.icone,
    required this.cor,
    required this.rotulo,
    required this.onTap,
  });
  final IconData icone;
  final Color cor;
  final String rotulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(icone, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              rotulo,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
