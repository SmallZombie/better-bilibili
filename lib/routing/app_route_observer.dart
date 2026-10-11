import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:material_ui/material_ui.dart';
import 'package:logger/logger.dart';
import 'dart:async';

final appRouteObserver = AppRouteObserver();

class AppRouteObserver extends NavigatorObserver {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'AppRouteObserver'));

  final StreamController<AppRouteEvent> _eventController = StreamController<AppRouteEvent>.broadcast();

  Stream<AppRouteEvent> get events => _eventController.stream;

  void _add(AppRouteEvent event) {
    _eventController.add(event);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log.i(
      'didPush: route=(${route.settings.name}: ${route.settings.arguments}), previousRoute=(${previousRoute?.settings.name}: ${previousRoute?.settings.arguments})',
    );
    _add(AppRoutePushEvent(route, previousRoute));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log.i(
      'didPop: route=(${route.settings.name}: ${route.settings.arguments}), previousRoute=(${previousRoute?.settings.name}: ${previousRoute?.settings.arguments})',
    );
    _add(AppRoutePopEvent(route, previousRoute));
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log.i(
      'didRemove: route=(${route.settings.name}: ${route.settings.arguments}), previousRoute=(${previousRoute?.settings.name}: ${previousRoute?.settings.arguments})',
    );
    _add(AppRouteRemoveEvent(route, previousRoute));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log.i(
      'didReplace: new=(${newRoute?.settings.name}: ${newRoute?.settings.arguments}), old=(${oldRoute?.settings.name}: ${oldRoute?.settings.arguments})',
    );
    _add(AppRouteReplaceEvent(newRoute, oldRoute));
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log.i(
      'didStartUserGesture: route=(${route.settings.name}: ${route.settings.arguments}), previousRoute=(${previousRoute?.settings.name}: ${previousRoute?.settings.arguments})',
    );
    _add(AppRouteStartUserGestureEvent(route, previousRoute));
  }

  @override
  void didStopUserGesture() {
    _log.i('didStopUserGesture');
    _add(const AppRouteStopUserGestureEvent());
  }
}

abstract class AppRouteEvent {
  const AppRouteEvent();
}

class AppRoutePushEvent extends AppRouteEvent {
  final Route<dynamic> route;
  final Route<dynamic>? previousRoute;

  const AppRoutePushEvent(this.route, this.previousRoute);
}

class AppRoutePopEvent extends AppRouteEvent {
  final Route<dynamic> route;
  final Route<dynamic>? previousRoute;

  const AppRoutePopEvent(this.route, this.previousRoute);
}

class AppRouteRemoveEvent extends AppRouteEvent {
  final Route<dynamic> route;
  final Route<dynamic>? previousRoute;

  const AppRouteRemoveEvent(this.route, this.previousRoute);
}

class AppRouteReplaceEvent extends AppRouteEvent {
  final Route<dynamic>? newRoute;
  final Route<dynamic>? oldRoute;

  const AppRouteReplaceEvent(this.newRoute, this.oldRoute);
}

class AppRouteStartUserGestureEvent extends AppRouteEvent {
  final Route<dynamic> route;
  final Route<dynamic>? previousRoute;

  const AppRouteStartUserGestureEvent(this.route, this.previousRoute);
}

class AppRouteStopUserGestureEvent extends AppRouteEvent {
  const AppRouteStopUserGestureEvent();
}
