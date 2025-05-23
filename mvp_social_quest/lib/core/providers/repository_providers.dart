import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvp_social_quest/core/providers/discount_repository_provider.dart';
import 'package:mvp_social_quest/data/discount_repository.dart';
import 'package:mvp_social_quest/models/discount.dart';
import '../../data/user_repository.dart';
import '../../data/partner_repository.dart';
import '../../data/quest_repository.dart';
import '../../data/slot_repository.dart';
import '../../data/booking_repository.dart';
import '../../data/auth_repository.dart';

final authRepoProvider = Provider<AuthRepository>(
  (_) => AuthRepository.instance,
);
final userRepoProvider = Provider((_) => UserRepository.instance);
final partnerRepoProvider = Provider((_) => PartnerRepository.instance);
final questRepoProvider = Provider((_) => QuestRepository.instance);
final slotRepoProvider = Provider((_) => SlotRepository.instance);
final bookingRepoProvider = Provider((_) => BookingRepository.instance);
final discountRepoProvider = Provider((_) => DiscountRepository.instance);
final discountsProvider = StreamProvider.family<List<Discount>, String>((
  ref,
  slotId,
) {
  final repo = ref.watch(discountRepositoryProvider);
  return repo.watchAll(slotId: slotId);
});
