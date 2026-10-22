import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/session_lock_manager.dart';

class UserActivityDetector extends ConsumerStatefulWidget {
  const UserActivityDetector({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UserActivityDetector> createState() =>
      _UserActivityDetectorState();
}

class _UserActivityDetectorState extends ConsumerState<UserActivityDetector> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    ref.read(sessionLockManagerProvider).recordActivity();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) =>
          ref.read(sessionLockManagerProvider).recordActivity(),
      onPointerMove: (_) =>
          ref.read(sessionLockManagerProvider).recordActivity(),
      onPointerSignal: (_) =>
          ref.read(sessionLockManagerProvider).recordActivity(),
      onPointerPanZoomStart: (_) =>
          ref.read(sessionLockManagerProvider).recordActivity(),
      onPointerPanZoomUpdate: (_) =>
          ref.read(sessionLockManagerProvider).recordActivity(),
      child: Focus(
        onKeyEvent: (node, event) {
          ref.read(sessionLockManagerProvider).recordActivity();
          return KeyEventResult.ignored;
        },
        child: widget.child,
      ),
    );
  }
}
