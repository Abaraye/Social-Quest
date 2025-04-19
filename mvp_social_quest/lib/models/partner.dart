// lib/models/partner.dart

class Partner {
  final String id;
  final String name;
  final String description;
  final Map<String, List<String>> slots;
  final String category;
  final double latitude;
  final double longitude;

  Partner({
    required this.id,
    required this.name,
    required this.description,
    required this.slots,
    required this.category,
    required this.latitude,
    required this.longitude,
  });

  factory Partner.fromMap(Map<String, dynamic> data, String id) {
    return Partner(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      slots: Map<String, List<String>>.from(
        (data['slots'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'slots': slots,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  int get maxReduction {
    final regex = RegExp(r'(\d+)%');
    int max = 0;
    for (var slotReductions in slots.values) {
      for (var reduction in slotReductions) {
        final match = regex.firstMatch(reduction);
        if (match != null) {
          final value = int.tryParse(match.group(1)!);
          if (value != null && value > max) {
            max = value;
          }
        }
      }
    }
    return max;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    category: json['category'],
    slots:
        {}, // Slots non inclus pour simplification (hors scope du JSON basique)
    latitude: (json['latitude'] ?? 0.0).toDouble(),
    longitude: (json['longitude'] ?? 0.0).toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Partner && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
