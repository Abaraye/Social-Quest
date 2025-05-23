import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/slot.dart';
import 'repository_providers.dart';

final slotListProvider = StreamProvider<List<Slot>>(
  (ref) => ref.watch(slotRepoProvider).watchAll(),
);

final slotProvider = FutureProvider.family<Slot?, String>(
  (ref, id) => ref.watch(slotRepoProvider).fetch(id),
);
