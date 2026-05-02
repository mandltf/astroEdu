class GalaksiModel {
  final String id;
  final String name;
  final String emoji;
  final int color;
  final String shortDesc;
  final String description;
  final String type;
  final String stars;
  final List<String> facts;
  
  Map<String, dynamic>? wikiData;

  GalaksiModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.shortDesc,
    required this.description,
    required this.type,
    required this.stars,
    required this.facts,
    this.wikiData,
  });
}