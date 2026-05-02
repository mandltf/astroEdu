class PlanetModel {
  final String id;
  final String name;
  final String emoji;
  final int color;
  final String distance;
  final String diameter;
  final int moons;
  final String description;
  final String shortDesc;
  final List<String> facts;
  final String apiId;
  
  final String? mass;
  final String? gravity;
  final String? temperature;
  
  Map<String, dynamic>? wikiData;

  PlanetModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.distance,
    required this.diameter,
    required this.moons,
    required this.description,
    required this.shortDesc,
    required this.facts,
    required this.apiId,
    this.mass,
    this.gravity,
    this.temperature,
    this.wikiData,
  });

  factory PlanetModel.fromJson(Map<String, dynamic> json) {
    return PlanetModel(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      color: json['color'],
      distance: json['distance'],
      diameter: json['diameter'],
      moons: json['moons'] ?? 0,
      description: json['description'],
      shortDesc: json['shortDesc'],
      facts: List<String>.from(json['facts']),
      apiId: json['api_id'],
      mass: json['mass'],
      gravity: json['gravity'],
      temperature: json['temperature'],
      wikiData: json['wiki_data'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'color': color,
    'distance': distance,
    'diameter': diameter,
    'moons': moons,
    'description': description,
    'shortDesc': shortDesc,
    'facts': facts,
    'api_id': apiId,
    'mass': mass,
    'gravity': gravity,
    'temperature': temperature,
    'wiki_data': wikiData,
  };
}