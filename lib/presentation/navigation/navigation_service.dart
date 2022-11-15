import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory NavigationService() {
    return _instance;
  }

  NavigationService._internal();

  Future<void>? push(Widget screen) {
    return navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) {
          return screen;
        },
      ),
    );
  }

  Future<void>? pushReplacement(Widget screen) {
    return navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return screen;
        },
      ),
    );
  }

  void pop() {
    return navigatorKey.currentState?.pop();
  }
}
