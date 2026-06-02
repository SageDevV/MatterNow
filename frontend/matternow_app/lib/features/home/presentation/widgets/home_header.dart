import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Cabeçalho verde da home — replica o frame com saudação ou título central.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.altura,
    this.saudacao,
    this.titulo,
    this.onVoltar,
    this.notificacoes = 0,
    this.onConfig,
    this.onNotificacoes,
  });

  final double altura;
  final String? saudacao;
  final String? titulo;
  final VoidCallback? onVoltar;
  final int notificacoes;
  final VoidCallback? onConfig;
  final VoidCallback? onNotificacoes;

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: altura + paddingTop,
      padding: EdgeInsets.fromLTRB(0, paddingTop, 0, 0),
      color: AppColors.primary,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (titulo != null)
            Text(
              titulo!,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            )
          else if (saudacao != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  saudacao!,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          if (onVoltar != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onVoltar,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onConfig,
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: onNotificacoes,
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      ),
                      if (notificacoes > 0)
                        const Positioned(
                          top: 10,
                          right: 8,
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
