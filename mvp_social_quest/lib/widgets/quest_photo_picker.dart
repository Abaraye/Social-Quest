// lib/widgets/quest_photo_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget réutilisable pour afficher et gérer les photos d'une quête
class QuestPhotoPicker extends StatelessWidget {
  final List<String> networkImages;
  final List<XFile> localImages;
  final VoidCallback onPick;
  final void Function(String url) onRemoveNetwork;
  final void Function(XFile file) onRemoveLocal;

  const QuestPhotoPicker({
    Key? key,
    required this.networkImages,
    required this.localImages,
    required this.onPick,
    required this.onRemoveNetwork,
    required this.onRemoveLocal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allCount = networkImages.length + localImages.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child:
              allCount > 0
                  ? PageView.builder(
                    itemCount: allCount,
                    itemBuilder: (context, index) {
                      final isNetwork = index < networkImages.length;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          isNetwork
                              ? Image.network(
                                networkImages[index],
                                fit: BoxFit.cover,
                              )
                              : Image.file(
                                File(
                                  localImages[index - networkImages.length]
                                      .path,
                                ),
                                fit: BoxFit.cover,
                              ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                if (isNetwork) {
                                  onRemoveNetwork(networkImages[index]);
                                } else {
                                  onRemoveLocal(
                                    localImages[index - networkImages.length],
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                  : Container(
                    color: Colors.grey[200],
                    child: const Center(child: Text('Aucune photo')),
                  ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Ajouter des photos'),
        ),
      ],
    );
  }
}
