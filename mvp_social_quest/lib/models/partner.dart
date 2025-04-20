class Partner {
  final String id;
  final String name;
  final String description;
  final Map<String, List<Map<String, dynamic>>> slots;
  final String category;
  final double latitude;
  final double longitude;
  final int? maxReduction; // ← optionnel : peut être calculé ou défini

  Partner({
    required this.id,
    required this.name,
    required this.description,
    required this.slots,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.maxReduction,
  });

  /// 🔄 Conversion depuis un format JSON (ex: stockage local, SharedPreferences)
  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      maxReduction: json['maxReduction'],
      slots: {}, // ⚠️ Les slots ne sont pas chargés pour les favoris
    );
  }

  /// 🔄 Conversion vers un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'maxReduction': maxReduction,
    };
  }

  /// 🔄 Construction depuis une Map Firestore + id
  factory Partner.fromMap(Map<String, dynamic> data, String id) {
    final rawSlots = data['slots'] ?? {};
    final parsedSlots = <String, List<Map<String, dynamic>>>{};

    for (final entry in rawSlots.entries) {
      parsedSlots[entry.key] = List<Map<String, dynamic>>.from(
        entry.value ?? [],
      );
    }

    return Partner(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      slots: parsedSlots,
      maxReduction: data['maxReduction'],
    );
  }

  /// 🧠 Calcul de la plus grosse réduction dans les créneaux
  int get computedMaxReduction {
    int max = 0;
    for (final reductions in slots.values) {
      for (final reduction in reductions) {
        final val = reduction['amount'];
        if (val is int && val > max) max = val;
      }
    }
    return max;
  }

  /// 🔁 Conversion vers une Map Firestore (utile pour update)
  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'slots': slots,
    'maxReduction': maxReduction ?? computedMaxReduction,
  };

  /// 🖼 Valeur à afficher dans les cards
  int get maxReductionDisplay => maxReduction ?? computedMaxReduction;

  /// 🔁 Égalité personnalisée pour pouvoir gérer les favoris
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Partner && other.id == id);

  @override
  int get hashCode => id.hashCode;

  /// ✅ Helper : vérifie s’il y a au moins un créneau à venir (future ou maintenant)
  bool get hasUpcomingSlot {
    final now = DateTime.now();
    return slots.values.any(
      (reductions) => reductions.any(
        (r) => r['startTime'] is DateTime && r['startTime'].isAfter(now),
      ),
    );
  }

  /// ✅ Helper : validation minimale du partenaire
  bool get isValid {
    return name.isNotEmpty &&
        description.isNotEmpty &&
        latitude != 0 &&
        longitude != 0;
  }
}
