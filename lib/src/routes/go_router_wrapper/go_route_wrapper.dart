import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'go_route_config.dart';
import 'go_route_info.dart';
import 'typedefs.dart';

abstract class GoRouteWrapperBase {
  const GoRouteWrapperBase();
}

class GoRouteWrapper extends GoRouteWrapperBase {
  GoRouteWrapper({
    this.builder,
    this.pageBuilder,
    this.redirect,
    this.onExit,
  });

  final GoRouterWidgetBuilder? builder;
  final GoRouterPageBuilder? pageBuilder;
  final GoRouterRedirect? redirect;
  final ExitCallback? onExit;

  GoRouteWrapperToLocation? $location;

  GoRoute $route({
    required String path,
    required GoRouteWrapperToLocation $location,
    List<RouteBase> routes = const [],
    GlobalKey<NavigatorState>? parentNavigatorKey,
  }) {
    this.$location ??= $location;
    return GoRoute(
      path: path,
      builder: builder,
      pageBuilder: pageBuilder,
      redirect: redirect,
      routes: routes,
      parentNavigatorKey: parentNavigatorKey,
      onExit: onExit,
    );
  }

  GoRouteConfig call() {
    return GoRouteConfig(
      location: $location!(),
    );
  }
}

class GoInfoRouteWrapper<T extends GoRouteInfo> extends GoRouteWrapperBase {
  /// Used to cache [GoRouteInfo] that corresponds to a given [GoRouterState]
  /// to minimize the number of times it has to be deserialized.
  static final _stateObjectExpando = Expando<GoRouteInfo>(
    'GoRouteState to GoRouteInfo expando',
  );

  GoInfoRouteWrapper({
    this.builder,
    this.pageBuilder,
    this.redirect,
    this.onExit,
  });

  final GoInfoRouteWrapperBuilder<T>? builder;
  final GoInfoRouteWrapperPageBuilder<T>? pageBuilder;
  final GoInfoRouteWrapperRedirect<T>? redirect;
  final ExitCallback? onExit;

  GoInfoRouteWrapperToLocation<T>? $location;

  GoRoute $route({
    required String path,
    required GoInfoRouteWrapperToLocation<T> $location,
    required GoInfoRouteWrapperToInfo<T> $info,
    List<RouteBase> routes = const [],
    GlobalKey<NavigatorState>? parentNavigatorKey,
  }) {
    T getInfo(GoRouterState state) {
      final Object? extra = state.extra;

      // If the "extra" value is of type `T` then we know it's the source
      // instance of `GoRouteInfo`, so it doesn't need to be recreated.
      if (extra is T) {
        return extra;
      }

      return (_stateObjectExpando[state] ??= $info(state)) as T;
    }

    GoRouterInfoState<T> getState(GoRouterState state) {
      return GoRouterInfoState(state, getInfo(state));
    }

    this.$location ??= $location;
    return GoRoute(
      path: path,
      routes: routes,
      parentNavigatorKey: parentNavigatorKey,
      builder: builder == null
          ? null
          : (context, state) => builder!(context, getState(state)),
      pageBuilder: pageBuilder == null
          ? null
          : (context, state) => pageBuilder!(context, getState(state)),
      redirect: redirect == null
          ? null
          : (context, state) => redirect!(context, getState(state)),
      onExit: onExit,
    );
  }

  GoInfoRouteConfig<T> call(T info) {
    return GoInfoRouteConfig(
      location: $location!(info),
      info: info,
    );
  }
}

class GoShellRouteWrapper extends GoRouteWrapperBase {
  const GoShellRouteWrapper({
    this.builder,
    this.pageBuilder,
  });

  final GoShellRouteWrapperBuilder? builder;
  final GoShellRouteWrapperPageBuilder? pageBuilder;

  ShellRoute $route({
    List<RouteBase> routes = const <RouteBase>[],
    List<NavigatorObserver>? observers,
    GlobalKey<NavigatorState>? navigatorKey,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    String? restorationScopeId,
  }) {
    return ShellRoute(
      builder: builder,
      pageBuilder: pageBuilder,
      routes: routes,
      observers: observers,
      navigatorKey: navigatorKey,
      parentNavigatorKey: parentNavigatorKey,
      // TODO: Review if it should be placed here
      restorationScopeId: restorationScopeId,
    );
  }
}

class GoStatefulShellRouteWrapper extends GoRouteWrapperBase {
  const GoStatefulShellRouteWrapper({
    this.builder,
    this.pageBuilder,
    required GoStatefulShellNavigationContainerBuilder
        this.navigatorContainerBuilder,
  });

  const GoStatefulShellRouteWrapper.indexedStack({
    this.builder,
    this.pageBuilder,
  }) : navigatorContainerBuilder = null;

  final GoStatefulShellRouteWrapperBuilder? builder;
  final GoStatefulShellRouteWrapperPageBuilder? pageBuilder;
  final GoStatefulShellNavigationContainerBuilder? navigatorContainerBuilder;

  StatefulShellRoute $route({
    required List<StatefulShellBranch> branches,
    List<NavigatorObserver>? observers,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    String? restorationScopeId,
  }) {
    return navigatorContainerBuilder == null
        ? StatefulShellRoute.indexedStack(
            branches: branches,
            builder: builder,
            pageBuilder: pageBuilder,
            parentNavigatorKey: parentNavigatorKey,
            restorationScopeId: restorationScopeId,
          )
        : StatefulShellRoute(
            branches: branches,
            navigatorContainerBuilder: navigatorContainerBuilder!,
            builder: builder,
            pageBuilder: pageBuilder,
            parentNavigatorKey: parentNavigatorKey,
            restorationScopeId: restorationScopeId,
          );
  }
}
