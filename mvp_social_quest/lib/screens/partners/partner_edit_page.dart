import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/partner.dart';
import '../../../widgets/forms/partner_form.dart';
import '../../../core/providers/partner_provider.dart';

class PartnerEditPage extends ConsumerWidget {
  final String? partnerId;
  final Partner? initial;

  const PartnerEditPage({super.key, this.partnerId, this.initial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Cas 1 : un Partner complet est fourni → édition directe
    if (initial != null) {
      return _buildFormPage(context, initial!);
    }

    // ✅ Cas 2 : un partnerId est fourni → chargement async
    if (partnerId != null) {
      final asyncPartner = ref.watch(partnerProvider(partnerId!));
      return asyncPartner.when(
        data: (partner) {
          if (partner == null) {
            return const Scaffold(
              body: Center(child: Text('Activité introuvable')),
            );
          }
          return _buildFormPage(context, partner);
        },
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (e, _) => Scaffold(body: Center(child: Text('Erreur : $e'))),
      );
    }

    // ✅ Cas 3 : ni partnerId ni initial → création d’un nouveau partner
    return _buildFormPage(context, null);
  }

  Widget _buildFormPage(BuildContext context, Partner? partner) {
    return Scaffold(
      appBar: AppBar(
        title: Text(partner == null ? 'Nouveau commerce' : 'Modifier activité'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PartnerForm(
          initial: partner,
          onSaved: () {
            context.go('/');
          },
        ),
      ),
    );
  }
}
