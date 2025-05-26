class FormValidators {
  static String? validateRequired(String? value) {
    return (value == null || value.trim().isEmpty)
        ? 'Ce champ est requis'
        : null;
  }

  static String? email(String? value) {
    // Exemple simple
    if (value == null || !value.contains('@')) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) return 'Mot de passe trop court';
    return null;
  }

  static String? Function(String?) required([String field = 'Ce champ']) {
    return (value) =>
        value == null || value.trim().isEmpty ? '$field est requis' : null;
  }
}
