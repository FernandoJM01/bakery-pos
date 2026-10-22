import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/session_lock_manager.dart';

class UserActivityDetector extends ConsumerWidget {
  const UserActivityDetector({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) =>
          ref.read(sessionLockManagerProvider).recordActivity(),
      onPointerMove: (_) =>
          ref.read(sessionLockManagerProvider).recordActivity(),
      child: Focus(
        onKeyEvent: (node, event) {
          ref.read(sessionLockManagerProvider).recordActivity();
          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }
}
