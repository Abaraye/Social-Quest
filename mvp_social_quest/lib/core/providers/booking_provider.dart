import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/booking.dart';
import 'repository_providers.dart';

final bookingListProvider = StreamProvider<List<Booking>>(
  (ref) => ref.watch(bookingRepoProvider).watchAll(),
);

final bookingProvider = FutureProvider.family<Booking?, String>(
  (ref, id) => ref.watch(bookingRepoProvider).fetch(id),
);

final partnerBookingListProvider = FutureProvider.family<List<Booking>, String>(
  (ref, partnerId) async {
    final repo = ref.read(bookingRepoProvider);
    return repo.fetchByPartnerId(partnerId);
  },
);
