import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services.dart';
import 'go_router_wrapper.dart';

abstract class AppRouteBase<State extends AppStateBase> extends ChangeNotifier {
  AppRouteBase() {
    /// Initializes [$routes] at the beginning
    $routes;
  }

  State get state;

  List<RouteBase> get $routes;

  FutureOr<String?> $redirect(
    BuildContext context,
    GoRouterState state,
  );

  void $listen(
    Ref ref,
    AlwaysAliveProviderListenable provider, {
    bool fireImmediately = false,
  }) {
    $listenAll(ref, [provider], fireImmediately: fireImmediately);
  }

  void $listenAll(
    Ref ref,
    List<AlwaysAliveProviderListenable> providers, {
    bool fireImmediately = false,
  }) {
    for (var provider in providers) {
      ref.listen(
        provider,
        (previous, next) => SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        }),
        fireImmediately: fireImmediately,
      );
    }
  }

  @protected
  String? guard(
    bool Function(State state) checker,
    GoRouteConfig? target, [
    GoRouteConfig? fallback,
  ]) {
    final state = this.state;
    if (!state.isReady) return null;

    final result = checker(state) ? target : fallback;
    return result?.location;
  }
}
