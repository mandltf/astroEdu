class GerhanaModel {
  final String id;
  final String name;
  final String emoji;
  final int color;
  final String shortDesc;
  final String description;
  final String duration;
  final String frequency;
  final String safety;
  final List<String> facts;
  Map<String, dynamic>? wikiData;

  GerhanaModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.shortDesc,
    required this.description,
    required this.duration,
    required this.frequency,
    required this.safety,
    required this.facts,
    this.wikiData,
  });
}