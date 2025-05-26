// lib/widgets/quest_photo_carousel.dart
import 'package:flutter/material.dart';

class QuestPhotoCarousel extends StatelessWidget {
  final List<String> urls;
  const QuestPhotoCarousel({super.key, required this.urls});

  @override
  Widget build(BuildContext context) =>
      urls.isEmpty
          ? const Placeholder(fallbackHeight: 180)
          : SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: urls.length,
              itemBuilder: (_, i) => Image.network(urls[i], fit: BoxFit.cover),
            ),
          );
}
