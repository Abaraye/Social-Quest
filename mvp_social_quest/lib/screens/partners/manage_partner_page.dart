import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 🔧 Écran de gestion des activités du commerçant
class ManagePartnerPage extends StatefulWidget {
  const ManagePartnerPage({super.key});

  @override
  State<ManagePartnerPage> createState() => _ManagePartnerPageState();
}

class _ManagePartnerPageState extends State<ManagePartnerPage> {
  // Contrôleurs pour les champs de création d'activité
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // Contrôleurs pour les réductions
  final reductionAmountController = TextEditingController();
  final groupSizeController = TextEditingController();

  // Liste de catégories disponibles (à centraliser plus tard)
  final List<String> categories = [
    'Cuisine',
    'Sport',
    'Culture',
    'Jeux',
    'Bien-être',
    'Musique',
    'Autre',
  ];
  String selectedCategory = 'Cuisine';

  // Activité sélectionnée pour l’ajout de slots
  DateTime? selectedDateTime;
  String? partnerId;
  bool isLoading = true;

  // Activités et slots chargés depuis Firestore
  List<Map<String, dynamic>> partners = [];
  List<Map<String, dynamic>> slots = [];

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  /// 🔁 Charge toutes les activités du commerçant
  Future<void> _loadPartners() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('partners')
            .where('ownerId', isEqualTo: user.uid)
            .get();

    partners =
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();

    setState(() => isLoading = false);
  }

  /// 🔁 Charge les slots d’un partenaire sélectionné
  Future<void> _loadSlots(String partnerId) async {
    final slotsSnapshot =
        await FirebaseFirestore.instance
            .collection('partners')
            .doc(partnerId)
            .collection('slots')
            .get();

    setState(() {
      this.partnerId = partnerId;
      slots =
          slotsSnapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
    });
  }

  /// ➕ Crée une nouvelle activité
  Future<void> _createPartner() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('partners').add({
      'ownerId': user.uid,
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': selectedCategory,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      partners.add({
        'id': doc.id,
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': selectedCategory,
      });
      nameController.clear();
      descriptionController.clear();
    });
  }

  /// 📅 Affiche le sélecteur de date + heure
  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  /// ➕ Ajoute un slot à l’activité sélectionnée
  Future<void> _addSlot() async {
    if (partnerId == null || selectedDateTime == null) return;

    final amount = int.tryParse(reductionAmountController.text.trim());
    final groupSize = int.tryParse(groupSizeController.text.trim());
    if (amount == null || groupSize == null) return;

    final slotData = {
      'startTime': Timestamp.fromDate(selectedDateTime!),
      'reductions': [
        {'amount': amount, 'groupSize': groupSize},
      ],
    };

    final docRef = await FirebaseFirestore.instance
        .collection('partners')
        .doc(partnerId)
        .collection('slots')
        .add(slotData);

    setState(() {
      slots.add({...slotData, 'id': docRef.id});
      selectedDateTime = null;
      reductionAmountController.clear();
      groupSizeController.clear();
    });
  }

  /// 🧱 UI
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes activités"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Créer une nouvelle activité",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 🔹 Formulaire création activité
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Nom de l'activité",
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) => value!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) => value!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items:
                        categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => selectedCategory = val!),
                    decoration: const InputDecoration(
                      labelText: "Catégorie",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_business),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) _createPartner();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    label: const Text("Créer l'activité"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              "Mes activités",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // 🔹 Liste des activités créées
            ...partners.map(
              (partner) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(partner['name'] ?? ''),
                  subtitle: Text(partner['description'] ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () => _loadSlots(partner['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade400,
                    ),
                    child: const Text("Gérer"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
