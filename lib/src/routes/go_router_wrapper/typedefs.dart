// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/misc/errors.dart';

import 'go_route_info.dart';

// --- RouteWrapper
typedef GoRouteWrapperBuilder = GoRouterWidgetBuilder;
typedef GoRouteWrapperPageBuilder = GoRouterPageBuilder;
typedef GoRouteWrapperRedirect = GoRouterRedirect;
typedef GoRouteWrapperToLocation = String Function();

// --- InfoRouteWrapper
typedef GoInfoRouteWrapperBuilder<T extends GoRouteInfo> = Widget Function(
  BuildContext context,
  GoRouterInfoState<T> state,
);
typedef GoInfoRouteWrapperPageBuilder<T extends GoRouteInfo> = Page<void>
    Function(
  BuildContext context,
  GoRouterInfoState<T> state,
);
typedef GoInfoRouteWrapperRedirect<T extends GoRouteInfo> = FutureOr<String?>
    Function(
  BuildContext context,
  GoRouterInfoState<T> state,
);
typedef GoInfoRouteWrapperToLocation<T extends GoRouteInfo> = String Function(
  T info,
);
typedef GoInfoRouteWrapperToInfo<T extends GoRouteInfo> = T Function(
  GoRouterState state,
);

// --- ShellRouteWrapper
typedef GoShellRouteWrapperBuilder = ShellRouteBuilder;
typedef GoShellRouteWrapperPageBuilder = ShellRoutePageBuilder;

// --- StatefulShellRouteWrapper
typedef GoStatefulShellRouteWrapperBuilder = StatefulShellRouteBuilder;
typedef GoStatefulShellRouteWrapperPageBuilder = StatefulShellRoutePageBuilder;
typedef GoStatefulShellNavigationContainerBuilder
    = ShellNavigationContainerBuilder;

class GoRouterInfoState<T extends GoRouteInfo> implements GoRouterState {
  const GoRouterInfoState(this._state, this.info);

  final GoRouterState _state;
  final T info;

  @override
  GoException? get error => _state.error;

  @override
  Object? get extra => _state.extra;

  @override
  String? get fullPath => _state.fullPath;

  @override
  String get location => _state.location;

  @override
  String? get name => _state.name;

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  @override
  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
  }) {
    return _state.namedLocation(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
    );
  }

  @override
  ValueKey<String> get pageKey => _state.pageKey;

  @override
  Map<String, String> get pathParameters => _state.pathParameters;

  @override
  String? get path => _state.path;

  @override
  Map<String, List<String>> get queryParametersAll => _state.queryParametersAll;

  @override
  Map<String, String> get queryParameters => _state.queryParameters;

  @override
  String get matchedLocation => _state.matchedLocation;
}
