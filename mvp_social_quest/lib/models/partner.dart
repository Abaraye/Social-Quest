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
    slots: {}, // Les slots ne sont pas restaurés ici (hors portée MVP)
    category: json['category'],
    latitude: json['latitude'],
    longitude: json['longitude'],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Partner && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
