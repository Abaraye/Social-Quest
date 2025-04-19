import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp_social_quest/services/firestore_service.dart';

class CreatePartnerPage extends StatefulWidget {
  const CreatePartnerPage({super.key});

  @override
  State<CreatePartnerPage> createState() => _CreatePartnerPageState();
}

class _CreatePartnerPageState extends State<CreatePartnerPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final slotController = TextEditingController();
  final reductionController = TextEditingController();

  final Map<String, List<String>> slots = {};
  bool isLoading = false;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)
      return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  void _addSlotWithReduction() {
    final slot = slotController.text.trim();
    final reduction = reductionController.text.trim();
    if (slot.isNotEmpty && reduction.isNotEmpty) {
      setState(() {
        slots.putIfAbsent(slot, () => []).add(reduction);
        slotController.clear();
        reductionController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        slots.isEmpty ||
        latitude == null ||
        longitude == null)
      return;

    setState(() => isLoading = true);
    try {
      await FirestoreService.createPartner(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        category: categoryController.text.trim(),
        slots: slots,
        latitude: latitude!,
        longitude: longitude!,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Activité créée avec succès ✅")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : \${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle activité'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Créer une activité 🎯',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l’activité',
                ),
                validator: (value) => value!.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                validator:
                    (value) => value!.isEmpty ? 'Catégorie requise' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator:
                    (value) => value!.isEmpty ? 'Description requise' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Créneaux et réductions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: slotController,
                      decoration: const InputDecoration(
                        hintText: 'Ex: Samedi 15h',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: reductionController,
                      decoration: const InputDecoration(
                        hintText: 'Ex: -20% à partir de 4',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSlotWithReduction,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...slots.entries.map(
                (entry) => ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value.join(', ')),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size.fromHeight(50),
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Créer une activité'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
