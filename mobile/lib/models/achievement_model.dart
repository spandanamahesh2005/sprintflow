class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.unlocked,
  });

  final int id;
  final String title;
  final String description;
  final bool unlocked;
}
