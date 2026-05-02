class RasiModel {
  final String id;
  final String name;
  final String emoji;
  final int color;
  final String shortDesc;
  final String description;
  final String bestTime;
  final int stars;
  final List<String> facts;
  Map<String, dynamic>? wikiData;

  RasiModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.shortDesc,
    required this.description,
    required this.bestTime,
    required this.stars,
    required this.facts,
    this.wikiData,
  });
}