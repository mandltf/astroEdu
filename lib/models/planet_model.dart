class PlanetModel {
  final String id;
  final String name;
  final String emoji;
  final int color;
  final int moons;
  final String description;
  final String shortDesc;
  final List<String> facts;
  final String apiId;
  
  Map<String, dynamic>? wikiData;

  PlanetModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.moons,
    required this.description,
    required this.shortDesc,
    required this.facts,
    required this.apiId,
    this.wikiData,
  });
}