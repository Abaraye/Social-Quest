class FormValidators {
  static String? requiredField(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Champ requis' : null;

  static String? email(String? value) {
    if (requiredField(value) != null) return 'Email requis';
    final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value!.trim()) ? null : 'Email invalide';
  }

  static String? password(String? value) =>
      (value != null && value.length >= 6) ? null : '6 caractères minimum';
}
