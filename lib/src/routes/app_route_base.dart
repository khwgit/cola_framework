import 'dart:async';

import 'package:cola_framework/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

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

  /// Guards the route based on the [checker] function.
  ///
  /// It will redirect to [target] if the [checker] returns 'true'.
  @protected
  FutureOr<String?> guard(
    FutureOr<bool> Function(StateT state) checker,
    String? target, [
    String? fallback,
  ]) async {
    await service.initialize();
    return await checker(service.state) ? target : fallback;
  }
}
