import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies router when stream changes (e.g., auth state)
/// Used to trigger router refresh on authentication changes
class StreamRefreshNotifier<T> extends ChangeNotifier {
  StreamRefreshNotifier(Stream<T> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<T> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
