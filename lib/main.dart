import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:isar/isar.dart';
import 'package:kakunin/data/models/verification_item.dart';
import 'package:kakunin/provider.dart';
import 'package:kakunin/router.dart';
import 'package:kakunin/utils/color.dart';
import 'package:kakunin/utils/log.dart';

import 'package:kakunin/utils/scroll.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:timezone/data/latest.dart' as timezone;

import 'utils/i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

late final SharedPreferences spInstance;

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email', DriveApi.driveFileScope],
);

// late final GoogleSignInAccount? googleAccount;

// late final DriveApi? driveApi;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

const locales = [
  Locale('en', "US"),
  Locale('zh', "CN"),
  Locale('zh', "TW"),
  Locale('ja', "JP"),
];

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color colorSeed = ref.watch(colorThemeProvider);
    final monetEnabled = ref.watch(monetEnableProvider);
    final defaultLightColor = ColorScheme.fromSeed(seedColor: colorSeed, brightness: Brightness.light);
    final defaultDarkColor = ColorScheme.fromSeed(seedColor: colorSeed, brightness: Brightness.dark);
    final locale = locales[spInstance.getInt("locale") ?? 1];
    // final locale = ref.watch(localeProvider);
    // final currentLocale = useState(getLocale(locale));
    useEffect(() {
      // initGoogleAccount(context);
      int accountType = spInstance.getInt("accountType") ?? 0;
      if (accountType == 0) {
        ref.read(cloudAccountProvider.notifier).login(CloudAccountType.Google);
      } else if (accountType == 1) {
        ref.read(cloudAccountProvider.notifier).checkDavToken();
      }
      return null;
    }, []);
    return I18n(
      initialLocale: locale,
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          if (lightDynamic == null || darkDynamic == null) {
            supportMonet = false;
          } else {
            supportMonet = true;
          }
          return MaterialApp.router(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: const [
              Locale('en', "US"),
              Locale('zh', "CN"),
              Locale('zh', "TW"),
              Locale('ja', "JP"),
            ],
            theme:
                ThemeData(colorScheme: (monetEnabled ? lightDynamic : null) ?? defaultLightColor, useMaterial3: true),
            darkTheme:
                ThemeData(colorScheme: (monetEnabled ? darkDynamic : null) ?? defaultDarkColor, useMaterial3: true),
            routeInformationProvider: AppPages.router.routeInformationProvider,
            routeInformationParser: AppPages.router.routeInformationParser,
            routerDelegate: AppPages.router.routerDelegate,
            scrollBehavior: CustScroll(),
          );
        },
      ),
    );
  }
}

final colorThemeProvider =
    StateProvider((ref) => getMaterialColor(Color(spInstance.getInt("colorSeed") ?? 4294198070)));

final monetEnableProvider = StateProvider((ref) => spInstance.getBool("dynamicColor") ?? false);

bool supportMonet = false;

// Locale locale = Locale("zh", "CN");

// final localeProvider = StateProvider((ref) => spInstance.getInt("locale") ?? 1);

// getLocale(int locale) {
//   Log.e(locale, "getLocal");
//   final arr = [const Locale("en", "US"), const Locale("zh", "CN"), const Locale("zh", "TW"), const Locale("ja", "JP")];
//   return arr[locale];
// }
