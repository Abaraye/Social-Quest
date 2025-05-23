import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) dataBuilder;
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.dataBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: dataBuilder,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
    );
  }
}
