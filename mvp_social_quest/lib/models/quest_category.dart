enum QuestCategory { sport, food, culture, nature, game, relaxation, workshop }

extension QuestCategoryExtension on QuestCategory {
  String get label {
    switch (this) {
      case QuestCategory.sport:
        return 'Sport';
      case QuestCategory.food:
        return 'Gastronomie';
      case QuestCategory.culture:
        return 'Culture';
      case QuestCategory.nature:
        return 'Nature';
      case QuestCategory.game:
        return 'Jeux';
      case QuestCategory.relaxation:
        return 'Détente';
      case QuestCategory.workshop:
        return 'Atelier';
    }
  }
}
