/// Catálogo de identificadores de avatar suportados pelo app.
class AvatarCatalog {
  AvatarCatalog._();

  // Animais — emojis fofos para a tela "Escolher o mais fofo"
  static const animais = [
    (id: 'animal_urso', emoji: '🐻'),
    (id: 'animal_coelho', emoji: '🐰'),
    (id: 'animal_tigre', emoji: '🐯'),
    (id: 'animal_coala', emoji: '🐨'),
    (id: 'animal_raposa', emoji: '🦊'),
    (id: 'animal_gato', emoji: '🐱'),
    (id: 'animal_girafa', emoji: '🦒'),
    (id: 'animal_leao', emoji: '🦁'),
    (id: 'animal_passarinho', emoji: '🐤'),
  ];

  // Pessoas — emojis variados representando "Quem é você aqui?"
  static const pessoas = [
    (id: 'pessoa_1', emoji: '👩'),
    (id: 'pessoa_2', emoji: '👩‍🦱'),
    (id: 'pessoa_3', emoji: '👱‍♀️'),
    (id: 'pessoa_4', emoji: '👩🏾‍🦱'),
    (id: 'pessoa_5', emoji: '👩🏽'),
    (id: 'pessoa_6', emoji: '👩🏿'),
    (id: 'pessoa_7', emoji: '👩‍🦰'),
    (id: 'pessoa_8', emoji: '🧕'),
    (id: 'pessoa_9', emoji: '👱🏼‍♀️'),
  ];

  /// Resolve o emoji a partir de um id, vazio se não encontrado.
  static String emoji(String? id) {
    if (id == null) return '';
    for (final a in animais) {
      if (a.id == id) return a.emoji;
    }
    for (final p in pessoas) {
      if (p.id == id) return p.emoji;
    }
    return '';
  }
}
