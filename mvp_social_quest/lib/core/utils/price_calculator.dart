/// 💰 Utility helpers for pricing computations.
///
/// All operations are **cent-based** (integer) to avoid floating-point drift.
/// The calculator is deliberately small and pure so it can be unit-tested in
/// complete isolation.
class PriceCalculator {
  const PriceCalculator._(); // ⛔️ Prevent instantiation

  /// Returns the **net price** in **cents** after applying [reductionPercent].
  ///
  /// * [priceCents] – gross price in cents (e.g. `1999` → **19 € 99**).
  /// * [reductionPercent] – a value between **0** and **100**.
  ///
  /// The formula is:<br>
  /// `net = priceCents * (100 - reductionPercent) / 100`
  ///
  /// Rounding rules :
  /// * We round **to the nearest cent** (`half up`) to keep things fair.
  /// * A reduction of `0` % returns the original price.
  /// * A reduction of `100` % returns `0`.
  ///
  /// Throws [ArgumentError] if inputs are out of range.
  static int netPriceCents(int priceCents, int reductionPercent) {
    if (priceCents < 0) {
      throw ArgumentError.value(priceCents, 'priceCents', 'Must be positive');
    }
    if (reductionPercent < 0 || reductionPercent > 100) {
      throw ArgumentError.value(
        reductionPercent,
        'reductionPercent',
        'Must be between 0 and 100',
      );
    }

    // Multiplying first keeps integer precision before division.
    final raw = priceCents * (100 - reductionPercent);

    // Add 50 before integer division by 100 to achieve half-up rounding.
    return ((raw + 50) / 100).floor();
  }
}
