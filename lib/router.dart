import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:kakunin/data/models/verification_item.dart';
import 'package:kakunin/main.dart';
import 'package:kakunin/screen/backup/backup_view.dart';
import 'package:kakunin/screen/backup/webdav_path_view.dart';
import 'package:kakunin/screen/backup/webdav_view.dart';
// import 'package:go_router_flow/go_router_flow.dart';
import 'package:kakunin/screen/code/code_view.dart';
import 'package:kakunin/screen/config/config_view.dart';
import 'package:kakunin/screen/home/home_view.dart';
import 'package:kakunin/screen/libs/lib_detail_screen.dart';
import 'package:kakunin/screen/libs/libs_screen.dart';
import 'package:kakunin/screen/scan/scan_view.dart';
import 'package:timezone/timezone.dart';

class AppPages {
  static GoRouter router = GoRouter(navigatorKey: NavigationService.navigatorKey, routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => getI18nWidget(child: const HomeView()),
    ),
    GoRoute(
      path: '/code',
      builder: (context, state) {
        VerificationItem? item = state.extra as VerificationItem?;
        return getI18nWidget(child: CodeView(item: item));
      },
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => getI18nWidget(child: const ScanView()),
    ),
    GoRoute(
      path: '/config',
      builder: (context, state) => getI18nWidget(child: const ConfigView()),
    ),
    GoRoute(
      path: '/libs',
      builder: (context, state) => getI18nWidget(child: const LibsView()),
    ),
    GoRoute(
      path: '/lib_detail',
      builder: (context, state) {
        String lib = state.extra as String;
        return getI18nWidget(child: LibDetailView(lib: lib));
      },
    ),
    GoRoute(
      path: '/backup',
      builder: (context, state) => getI18nWidget(child: const BackupView()),
    ),
    GoRoute(
      path: '/webdav',
      builder: (context, state) => getI18nWidget(child: const WebDavView()),
    ),
    GoRoute(
      path: '/webdavPath',
      builder: (context, state) => getI18nWidget(child: const WebDavPathView()),
    )
  ]);
}

getI18nWidget({required Widget child}) {
  return I18n(
    initialLocale: locale,
    child: child,
  );
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
