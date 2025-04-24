/// Modèle de réduction appliquée à un slot
class Reduction {
  /// Pourcentage de réduction (ex: 20 pour 20%)
  final int amount;

  /// Taille minimale du groupe pour bénéficier de la réduction
  final int groupSize;

  const Reduction({required this.amount, required this.groupSize});

  /// Crée une instance depuis une map (par exemple depuis Firestore)
  factory Reduction.fromMap(Map<String, dynamic> map) {
    return Reduction(
      amount: (map['amount'] as num).toInt(),
      groupSize: (map['groupSize'] as num).toInt(),
    );
  }

  /// Convertit l'objet en map pour l'enregistrement (Firestore, JSON, ...)
  Map<String, dynamic> toMap() {
    return {'amount': amount, 'groupSize': groupSize};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reduction &&
        other.amount == amount &&
        other.groupSize == groupSize;
  }

  @override
  int get hashCode => amount.hashCode ^ groupSize.hashCode;

  @override
  String toString() => 'Reduction(amount: \$amount, groupSize: \$groupSize)';
}
