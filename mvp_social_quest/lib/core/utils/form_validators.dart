class FormValidators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ requis';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Adresse email requise';
    }
    if (!value.contains('@')) {
      return 'Adresse email invalide';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 6) {
      return '6 caractères minimum';
    }
    return null;
  }
}
