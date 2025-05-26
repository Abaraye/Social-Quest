import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) dataBuilder;
  final Widget? loading;
  final Widget Function(Object error)? errorBuilder;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.dataBuilder,
    this.loading,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: dataBuilder,
      loading:
          () => loading ?? const Center(child: CircularProgressIndicator()),
      error:
          (e, _) =>
              errorBuilder != null
                  ? errorBuilder!(e)
                  : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Une erreur est survenue :\n$e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
    );
  }
}
