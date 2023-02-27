import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:kakunin/data/models/verification_item.dart';
import 'package:kakunin/router.dart';
import 'package:kakunin/utils/color.dart';
import 'package:kakunin/utils/log.dart';
import 'package:kakunin/utils/scroll.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/data/latest.dart' as timezone;

late final SharedPreferences spInstance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timezone.initializeTimeZones();
  spInstance = await SharedPreferences.getInstance();
  Isar.openSync([VerificationItemSchema]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);
  const systemUiOverlayStyle =
      SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.transparent);
  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  runApp(const ProviderScope(child: MyApp()));
}

// final _defaultLightColor = ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light);
// final _defaultDarkColor = ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark);

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return DynamicColorBuilder(
//       builder: (lightDynamic, darkDynamic) {
//         return MaterialApp.router(
//           theme: ThemeData(colorScheme: lightDynamic ?? _defaultLightColor, useMaterial3: true),
//           darkTheme: ThemeData(colorScheme: darkDynamic ?? _defaultDarkColor, useMaterial3: true),
//           routeInformationProvider: AppPages.router.routeInformationProvider,
//           routeInformationParser: AppPages.router.routeInformationParser,
//           routerDelegate: AppPages.router.routerDelegate,
//           scrollBehavior: CustScroll(),
//         );
//       },
//     );
//   }
// }

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color colorSeed = ref.watch(colorThemeProvider);
    final monetEnabled = ref.watch(monetEnableProvider);
    final defaultLightColor = ColorScheme.fromSeed(seedColor: colorSeed, brightness: Brightness.light);
    final defaultDarkColor = ColorScheme.fromSeed(seedColor: colorSeed, brightness: Brightness.dark);

    // useEffect(() {
    //   ref.read(colorThemeProvider.notifier).state =
    //       getMaterialColor(Color(spInstance.getInt("colorSeed") ?? 0xff2196f3));
    //   return null;
    // }, []);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        if (lightDynamic == null || darkDynamic == null) {
          supportMonet = false;
        } else {
          supportMonet = true;
        }
        // useEffect(() {
        //   if (lightDynamic == null) {
        //     ref.read(monetSupportProvider.notifier).state = false;
        //     spInstance.setBool("dynamicColor", false);
        //   }
        // }, []);
        Log.e(ref.read(monetEnableProvider.notifier).state, "ltc");
        return MaterialApp.router(
          theme: ThemeData(colorScheme: (monetEnabled ? lightDynamic : null) ?? defaultLightColor, useMaterial3: true),
          darkTheme:
              ThemeData(colorScheme: (monetEnabled ? darkDynamic : null) ?? defaultDarkColor, useMaterial3: true),
          routeInformationProvider: AppPages.router.routeInformationProvider,
          routeInformationParser: AppPages.router.routeInformationParser,
          routerDelegate: AppPages.router.routerDelegate,
          scrollBehavior: CustScroll(),
        );
      },
    );
  }
}

final colorThemeProvider =
    StateProvider((ref) => getMaterialColor(Color(spInstance.getInt("colorSeed") ?? 0xff2196f3)));

// final monetSupportProvider = StateProvider((ref) => true);

final monetEnableProvider = StateProvider((ref) => spInstance.getBool("dynamicColor") ?? false);

bool supportMonet = false;
