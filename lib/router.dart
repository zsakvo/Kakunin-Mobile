import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakunin/data/models/verification_item.dart';
// import 'package:go_router_flow/go_router_flow.dart';
import 'package:kakunin/screen/code/code_view.dart';
import 'package:kakunin/screen/config/config_view.dart';
import 'package:kakunin/screen/home/home_view.dart';
import 'package:kakunin/screen/scan/scan_view.dart';

class AppPages {
  static GoRouter router = GoRouter(navigatorKey: NavigationService.navigatorKey, routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/code',
      builder: (context, state) {
        VerificationItem? item = state.extra as VerificationItem?;
        return CodeView(item: item);
      },
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanView(),
    ),
    GoRoute(
      path: '/config',
      builder: (context, state) => const ConfigView(),
    ),
  ]);
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
