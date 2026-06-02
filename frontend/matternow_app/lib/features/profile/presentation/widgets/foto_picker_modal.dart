import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../avatar_page.dart';

/// Resultado retornado pelo modal de seleção de foto.
sealed class FotoEscolha {
  const FotoEscolha();
}

class FotoCamera extends FotoEscolha {
  const FotoCamera();
}

class FotoGaleria extends FotoEscolha {
  const FotoGaleria();
}

class FotoAvatar extends FotoEscolha {
  const FotoAvatar(this.avatarId);
  final String avatarId;
}

/// Bottom-sheet "Adicionar foto" — replica o frame "Adicionar foto" do Figma.
class FotoPickerModal {
  FotoPickerModal._();

  static Future<FotoEscolha?> mostrar(BuildContext context) {
    return showModalBottomSheet<FotoEscolha>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const _Conteudo(),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo();

  Future<void> _abrirAvatar(BuildContext context) async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const AvatarPage(categoria: AvatarCategoria.animais),
      ),
    );
    if (!context.mounted) return;
    if (id != null) Navigator.of(context).pop(FotoAvatar(id));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Adicionar foto',
                  style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              _Opcao(
                emoji: '📷',
                texto: 'Tirar foto',
                onTap: () => Navigator.of(context).pop(const FotoCamera()),
              ),
              const SizedBox(height: 12),
              _Opcao(
                emoji: '🖼️',
                texto: 'Escolher da galeria',
                onTap: () => Navigator.of(context).pop(const FotoGaleria()),
              ),
              const SizedBox(height: 12),
              _Opcao(
                emoji: '🐻',
                texto: 'Escolher avatar',
                onTap: () => _abrirAvatar(context),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.primaryDark, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Opcao extends StatelessWidget {
  const _Opcao({required this.emoji, required this.texto, required this.onTap});
  final String emoji;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.3), width: 0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(color: AppColors.text, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
