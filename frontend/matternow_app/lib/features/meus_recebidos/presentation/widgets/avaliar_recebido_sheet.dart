import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/recebido_models.dart';

/// Bottom sheet "Hora de avaliar sua experiência". Permite escolher um
/// estado do produto e marcar se a indicação ajudou. Devolve um
/// [AvaliacaoRecebido] quando o usuário confirma.
class AvaliarRecebidoSheet extends StatefulWidget {
  const AvaliarRecebidoSheet({super.key, required this.recebido});

  final Recebido recebido;

  /// Apresenta o bottom sheet em modal e devolve a avaliação preenchida ou
  /// `null` quando o usuário cancela.
  static Future<AvaliacaoRecebido?> mostrar(
    BuildContext context, {
    required Recebido recebido,
  }) {
    return showModalBottomSheet<AvaliacaoRecebido>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AvaliarRecebidoSheet(recebido: recebido),
    );
  }

  @override
  State<AvaliarRecebidoSheet> createState() => _AvaliarRecebidoSheetState();
}

class _AvaliarRecebidoSheetState extends State<AvaliarRecebidoSheet> {
  EstadoAvaliacao? _estado;
  bool _ajudou = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Hora de avaliar sua experiência',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close,
                      size: 20, color: Color(0xFF6B7280)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ItemAvaliado(recebido: widget.recebido),
            const SizedBox(height: 24),
            const Text(
              'Como está o produto?',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _ChipsEstado(
              atual: _estado,
              onSelect: (e) => setState(() => _estado = e),
            ),
            const SizedBox(height: 20),
            _ToggleAjudou(
              ativo: _ajudou,
              onChanged: (v) => setState(() => _ajudou = v),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _estado == null
                    ? null
                    : () => Navigator.of(context).pop(
                          AvaliacaoRecebido(
                            estado: _estado!,
                            marcouAjudou: _ajudou,
                          ),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFCBD5D6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999)),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                child: const Text('Concluir avaliação'),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemAvaliado extends StatelessWidget {
  const _ItemAvaliado({required this.recebido});
  final Recebido recebido;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF1F0),
              borderRadius: BorderRadius.circular(10),
              image: recebido.fotoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(recebido.fotoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: recebido.fotoUrl == null
                ? const Icon(Icons.image_outlined,
                    size: 22, color: Color(0xFF9CA3AF))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recebido.parceiroNome,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Já ajudou ${recebido.parceiroAjudouMaes} mães',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipsEstado extends StatelessWidget {
  const _ChipsEstado({required this.atual, required this.onSelect});
  final EstadoAvaliacao? atual;
  final ValueChanged<EstadoAvaliacao> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in EstadoAvaliacao.values)
          _ChipEstado(
            estado: e,
            ativo: e == atual,
            onTap: () => onSelect(e),
          ),
      ],
    );
  }
}

class _ChipEstado extends StatelessWidget {
  const _ChipEstado({
    required this.estado,
    required this.ativo,
    required this.onTap,
  });
  final EstadoAvaliacao estado;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: ativo ? const Color(0xFFEFF6F5) : Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: ativo ? AppColors.primary : const Color(0xFFE5E7EB),
            width: ativo ? 1.5 : 1,
          ),
        ),
        child: Text(
          estado.rotulo,
          style: TextStyle(
            color: ativo ? AppColors.primary : const Color(0xFF374151),
            fontSize: 13,
            fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ToggleAjudou extends StatelessWidget {
  const _ToggleAjudou({required this.ativo, required this.onChanged});
  final bool ativo;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCE2A6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4B0),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text('✨', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Isso me ajudou',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ao marcar, você ajuda a fortalecer a comunidade e incentiva outras mães!',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: ativo,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
