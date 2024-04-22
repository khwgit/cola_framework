import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../services.dart';
import 'go_router_wrapper.dart';

abstract class AppRouteBase<StateT> extends ChangeNotifier {
  AppRouteBase() {
    /// Initializes [$routes] at the beginning
    $routes;
  }

  AppServiceBase<StateT> get service;

  List<RouteBase> get $routes;

  FutureOr<String?> $redirect(
    BuildContext context,
    GoRouterState state,
  );

  // void $listen(
  //   Ref ref,
  //   AlwaysAliveProviderListenable provider, {
  //   bool fireImmediately = false,
  // }) {
  //   $listenAll(ref, [provider], fireImmediately: fireImmediately);
  // }

  // void $listenAll(
  //   Ref ref,
  //   List<AlwaysAliveProviderListenable> providers, {
  //   bool fireImmediately = false,
  // }) {
  //   for (var provider in providers) {
  //     ref.listen(
  //       provider,
  //       (previous, next) => SchedulerBinding.instance.addPostFrameCallback((_) {
  //         notifyListeners();
  //       }),
  //       fireImmediately: fireImmediately,
  //     );
  //   }
  // }

  /// Guards the route based on the [checker] function.
  ///
  /// It will redirect to [target] if the [checker] returns 'true'.
  @protected
  FutureOr<String?> guard(
    FutureOr<bool> Function(StateT state) checker,
    GoRouteConfig? target, [
    GoRouteConfig? fallback,
  ]) async {
    await service.initialize();
    return await checker(service.state) ? target?.location : fallback?.location;
  }
}
