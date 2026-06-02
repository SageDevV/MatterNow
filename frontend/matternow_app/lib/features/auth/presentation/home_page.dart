import 'package:flutter/material.dart';

import '../data/auth_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.authRepository});
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MatterNow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await authRepository.sair();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/auth-choice', (_) => false);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>?>(
        future: authRepository.usuarioCorrente(),
        builder: (context, snapshot) {
          final usuario = snapshot.data;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Bem-vindo${usuario == null ? "" : ", ${usuario["nome"]}"}!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  if (usuario != null) ...[
                    const SizedBox(height: 8),
                    Text(usuario['email'] ?? '', style: const TextStyle(fontSize: 12)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/profile'),
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Meu cadastro'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/children'),
                    icon: const Icon(Icons.child_care_outlined),
                    label: const Text('Meus filhos'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
