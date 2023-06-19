import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'go_route_info.dart';

class GoRouteConfig {
  const GoRouteConfig({
    required this.location,
  });

  final String location;

  void go(BuildContext context) {
    return GoRouter.of(context).goRoute(this);
  }

  Future<T?> push<T>(BuildContext context) {
    return GoRouter.of(context).pushRoute(this);
  }

  Future<T?> pushReplacement<T>(BuildContext context) {
    return GoRouter.of(context).pushReplacementRoute(this);
  }

  Future<T?> replace<T>(BuildContext context) {
    return GoRouter.of(context).replaceRoute(this);
  }
}

class GoInfoRouteConfig<T extends GoRouteInfo> extends GoRouteConfig {
  const GoInfoRouteConfig({
    required super.location,
    required this.info,
  });

  final T info;
}

extension GoRouterWrapperExtension on GoRouter {
  GoRouteInfo? _info(GoRouteConfig config) {
    return config is GoInfoRouteConfig ? config.info : null;
  }

  void goRoute(GoRouteConfig config) {
    return go(config.location, extra: _info(config));
  }

  Future<T?> pushRoute<T>(GoRouteConfig config) {
    return push<T>(config.location, extra: _info(config));
  }

  Future<T?> pushReplacementRoute<T>(GoRouteConfig config) {
    return pushReplacement<T>(config.location, extra: _info(config));
  }

  Future<T?> replaceRoute<T>(GoRouteConfig config) {
    return replace<T>(config.location, extra: _info(config));
  }
}
