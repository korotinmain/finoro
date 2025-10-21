import 'dart:async';
import 'package:flutter/foundation.dart';

/// Notifies router when stream changes (e.g., auth state)
/// Used to trigger router refresh on authentication changes
class StreamRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription _subscription;

  StreamRefreshNotifier(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
