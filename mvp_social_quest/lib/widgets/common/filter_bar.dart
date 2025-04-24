// widgets/common/filter_bar.dart
import 'package:flutter/material.dart';

/// 🔤 Barre de filtres horizontale intégrant des ChoiceChips
class FilterBar extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final void Function(String) onToggle;
  final String labelAll;

  const FilterBar({
    Key? key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.labelAll = 'Tous',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(labelAll),
            selected: selected.isEmpty,
            onSelected: (_) => onToggle('__all__'),
          ),
          const SizedBox(width: 8),
          ...options.map(
            (opt) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(opt),
                selected: selected.contains(opt),
                onSelected: (_) => onToggle(opt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
