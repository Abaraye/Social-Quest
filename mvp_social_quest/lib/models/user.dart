class AppUser {
  final String id;
  final String email;
  final String name;
  final String type;
  final List<String> favorites;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
    required this.favorites,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    type: json['type'],
    favorites: List<String>.from(json['favorites'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'type': type,
    'favorites': favorites,
  };
}
