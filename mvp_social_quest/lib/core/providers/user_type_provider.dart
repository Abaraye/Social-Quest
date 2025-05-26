import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

final userTypeProvider = FutureProvider<String?>((ref) async {
  final auth = ref.watch(authProvider).value;
  final userId = auth?.uid;
  if (userId == null) return null;

  final user = await ref.read(userRepoProvider).fetch(userId);
  return user?.type;
});
