import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('More placeholder'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/more/features'),
            child: const Text('Features'),
          ),
        ],
      ),
    );
  }
}
